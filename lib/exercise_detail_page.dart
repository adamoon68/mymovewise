import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mymovewiseapp/user.dart';
import 'package:mymovewiseapp/myconfig.dart';
import 'package:mymovewiseapp/exercise_video_page.dart';

class ExerciseDetailPage extends StatefulWidget {
  final Map<String, String> exercise;
  final User user;

  const ExerciseDetailPage({
    super.key,
    required this.exercise,
    required this.user,
  });

  @override
  State<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  late String displayName;
  late String displayDesc;
  late String displayLevel;
  String? customVideoLink;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    displayName = widget.exercise['name'] ?? "Exercise";
    displayDesc = widget.exercise['desc'] ?? "No description available.";
    displayLevel = widget.exercise['level'] ?? "All Levels";
    fetchRemoteData();
  }

  void fetchRemoteData() async {
    String name = widget.exercise['name']!;
    var url = Uri.parse("${MyConfig.baseUrl}/mymovewise/backend/get_desc.php?name=${Uri.encodeComponent(name)}");
    
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['status'] == 'success') {
          setState(() {
            if (res['desc'] != null && res['desc'].toString().isNotEmpty) {
              displayDesc = res['desc'];
            }
            if (res['difficulty'] != null && res['difficulty'].toString().isNotEmpty) {
              displayLevel = res['difficulty'];
            }
            if (res['video_link'] != null && res['video_link'].toString().isNotEmpty) {
              customVideoLink = res['video_link'];
            }
          });
        }
      }
    } catch (e) {
      print("Sync Error: $e");
    }
    setState(() => isLoading = false);
  }

  void markExerciseComplete() {
    http.post(
      Uri.parse("${MyConfig.baseUrl}/mymovewise/backend/save_workout.php"),
      body: {
        "user_id": widget.user.id,
        "exercise_name": widget.exercise['name'],
        "type": widget.exercise['type'] ?? "Strength",
      },
    ).then((response) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Great job! Saved to history."),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void openVideo() {
    if (customVideoLink != null && customVideoLink!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: Text(displayName)),
            body: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(customVideoLink!)),
            ),
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseVideoPage(exerciseName: widget.exercise['name']!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Workout Details"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Top Curve Header ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 20),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fitness_center, size: 50, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Info Chips ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoChip(Icons.flash_on, widget.exercise['type'] ?? "General"),
                      const SizedBox(width: 10),
                      _buildInfoChip(Icons.bar_chart, displayLevel),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // --- Description Box ---
                  const Text("Instructions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      displayDesc,
                      style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[800]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.exercise['bodyPart'] != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Chip(
                        label: Text("Target: ${widget.exercise['bodyPart']}"),
                        backgroundColor: Colors.blue[50],
                      ),
                    ),

                  const SizedBox(height: 40),

                  // --- Buttons ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.play_circle_fill, color: Colors.red),
                      label: const Text("Watch Video Tutorial", style: TextStyle(fontSize: 16)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: openVideo,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Complete & Save to History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: markExerciseComplete,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}