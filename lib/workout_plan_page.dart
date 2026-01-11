import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymovewiseapp/user.dart';
import 'package:mymovewiseapp/myconfig.dart';

class WorkoutPlanPage extends StatefulWidget {
  final User user;
  final String energyLevel;
  final String duration;
  final String equipment;

  const WorkoutPlanPage({
    super.key,
    required this.user,
    required this.energyLevel,
    required this.duration,
    required this.equipment,
  });

  @override
  State<WorkoutPlanPage> createState() => _WorkoutPlanPageState();
}

class _WorkoutPlanPageState extends State<WorkoutPlanPage> {
  List generatedPlan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAndFilterExercises();
  }

  void fetchAndFilterExercises() async {
    // 1. Fetch all exercises from server
    var url = Uri.parse(
      "${MyConfig.baseUrl}/mymovewise/backend/get_exercises.php",
    );
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res['status'] == 'success') {
        List allExercises = res['data'];

        // 2. Apply Logic Filter
        bool hasCondition =
            widget.user.chronicCondition != null &&
            widget.user.chronicCondition != "None";

        setState(() {
          generatedPlan = allExercises.where((ex) {
            String tags = ex['tags'] ?? "";
            // Safety Filter: If user has condition, exclude "High Impact" or "Unsafe"
            if (hasCondition &&
                (tags.contains("High Impact") || tags.contains("Unsafe"))) {
              return false;
            }
            return true;
          }).toList();
          isLoading = false;
        });
      }
    }
  }

  void saveWorkout() {
    http
        .post(
          Uri.parse("${MyConfig.baseUrl}/mymovewise/backend/save_workout.php"),
          body: {
            "user_id": widget.user.id,
            "exercise_name":
                "Custom ${widget.energyLevel} Session", // Summarized title
            "type": "Mixed",
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Workout Saved!")));
            Navigator.pop(context); // Go back to Home
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Plan")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.user.chronicCondition != "None")
                  Container(
                    color: Colors.red[100],
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    child: Text(
                      "Safety Mode Active: ${widget.user.chronicCondition} detected.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: generatedPlan.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(generatedPlan[index]['name']),
                          subtitle: Text(generatedPlan[index]['tags']),
                          trailing: const Icon(Icons.check_circle_outline),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      // FUNCTIONAL BUTTON: Saves to DB
                      onPressed: saveWorkout,
                      child: const Text("Finish & Save Workout"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
