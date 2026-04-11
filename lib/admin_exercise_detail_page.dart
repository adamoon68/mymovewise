import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymovewiseapp/myconfig.dart';

class AdminExerciseDetailPage extends StatefulWidget {
  final Map<String, String> exercise;

  const AdminExerciseDetailPage({super.key, required this.exercise});

  @override
  State<AdminExerciseDetailPage> createState() => _AdminExerciseDetailPageState();
}

class _AdminExerciseDetailPageState extends State<AdminExerciseDetailPage> {
  TextEditingController descController = TextEditingController();
  TextEditingController videoController = TextEditingController();
  String selectedIntensity = "Beginner";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // 1. Initialize with CSV data
    descController.text = widget.exercise['desc'] ?? "";
    selectedIntensity = widget.exercise['level'] ?? "Beginner";
    
    // 2. Fetch DB Overrides
    fetchCurrentData();
  }

  void fetchCurrentData() async {
    String name = widget.exercise['name']!;
    var url = Uri.parse("${MyConfig.baseUrl}/mymovewise/backend/get_desc.php?name=${Uri.encodeComponent(name)}");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['status'] == 'success') {
        setState(() {
          if (res['desc'] != null && res['desc'].toString().isNotEmpty) {
            descController.text = res['desc'];
          }
          if (res['video_link'] != null) {
            videoController.text = res['video_link'];
          }
          if (res['difficulty'] != null && res['difficulty'].toString().isNotEmpty) {
            selectedIntensity = res['difficulty'];
          }
        });
      }
    }
    setState(() => isLoading = false);
  }

  void saveChanges() {
    http.post(
      Uri.parse("${MyConfig.baseUrl}/mymovewise/backend/admin_update_exercise.php"),
      body: {
        "name": widget.exercise['name'],
        "type": widget.exercise['type'] ?? "General",
        "description": descController.text,
        "video_link": videoController.text,
        "difficulty": selectedIntensity,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Exercise Updated Successfully!")));
          Navigator.pop(context);
        } else {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${res['error']}")));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Exercise (Admin)")),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Editing: ${widget.exercise['name']}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              const SizedBox(height: 10),

              // 1. INTENSITY SELECTOR
              const Text("Set Intensity Level:", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: ["Beginner", "Intermediate", "Expert"].contains(selectedIntensity) ? selectedIntensity : "Beginner",
                isExpanded: true,
                items: ["Beginner", "Intermediate", "Expert"].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) => setState(() => selectedIntensity = newValue!),
              ),
              const SizedBox(height: 20),

              // 2. VIDEO LINK INPUT
              const Text("YouTube Video Link (Optional):", style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: videoController,
                decoration: const InputDecoration(
                  hintText: "https://www.youtube.com/watch?v=...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // 3. DESCRIPTION EDITOR
              const Text("Description / Instructions:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              TextField(
                controller: descController,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter step-by-step instructions...",
                ),
              ),
              const SizedBox(height: 30),

              // 4. SAVE BUTTON (No "Complete Workout" button here)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Changes"),
                  onPressed: saveChanges,
                ),
              ),
            ],
          ),
        ),
    );
  }
}