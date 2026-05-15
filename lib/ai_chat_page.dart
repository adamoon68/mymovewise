import 'package:flutter/material.dart';
import 'package:mymovewiseapp/exercise_detail_page.dart';
import 'package:mymovewiseapp/medical_conditions.dart';
import 'package:mymovewiseapp/user.dart';
import 'package:mymovewiseapp/workout_recommender_service.dart';

class AIChatPage extends StatefulWidget {
  final User user;

  const AIChatPage({super.key, required this.user});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _promptController = TextEditingController();
  WorkoutRecommendationResult? _result;
  bool _isLoading = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _recommendWorkouts() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty || _isLoading) return;

    setState(() => _isLoading = true);

    final result = await WorkoutRecommenderService.recommend(
      user: widget.user,
      prompt: prompt,
    );

    if (!mounted) return;
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstName = widget.user.name?.split(' ').first ?? 'User';
    final condition = MedicalConditionCatalog.findByName(
      widget.user.chronicCondition,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Workout Assistant'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Describe the workout you want, $firstName.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  condition.isNone
                      ? 'MoveWise will match exercises from the dataset using rule-based filtering.'
                      : 'Your ${condition.name.toLowerCase()} safety filter is active before results are shown.',
                  style: const TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _promptController,
                  minLines: 2,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _recommendWorkouts(),
                  decoration: InputDecoration(
                    hintText:
                        'Example: I need a gentle 20 minute home workout for my back and core.',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildPromptChip(
                      'Gentle home workout',
                      'Need a gentle 20 minute home workout with no jumping.',
                    ),
                    _buildPromptChip(
                      'Beginner upper body',
                      'Give me a beginner upper body strength workout with dumbbells.',
                    ),
                    _buildPromptChip(
                      'Stretch and recovery',
                      'Suggest a low impact recovery and stretching routine for sore legs.',
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _recommendWorkouts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF103D77),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(
                      _isLoading
                          ? 'Matching workouts...'
                          : 'Find Safe Workouts',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _result == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Enter a natural language prompt to get matched exercises from the workout dataset.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildSummaryCard(_result!, condition),
                      const SizedBox(height: 18),
                      ..._result!.exercises.map(_buildExerciseCard),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String label, String prompt) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      side: BorderSide.none,
      onPressed: () {
        setState(() {
          _promptController.text = prompt;
        });
      },
    );
  }

  Widget _buildSummaryCard(
    WorkoutRecommendationResult result,
    MedicalConditionOption condition,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Matched Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            result.summary,
            style: const TextStyle(fontSize: 15, height: 1.45),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: result.detectedNeeds.isEmpty
                ? [_buildInfoChip('Balanced'), _buildInfoChip(condition.name)]
                : result.detectedNeeds.map(_buildInfoChip).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE7C76D)),
            ),
            child: Text(
              result.safetyNote,
              style: const TextStyle(color: Color(0xFF6A5600), height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, String> exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          horizontal: 18,
          vertical: 14,
        ),
        title: Text(
          exercise['name'] ?? 'Workout',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoChip(exercise['type'] ?? 'General'),
                  _buildInfoChip(exercise['bodyPart'] ?? 'Full Body'),
                  _buildInfoChip(exercise['level'] ?? 'All Levels'),
                  _buildInfoChip(exercise['equipment'] ?? 'Mixed'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                exercise['why'] ?? 'Matched for your prompt.',
                style: const TextStyle(color: Colors.black54, height: 1.4),
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
              builder: (_) =>
                  ExerciseDetailPage(exercise: exercise, user: widget.user),
            ),
          );
        },
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
