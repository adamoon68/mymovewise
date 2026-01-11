import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymovewiseapp/user.dart';
import 'package:mymovewiseapp/myconfig.dart';
import 'package:mymovewiseapp/loginpage.dart';

class AdminDashboard extends StatefulWidget {
  final User user;
  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List exercises = [];

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  void loadExercises() {
    http
        .get(
          Uri.parse("${MyConfig.baseUrl}/mymovewise/backend/get_exercises.php"),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var res = jsonDecode(response.body);
            if (res['status'] == 'success') {
              setState(() => exercises = res['data']);
            }
          }
        });
  }

  void uploadExercise(String name, String type) {
    http
        .post(
          Uri.parse(
            "${MyConfig.baseUrl}/mymovewise/backend/upload_exercise.php",
          ),
          body: {
            "name": name,
            "description": "Standard instruction",
            "type": type,
            "tags": "General", // Default tag
          },
        )
        .then((_) {
          Navigator.pop(context);
          loadExercises();
        });
  }

  void tagExercise(String id, String tag) {
    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/mymovewise/backend/tag_exercise.php"),
          body: {"exercise_id": id, "new_tag": tag},
        )
        .then((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Tagged as $tag")));
          loadExercises();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Upload New Exercise"),
              onPressed: () {
                TextEditingController nameCtrl = TextEditingController();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Add Exercise"),
                    content: TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            uploadExercise(nameCtrl.text, "Strength"),
                        child: const Text("Upload"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(exercises[index]['name']),
                    subtitle: Text("Tags: ${exercises[index]['tags']}"),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "Low Impact",
                          child: Text("Tag: Low Impact"),
                        ),
                        const PopupMenuItem(
                          value: "High Impact",
                          child: Text("Tag: High Impact"),
                        ),
                      ],
                      onSelected: (val) =>
                          tagExercise(exercises[index]['id'], val),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
