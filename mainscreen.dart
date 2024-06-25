import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController linkController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: linkController,
              decoration: InputDecoration(
                hintText: "Link..."
              ),
            ),
            GestureDetector(
              onTap: () {
                _launchUrl(linkController.text.trim().toLowerCase());
              },
              child: Container(
                height: 40,
                width: 200,
                color: Colors.green,
                child: Center(child: Text("Launch Url")),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    if(await canLaunch(urlString)) {
      await launch(
        urlString,
        forceWebView: true,
      );
    } else {
      print("Can\'t Launch Url");
    }
  }
}
