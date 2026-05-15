import 'package:flutter/material.dart';
import 'package:mymovewiseapp/exercise_data_service.dart';
import 'package:mymovewiseapp/medical_conditions.dart';
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
  List<Map<String, String>> _allExercises = [];
  List<Map<String, String>> _fullGeneratedPlan = [];
  List<Map<String, String>> generatedPlan = [];
  String _selectedLetter = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  void loadCsvData() async {
    try {
      final exercises = await ExerciseDataService.loadExercises(
        sortAlphabetically: true,
      );
      if (!mounted) return;
      setState(() {
        _allExercises = exercises;
      });
      generateWorkout();
    } catch (e) {
      debugPrint("Error loading CSV in Workout Plan: $e");
      setState(() => isLoading = false);
    }
  }

  void generateWorkout() {
    final tempPlan = <Map<String, String>>[];

    for (final exercise in _allExercises) {
      final name = exercise['name']?.trim() ?? '';
      final type = exercise['type']?.trim() ?? '';
      final equip = exercise['equipment']?.trim() ?? '';
      final level = exercise['level']?.trim() ?? '';
      final bodyPart = exercise['bodyPart']?.trim() ?? '';
      final description = exercise['desc']?.trim() ?? '';

      if (name.isEmpty) continue;
      if (!_matchesSafety(type)) continue;
      if (!_matchesEquipment(equip)) continue;
      if (!_matchesEnergyLevel(level)) continue;

      tempPlan.add({
        "name": name,
        "details": "$type | $equip",
        "desc": description,
        "type": type,
        "bodyPart": bodyPart,
        "level": level,
      });
    }

    final sortedPlan = _buildBalancedPlan(tempPlan, limit: _exerciseLimit);

    setState(() {
      _fullGeneratedPlan = sortedPlan;
      _selectedLetter = 'All';
      generatedPlan = sortedPlan;
      isLoading = false;
    });
  }

  bool get _hasChronicCondition {
    return !MedicalConditionCatalog.findByName(
      widget.user.chronicCondition,
    ).isNone;
  }

  int get _exerciseLimit {
    if (widget.duration == "15 mins") return 4;
    if (widget.duration == "30 mins") return 6;
    return 10;
  }

  bool _matchesSafety(String type) {
    if (!_hasChronicCondition) return true;

    final condition = MedicalConditionCatalog.findByName(
      widget.user.chronicCondition,
    );
    return !condition.avoidTypes.any(
      (item) => item.toLowerCase() == type.toLowerCase(),
    );
  }

  bool _matchesEquipment(String equipment) {
    if (widget.equipment == "None") {
      return equipment == "Body Only" || equipment == "None";
    }

    if (widget.equipment == "Dumbbells") {
      return equipment == "Body Only" ||
          equipment == "None" ||
          equipment == "Dumbbell";
    }

    return true;
  }

  bool _matchesEnergyLevel(String level) {
    if (widget.energyLevel == "Low") {
      return level == "Beginner";
    }

    if (widget.energyLevel == "Medium") {
      return level == "Beginner" || level == "Intermediate";
    }

    return true;
  }

  List<Map<String, String>> _buildBalancedPlan(
    List<Map<String, String>> exercises, {
    required int limit,
  }) {
    if (exercises.isEmpty || limit <= 0) return [];

    final grouped = <String, List<Map<String, String>>>{};
    for (final exercise in exercises) {
      final bodyPart = exercise['bodyPart']?.trim().isNotEmpty == true
          ? exercise['bodyPart']!.trim()
          : 'General';
      grouped.putIfAbsent(bodyPart, () => []).add(exercise);
    }

    grouped.forEach((_, group) {
      group.sort((a, b) {
        final scoreCompare = _exerciseScore(b).compareTo(_exerciseScore(a));
        if (scoreCompare != 0) return scoreCompare;
        return a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase());
      });
    });

    final bodyParts = grouped.keys.toList()..sort();
    final rotation = _deterministicHash(
      "${widget.energyLevel}|${widget.duration}|${widget.equipment}|${widget.user.chronicCondition ?? 'none'}",
    );
    final orderedBodyParts = [
      ...bodyParts.skip(rotation % bodyParts.length),
      ...bodyParts.take(rotation % bodyParts.length),
    ];

    final selected = <Map<String, String>>[];

    while (selected.length < limit) {
      var addedInPass = false;

      for (final bodyPart in orderedBodyParts) {
        final group = grouped[bodyPart]!;
        if (group.isEmpty) continue;

        selected.add(group.removeAt(0));
        addedInPass = true;

        if (selected.length >= limit) break;
      }

      if (!addedInPass) break;
    }

    return selected;
  }

  int _exerciseScore(Map<String, String> exercise) {
    final level = exercise['level'] ?? '';
    final type = exercise['type'] ?? '';
    final details = exercise['details'] ?? '';
    final hasDescription = (exercise['desc'] ?? '').trim().isNotEmpty;

    var score = hasDescription ? 20 : 0;

    switch (widget.energyLevel) {
      case "Low":
        if (level == "Beginner") score += 50;
        if (details.contains("Body Only") || details.contains("None")) {
          score += 15;
        }
        if (type == "Stretching" || type == "Cardio") score += 15;
        break;
      case "Medium":
        if (level == "Intermediate") score += 45;
        if (level == "Beginner") score += 30;
        if (type == "Strength") score += 12;
        if (details.contains("Dumbbell")) score += 8;
        break;
      case "High":
        if (level == "Expert") score += 60;
        if (level == "Intermediate") score += 45;
        if (level == "Beginner") score += 10;
        if (!_hasChronicCondition &&
            (type == "Plyometrics" ||
                type == "Powerlifting" ||
                type == "Olympic Weightlifting" ||
                type == "Strongman")) {
          score += 20;
        }
        if (!details.contains("Body Only")) score += 10;
        break;
    }

    if (_hasChronicCondition &&
        (type == "Stretching" || type == "Cardio" || type == "Strength")) {
      score += 10;
    }

    return score;
  }

  int _deterministicHash(String input) {
    var hash = 0;
    for (final codeUnit in input.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash;
  }

  void _filterGeneratedPlanByLetter(String letter) {
    final filtered = letter == 'All'
        ? List<Map<String, String>>.from(_fullGeneratedPlan)
        : _fullGeneratedPlan
              .where(
                (exercise) =>
                    exercise['name']!.toUpperCase().startsWith(letter),
              )
              .toList();

    setState(() {
      _selectedLetter = letter;
      generatedPlan = filtered;
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
                        Icon(
                          Icons.health_and_safety,
                          color: Colors.amber[900],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Safety Filters Active: ${widget.user.chronicCondition}",
                          style: TextStyle(
                            color: Colors.amber[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(
                  height: 58,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    children: [
                      _buildLetterChip('All'),
                      ...List.generate(
                        26,
                        (index) =>
                            _buildLetterChip(String.fromCharCode(65 + index)),
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
                                    color: Colors.grey.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blueAccent.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  generatedPlan[index]['name']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: [
                                      _buildTag(generatedPlan[index]['level']!),
                                      const SizedBox(width: 8),
                                      Text(
                                        generatedPlan[index]['bodyPart'] ?? "",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
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
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLetterChip(String letter) {
    final isSelected = _selectedLetter == letter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(letter),
        selected: isSelected,
        onSelected: (_) => _filterGeneratedPlanByLetter(letter),
        selectedColor: Colors.blueAccent,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.blueAccent,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.blueAccent),
      ),
    );
  }
}
