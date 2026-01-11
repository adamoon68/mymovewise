import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:mymovewiseapp/user.dart';
import 'package:mymovewiseapp/exercise_detail_page.dart';

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
  List<List<dynamic>> _allExercises = [];
  List<Map<String, String>> generatedPlan = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  void loadCsvData() async {
    try {
      final rawData = await rootBundle.loadString("assets/megaGymDataset.csv");
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
      _allExercises = csvTable;
      generateWorkout();
    } catch (e) {
      print("Error loading CSV: $e");
      setState(() => isLoading = false);
    }
  }

  void generateWorkout() {
    List<Map<String, String>> tempPlan = [];
    
    bool isBeginner = widget.energyLevel == "Low";
    bool isIntermediate = widget.energyLevel == "Medium";
    
    // Skip header row
    for (var i = 1; i < _allExercises.length; i++) {
      var row = _allExercises[i];
      
      String name = row[1].toString();
      String type = row[3].toString();
      String equip = row[5].toString();
      String level = row[6].toString();

      // 1. Safety Filter
      if (widget.user.chronicCondition != "None" && widget.user.chronicCondition != null) {
        if (type == "Plyometrics" || type == "Olympic Weightlifting") continue;
      }

      // 2. Equipment Filter
      bool equipMatch = false;
      if (widget.equipment == "None") {
        if (equip == "Body Only" || equip == "None") equipMatch = true;
      } else if (widget.equipment == "Dumbbells") {
        if (equip == "Body Only" || equip == "Dumbbell") equipMatch = true;
      } else {
        equipMatch = true; 
      }

      // 3. Level Filter
      bool levelMatch = false;
      if (isBeginner) {
        if (level == "Beginner") levelMatch = true;
      } else if (isIntermediate) {
        if (level == "Beginner" || level == "Intermediate") levelMatch = true;
      } else {
        levelMatch = true; 
      }

      if (equipMatch && levelMatch) {
        tempPlan.add({
          "name": name,
          "details": "$type | $equip",
          "desc": row[2].toString(),
          "type": type,
          "bodyPart": row[4].toString(),
          "level": level,
        });
      }
    }

    tempPlan.shuffle();
    int limit = widget.duration == "15 mins" ? 4 : (widget.duration == "30 mins" ? 6 : 10);
    
    setState(() {
      generatedPlan = tempPlan.take(limit).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Theme Background
      appBar: AppBar(
        title: const Text("Your Custom Plan"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // --- Plan Summary Header ---
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  color: Colors.blueAccent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderInfo(Icons.flash_on, widget.energyLevel),
                      _buildHeaderInfo(Icons.timer, widget.duration),
                      _buildHeaderInfo(Icons.fitness_center, widget.equipment),
                    ],
                  ),
                ),

                // --- Safety Banner ---
                if (widget.user.chronicCondition != "None")
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    color: Colors.amber[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.health_and_safety, color: Colors.amber[900], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Safety Filters Active: ${widget.user.chronicCondition}",
                          style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                // --- Exercise List ---
                Expanded(
                  child: generatedPlan.isEmpty
                      ? const Center(child: Text("No exercises found."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: generatedPlan.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  generatedPlan[index]['name']!,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: [
                                      _buildTag(generatedPlan[index]['level']!),
                                      const SizedBox(width: 8),
                                      Text(
                                        generatedPlan[index]['bodyPart'] ?? "",
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ExerciseDetailPage(
                                        exercise: generatedPlan[index],
                                        user: widget.user,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTag(String text) {
    Color color = Colors.green;
    if (text == "Intermediate") color = Colors.orange;
    if (text == "Expert") color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}