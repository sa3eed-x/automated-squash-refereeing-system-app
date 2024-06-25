import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/screens/referee/referee_recall.dart';
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';

const int _kWinningScore = 11;
const int _kMargin = 2;
const int _kWinStreak = 2;

class VideoDisplayer extends StatefulWidget {
  static const routeName = '/squash-game';
  final String player1Name;
  final String player2Name;

  VideoDisplayer({required this.player1Name, required this.player2Name});

  @override
  _VideoDisplayerState createState() =>
      _VideoDisplayerState(player1Name: player1Name, player2Name: player2Name);
}

class _VideoDisplayerState extends State<VideoDisplayer> {
  late VideoPlayerController _controller;
  bool _isDarkTheme = false; // Add a flag to track the theme
  final String player1Name;
  final String player2Name;

  _VideoDisplayerState({required this.player1Name, required this.player2Name});

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/output_video.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the video is played.
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme
          ? ThemeData.dark()
          : ThemeData.light(), // Update the theme based on the flag
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Score Board',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            Switch(
              value: _isDarkTheme,
              onChanged: (value) {
                setState(() {
                  _isDarkTheme = value;
                });
              },
            ),
          ],
        ),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.555,
              color: Colors.black,
              child: VideoPlayer(_controller),
            ),
            const Divider(
              color: Colors.white,
              height: 3,
            ),
            // AspectRatio(
            //   aspectRatio: _controller.value.aspectRatio,
            //   child: VideoPlayer(_controller),
            // ),
            Container(
              height: MediaQuery.of(context).size.height * 0.33,
              child: GameState(
                player1Name: player1Name,
                player2Name: player2Name,
              ),
            ),
            const Divider(
              color: Colors.white,
              height: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class GameState extends StatefulWidget {
  final String player1Name;
  final String player2Name;
  const GameState({required this.player1Name, required this.player2Name});

  @override
  _GameStateState createState() => _GameStateState();
}

class _GameStateState extends State<GameState> with TickerProviderStateMixin {
  late List<double> predictions = [];
  String yes_let = '';
  String no_let = '';
  String stroke = '';
  String biggst = '';

  late String _player1Name;
  late String _player2Name;

  int _cooldownTimer = 0;

  int _player1Score = 0;
  int _player2Score = 0;
  int _gamesWonPlayer1 = 0;
  int _gamesWonPlayer2 = 0;
  bool _matchOver = false;

  Stopwatch _gameTimer = Stopwatch();
  Duration _totalMatchTime = Duration.zero;
  Timer? _updateTimer;

  bool _showServerSideButtons = false;
  String? _serverSide;
  int _lastPointScoredBy = 0;

  bool _isNotGoodLightOn = false;
  bool _isDoubleLightOn = false;

  bool _isWinStreak(int player) {
    return player == 1
        ? _player1Score > _player2Score
        : _player2Score > _player1Score;
  }

  Future<void> sendVideoAndGetPrediction(String videoPath) async {
    try {
      final response = await http.put(
        Uri.parse(
            // http://127.0.0.1:5000/upload chrome
            // http://10.0.2.2:5000/upload  tablet
            'http://10.0.2.2:5000/upload'), // Replace with your Flask server IP
        body: {'video_path': videoPath},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          predictions = List<double>.from(data['predictions']);
          double maxPrediction =
              predictions.reduce((curr, next) => curr > next ? curr : next);
          yes_let = predictions[0].toStringAsFixed(1) + '%';
          stroke = predictions[1].toStringAsFixed(1) + '%';
          no_let = predictions[2].toStringAsFixed(1) + '%';
          log('predictions: $predictions');
          log('maxPrediction: $maxPrediction');
          if (maxPrediction == predictions[0]) {
            log('Yes Let: $yes_let');
            biggst = 'Yes Let';
          } else if (maxPrediction == predictions[1]) {
            log('Stroke: $stroke');
            biggst = 'Stroke';
          } else if (maxPrediction == predictions[2]) {
            log('No Let: $no_let');
          }
        });
      } else {
        setState(() {
          // predictions = 'Failed to get prediction';
        });
      }
    } catch (e) {
      setState(() {
        // predictions = 'Error: $e';
      });
    }
  }

  void _handlePointScored(int player) {
    if (!_matchOver) {
      setState(() {
        if (player == 1) {
          _player1Score++;
        } else {
          _player2Score++;
        }

        if (player != _lastPointScoredBy) {
          _showServerSideButtons = true;
          _lastPointScoredBy = player;
        }

        if (_isGameWon(player)) {
          if (player == 1) {
            _gamesWonPlayer1++;
          } else {
            _gamesWonPlayer2++;
          }
          _stopTimer();
          _checkMatchOver();
        }

        _isNotGoodLightOn = false;
        _isDoubleLightOn = false;
      });
    }
  }

  void _handlePointRemoved(int player) {
    if (!_matchOver) {
      setState(() {
        if (player == 1) {
          _player1Score--;
          if (_player1Score < 0) {
            _player1Score = 0;
          }
        } else {
          _player2Score--;
          if (_player2Score < 0) {
            _player2Score = 0;
          }
        }
      });
    }
  }

  bool _isGameWon(int player) {
    return (_player1Score >= _kWinningScore &&
            _player1Score - _player2Score >= _kMargin) ||
        (_player2Score >= _kWinningScore &&
            _player2Score - _player1Score >= _kMargin);
  }

  void _resetGameScores() {
    _player1Score = 0;
    _player2Score = 0;
    _showServerSideButtons = true;
    _serverSide = null;
    _lastPointScoredBy = 0;
    _gameTimer.reset();
    _startTimer(); // Start the timer at the beginning of each game
  }

  bool _isCooldownActive = false;

  void _checkMatchOver() {
    if (_gamesWonPlayer1 == 3 || _gamesWonPlayer2 == 3) {
      setState(() {
        _matchOver = true;
      });
    } else {
      setState(() {
        _isCooldownActive = true;
      });
      showDialog(
        context: context,
        barrierDismissible:
            false, // Prevent the dialog from being dismissed by tapping outside of it
        builder: (BuildContext context) {
          return CooldownDialog(
            onSkip: () {
              Navigator.of(context).pop();
              _resetGameScores();
              setState(() {
                _isCooldownActive = false;
              });
            },
            duration: Duration(seconds: 90),
          );
        },
      );
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer = 90;
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _cooldownTimer--;
        if (_cooldownTimer == 0) {
          timer.cancel();
          _resetGameScores();
          setState(() {
            _isCooldownActive = false;
          });
        }
      });
    });
  }

  void _startTimer() {
    _gameTimer.start();
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _stopTimer() {
    _gameTimer.stop();
    _totalMatchTime += _gameTimer.elapsed;
    _updateTimer?.cancel();
  }

  String _formattedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  // Widget _buildServerSideButtons() {
  //   if (_showServerSideButtons) {
  //     return Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         ElevatedButton(
  //           onPressed: () {
  //             setState(() {
  //               _serverSide = 'L';
  //               _showServerSideButtons = false;
  //             });
  //           },
  //           child: const Text('L'),
  //         ),
  //         const SizedBox(width: 20),
  //         ElevatedButton(
  //           onPressed: () {
  //             setState(() {
  //               _serverSide = 'R';
  //               _showServerSideButtons = false;
  //             });
  //           },
  //           child: const Text('R'),
  //         ),
  //       ],
  //     );
  //   } else {
  //     return Container();
  //   }
  // }

  Widget _buildScoreButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isNotGoodLightOn || _isDoubleLightOn || _isCooldownActive)
              ElevatedButton(
                onPressed: null,
                child: const Text('-'),
              )
            else
              ElevatedButton(
                onPressed: () => _showDecrementConfirmationDialog(1),
                child: const Text('-'),
              ),
            const SizedBox(width: 10),
            if (_isNotGoodLightOn || _isDoubleLightOn || _isCooldownActive)
              ElevatedButton(
                onPressed: null,
                child: const Text('Player 1'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  _handlePointScored(1);
                  setState(() {
                    _isNotGoodLightOn = false;
                    _isDoubleLightOn = false;
                  });
                },
                child: const Text('Player 1'),
              ),
            const SizedBox(width: 10),
            if (_isNotGoodLightOn || _isDoubleLightOn || _isCooldownActive)
              ElevatedButton(
                onPressed: null,
                child: const Text('Player 2'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  _handlePointScored(2);
                  setState(() {
                    _isNotGoodLightOn = false;
                    _isDoubleLightOn = false;
                  });
                },
                child: const Text('Player 2'),
              ),
            const SizedBox(width: 10),
            if (_isNotGoodLightOn || _isDoubleLightOn || _isCooldownActive)
              ElevatedButton(
                onPressed: null,
                child: const Text('-'),
              )
            else
              ElevatedButton(
                onPressed: () => _showDecrementConfirmationDialog(2),
                child: const Text('-'),
              ),
          ],
        ),
      ],
    );
  }

  void _showDecrementConfirmationDialog(int player) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Edit'),
        content: Text(
            'Are you sure you want to edit ${player == 1 ? 'Player 1' : 'Player 2'}\'s score?'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _handlePointRemoved(player);
              Navigator.pop(context);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchPlayerNames();
    _startTimer();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPlayerNames() async {
    final player1Doc = await FirebaseFirestore.instance
        .collection('matches')
        .doc('your_match_id_here')
        .get();
    final player2Doc = await FirebaseFirestore.instance
        .collection('matches')
        .doc('your_other_match_id_here')
        .get();

    setState(() {
      _player1Name = player1Doc.get('player1Name');
      _player2Name = player2Doc.get('player2Name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LightBulbButton(
                label: 'Not Good',
                lightState: _isNotGoodLightOn,
                onChanged: (bool newState) {
                  setState(() {
                    _isNotGoodLightOn = newState;
                  });
                },
              ),
              const SizedBox(width: 50),
              Column(
                children: [
                  Text(
                    '${widget.player1Name}: ${_gamesWonPlayer1}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    '$_player1Score - $_player2Score',
                    style: const TextStyle(fontSize: 32),
                  ),
                  Text(
                    '${widget.player2Name}: ${_gamesWonPlayer2}',
                    style: const TextStyle(fontSize: 24),
                  ),
                  if (!_matchOver)
                    Text(
                      'Game Time: ${_formattedTime(_gameTimer.elapsed)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                ],
              ),
              const SizedBox(width: 50),
              Column(
                children: [
                  LightBulbButton(
                    label: 'Double',
                    lightState: _isDoubleLightOn,
                    onChanged: (bool newState) {
                      setState(() {
                        _isDoubleLightOn = newState;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await sendVideoAndGetPrediction(
                          //"D:/college/Mobile/flutter_application_4/assets/no_let(1).mov"
                          "D:/college/Mobile/flutter_application_4/assets/no_let(1).mov"); //"D:/college/Mobile/flutter_application_4/assets/no_let(10).mov"
                      Future.delayed(Duration(seconds: 2), () {
                        //"D:/college/Mobile/flutter_application_4/assets/yes_let(10).mov"
                        // Code to execute after delay                                           D:/college/Mobile/flutter_application_4/assets/yes_let(11).mov
                        // Navigate to the second screen                                         D:/college/Mobile/flutter_application_4/assets/stroke(2).mp4
                        Navigator.push(
                          //D:/college/Mobile/flutter_application_4/assets/yes_let(12).mov
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyScreen(
                                    // stroke: stroke,
                                    // yes_let: yes_let,
                                    // no_let: no_let,
                                    // maxPrediction:maxPrediction,
                                    predictions: predictions,
                                  )),
                        );
                      });
                    },
                    child: Text('Recall'),
                  ),
                  // Text(yes_let),
                  // Text(stroke),
                  // Text(no_let),
                ],
              )

              // const SizedBox(width: 300),
              // LightBulbButton(
              //   label: 'Double',
              //   lightState: _isDoubleLightOn,
              //   onChanged: (bool newState) {
              //     setState(() {
              //       _isDoubleLightOn = newState;
              //     });
              //   },
              // ),
            ],
          ),
          const SizedBox(height: 20),
          _buildScoreButtons(),
          // _buildServerSideButtons(),
          if (_matchOver)
            Text(
              'Player ${_gamesWonPlayer1 == 3 ? 1 : 2} Wins!',
              style: const TextStyle(fontSize: 24),
            ),
          if (_matchOver)
            Text(
              'Total Match Time: ${_formattedTime(_totalMatchTime)}',
              style: const TextStyle(fontSize: 18),
            ),
        ],
      ),
    );
  }
}

