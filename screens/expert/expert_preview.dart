import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/data/foul_repository.dart';
import 'package:flutter_application_4/data/match_repository.dart';
import 'package:flutter_application_4/screens/admin/edit_match.dart';
import 'package:flutter_application_4/screens/v.dart';

// ignore: must_be_immutable
class VideoPreviewPage extends StatefulWidget {
  late String uid;
  late String camera1;
  late String camera2;
  late String camera3;
  VideoPreviewPage({
    required this.uid,
    required this.camera1,
    required this.camera2,
    required this.camera3,
  });

  @override
  _VideoPreviewPageState createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  late String _bigVideo;
  late String _smallVideo1;
  late String _smallVideo2;

  @override
  void initState() {
    super.initState();
    // _bigVideo = VideoPlayerFromAssets(videoPath: 'NoLet (2).mp4');
    // _smallVideo1 = VideoPlayerFromAssets(
    //     videoPath: 'NoLet (3).mp4'); // Placeholder for the first small video
    // _smallVideo2 = VideoPlayerFromAssets(
    //     videoPath: 'NoLet (4).mp4'); // Placeholder for the second small video
    _bigVideo = widget.camera1;
    _smallVideo1 = widget.camera2;
    _smallVideo2 = widget.camera3;
  }

  void _swapVideos(String smallVideo) {
    setState(() {
      String temp = _bigVideo;
      if (smallVideo == _smallVideo1) {
        _bigVideo = smallVideo;
        _smallVideo1 = temp;
      } else {
        _bigVideo = smallVideo;
        _smallVideo2 = temp;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preview: collection ${widget.uid} , Date: 2024',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          // First row with a single smaller video
          Container(
              height: MediaQuery.of(context).size.height * 0.55,
              color: Colors.black,
              child: VideoPlayerFromAssets(videoPath: _bigVideo)),
          const Divider(
            color: Colors.lightBlue,
            height: 4,
          ),
          // Second row with two smaller videos
          Container(
            height: MediaQuery.of(context).size.height * 0.23,
            color: Colors.white70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  color: Colors.black,
                  child: Image.asset(
                    'assets/psaLogo.png',
                    width: 300,
                    height: 250,
                  ),
                ),
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: () => _swapVideos(_smallVideo1),
                  child: VideoPlayerFromAssets(videoPath: _smallVideo1),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () => _swapVideos(_smallVideo2),
                  child: VideoPlayerFromAssets(videoPath: _smallVideo2),
                ),
                const SizedBox(width: 2),
                Container(
                  color: Colors.black,
                  child: Image.asset(
                    'assets/wso.jpg',
                    width: 350,
                    height: 250,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Colors.black,
            height: 4,
          ),
          // Third row with three buttons
          Container(
            // color: Colors.lightBlue,
            height: MediaQuery.of(context).size.height * 0.092,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => {
                    updateFoul(uid: widget.uid, decision: 'Stroke'),
                    Navigator.pop(context),
                  }, // Change the video path as needed
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Stroke ',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () => {
                    updateFoul(uid: widget.uid, decision: 'Yes Let'),
                    Navigator.pop(context),
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Yes Let',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () => {
                    updateFoul(uid: widget.uid, decision: 'No Let'),
                    Navigator.pop(context),
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text('No Let',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
