import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExerciseVideoPage extends StatefulWidget {
  final String exerciseName;

  const ExerciseVideoPage({super.key, required this.exerciseName});

  @override
  State<ExerciseVideoPage> createState() => _ExerciseVideoPageState();
}

class _ExerciseVideoPageState extends State<ExerciseVideoPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // 1. Construct the YouTube Search URL dynamically
    final String query = Uri.encodeComponent(widget.exerciseName);
    final String url = "https://www.youtube.com/results?search_query=$query";

    // 2. Initialize the WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tutorial Video")),
      body: WebViewWidget(controller: _controller),
    );
  }
}