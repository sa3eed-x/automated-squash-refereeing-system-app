import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerFromAssets extends StatefulWidget {
  final String videoPath;

  VideoPlayerFromAssets({required this.videoPath});

  @override
  _VideoPlayerFromAssetsState createState() => _VideoPlayerFromAssetsState();
}

class _VideoPlayerFromAssetsState extends State<VideoPlayerFromAssets> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {widget.videoPath;});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : CircularProgressIndicator(),
          _isPlaying
              ? IconButton(
                  icon: Icon(Icons.pause, size: 50),
                  onPressed: () {
                    setState(() {
                      _isPlaying = false;
                      _controller.pause();
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.play_arrow, size: 50),
                  onPressed: () {
                    setState(() {
                      _isPlaying = true;
                      _controller.play();
                    });
                  },
                ),
        ],
      ),
    );
  }
}