// Define a boolean variable to track the state of the light bulb

// Create a StatefulWidget to handle the state change
class LightBulbButton extends StatefulWidget {
  final String label;
  final bool lightState;
  final Function(bool) onChanged;

  LightBulbButton(
      {required this.label, required this.lightState, required this.onChanged});

  @override
  _LightBulbButtonState createState() => _LightBulbButtonState();
}

class _LightBulbButtonState extends State<LightBulbButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // Use a conditional statement to change the button's appearance based on the lightState
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.lightState
            ? Color.fromARGB(255, 247, 5, 5)
            : Colors.grey, // Yellow for on, grey for off
      ),
      onPressed: () {
        // Toggle the lightState when the button is pressed
        widget.onChanged(!widget.lightState);
      },
      child: Text(widget.label),
    );
  }
}

class CooldownDialog extends StatefulWidget {
  final VoidCallback onSkip;
  final Duration duration;

  CooldownDialog({required this.onSkip, required this.duration});

  @override
  _CooldownDialogState createState() => _CooldownDialogState();
}

class _CooldownDialogState extends State<CooldownDialog>
    with TickerProviderStateMixin {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - Duration(seconds: 1);
        } else {
          timer.cancel();
          widget.onSkip();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Match Not Over'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Please wait for the cooldown timer.'),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: _remainingTime.inSeconds / widget.duration.inSeconds,
            minHeight: 16,
          ),
          SizedBox(height: 16),
          Text(
              '${_remainingTime.inMinutes}:${_remainingTime.inSeconds % 60} remaining'),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Skip'),
          onPressed: widget.onSkip,
        ),
      ],
    );
  }
}
