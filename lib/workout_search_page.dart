import 'package:flutter/material.dart';
import 'package:mymovewiseapp/exercise_data_service.dart';
import 'package:mymovewiseapp/exercise_detail_page.dart';
import 'package:mymovewiseapp/user.dart';

class WorkoutSearchPage extends StatefulWidget {
  final User user;

  const WorkoutSearchPage({super.key, required this.user});

  @override
  State<WorkoutSearchPage> createState() => _WorkoutSearchPageState();
}

class _WorkoutSearchPageState extends State<WorkoutSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _allExercises = [];
  List<Map<String, String>> _filteredExercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    try {
      final exercises = await ExerciseDataService.loadExercises(
        sortAlphabetically: true,
      );

      if (!mounted) return;
      setState(() {
        _allExercises
          ..clear()
          ..addAll(exercises);
        _filteredExercises = List<Map<String, String>>.from(exercises.take(16));
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _filterExercises(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      setState(() {
        _filteredExercises = List<Map<String, String>>.from(
          _allExercises.take(16),
        );
      });
      return;
    }

    final results = _allExercises
        .where((exercise) {
          final haystack = [
            exercise['name'],
            exercise['type'],
            exercise['bodyPart'],
            exercise['equipment'],
            exercise['level'],
          ].whereType<String>().join(' ').toLowerCase();
          return haystack.contains(trimmed);
        })
        .take(30)
        .toList();

    setState(() {
      _filteredExercises = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Search Workouts'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Search by name, body part, level, type, or equipment.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: _filterExercises,
                  decoration: InputDecoration(
                    hintText: 'Try: chest, dumbbell, beginner, cardio...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExercises.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No workouts matched that search yet.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent.withValues(
                              alpha: 0.12,
                            ),
                            child: const Icon(
                              Icons.fitness_center,
                              color: Colors.blueAccent,
                            ),
                          ),
                          title: Text(
                            exercise['name'] ?? 'Workout',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildInfoChip(exercise['type'] ?? 'General'),
                                _buildInfoChip(
                                  exercise['bodyPart'] ?? 'Full Body',
                                ),
                                _buildInfoChip(
                                  exercise['level'] ?? 'All Levels',
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
                                  exercise: exercise,
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

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.blueAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
