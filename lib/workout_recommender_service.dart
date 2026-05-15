import 'package:mymovewiseapp/exercise_data_service.dart';
import 'package:mymovewiseapp/medical_conditions.dart';
import 'package:mymovewiseapp/user.dart';

class WorkoutRecommendationResult {
  final String summary;
  final String safetyNote;
  final List<String> detectedNeeds;
  final List<Map<String, String>> exercises;

  const WorkoutRecommendationResult({
    required this.summary,
    required this.safetyNote,
    required this.detectedNeeds,
    required this.exercises,
  });
}

class WorkoutRecommenderService {
  static Future<WorkoutRecommendationResult> recommend({
    required User user,
    required String prompt,
  }) async {
    final exercises = await ExerciseDataService.loadExercises(
      sortAlphabetically: true,
    );
    final condition = MedicalConditionCatalog.findByName(user.chronicCondition);
    final profile = _PromptProfile.fromPrompt(prompt);

    final scored = <_ScoredExercise>[];
    for (final exercise in exercises) {
      final score = _scoreExercise(
        exercise: exercise,
        profile: profile,
        condition: condition,
      );
      if (score != null) {
        scored.add(score);
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final selected = scored.take(profile.resultLimit).map((item) {
      return {...item.exercise, 'why': item.reason};
    }).toList();

    return WorkoutRecommendationResult(
      summary: _buildSummary(profile, condition, selected.length),
      safetyNote: _buildSafetyNote(condition),
      detectedNeeds: profile.detectedNeeds,
      exercises: selected,
    );
  }

  static _ScoredExercise? _scoreExercise({
    required Map<String, String> exercise,
    required _PromptProfile profile,
    required MedicalConditionOption condition,
  }) {
    final name = (exercise['name'] ?? '').trim();
    final description = (exercise['desc'] ?? '').trim();
    final type = (exercise['type'] ?? '').trim();
    final bodyPart = (exercise['bodyPart'] ?? '').trim();
    final equipment = (exercise['equipment'] ?? '').trim();
    final level = (exercise['level'] ?? '').trim();

    if (name.isEmpty) return null;

    final haystack = [
      name,
      description,
      type,
      bodyPart,
      equipment,
      level,
    ].join(' ').toLowerCase();

    if (_isUnsafeForCondition(
      haystack: haystack,
      type: type,
      bodyPart: bodyPart,
      condition: condition,
    )) {
      return null;
    }

    if (profile.requiresHomeFriendly &&
        !_matchesAny(equipment.toLowerCase(), [
          'body only',
          'none',
          'bands',
          'dumbbell',
        ])) {
      return null;
    }

    if (profile.requiredEquipment.isNotEmpty &&
        !_matchesAny(equipment.toLowerCase(), profile.requiredEquipment)) {
      return null;
    }

    var score = 10;
    final reasons = <String>[];

    if (profile.requestedBodyParts.isNotEmpty) {
      if (profile.requestedBodyParts.contains(bodyPart.toLowerCase())) {
        score += 35;
        reasons.add('targets ${exercise['bodyPart']}');
      } else {
        score -= 10;
      }
    }

    if (profile.requestedTypes.isNotEmpty) {
      if (profile.requestedTypes.contains(type.toLowerCase())) {
        score += 24;
        reasons.add('${exercise['type']} style match');
      } else {
        score -= 4;
      }
    }

    if (condition.preferredTypes
        .map((item) => item.toLowerCase())
        .contains(type.toLowerCase())) {
      score += 18;
      reasons.add('fits ${condition.name.toLowerCase()} safety profile');
    }

    if (profile.preferredLevel != null) {
      if (profile.preferredLevel == level.toLowerCase()) {
        score += 18;
      } else if (profile.preferredLevel == 'beginner' &&
          level.toLowerCase() != 'beginner') {
        score -= 8;
      }
    }

    if (profile.isGentleRequest && level.toLowerCase() == 'beginner') {
      score += 20;
      reasons.add('beginner-friendly');
    }

    if (profile.needsLowImpact &&
        (type == 'Stretching' || type == 'Cardio' || level == 'Beginner')) {
      score += 12;
    }

    for (final keyword in profile.promptKeywords) {
      if (keyword.length >= 4 && haystack.contains(keyword)) {
        score += 6;
      }
    }

    if (profile.requiredEquipment.isEmpty && profile.requiresHomeFriendly) {
      if (equipment == 'Body Only' || equipment == 'None') {
        score += 12;
        reasons.add('home-friendly');
      } else if (equipment == 'Bands' || equipment == 'Dumbbell') {
        score += 8;
      }
    }

    if (description.isNotEmpty) {
      score += 4;
    }

    if (profile.requestedTypes.isEmpty &&
        type == 'Strength' &&
        !profile.isGentleRequest &&
        !profile.needsLowImpact) {
      score += 8;
    }

    return _ScoredExercise(
      exercise: exercise,
      score: score,
      reason: reasons.isEmpty
          ? 'Matched your prompt with a safer general fit.'
          : reasons.take(2).join(' • '),
    );
  }

  static bool _isUnsafeForCondition({
    required String haystack,
    required String type,
    required String bodyPart,
    required MedicalConditionOption condition,
  }) {
    if (condition.isNone) return false;

    if (condition.avoidTypes.any(
      (item) => item.toLowerCase() == type.toLowerCase(),
    )) {
      return true;
    }

    if (condition.avoidBodyParts.any(
      (item) => item.toLowerCase() == bodyPart.toLowerCase(),
    )) {
      return true;
    }

    for (final keyword in condition.avoidKeywords) {
      if (haystack.contains(keyword.toLowerCase())) {
        return true;
      }
    }

    return false;
  }

  static bool _matchesAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }

  static String _buildSummary(
    _PromptProfile profile,
    MedicalConditionOption condition,
    int resultCount,
  ) {
    final focus = profile.detectedNeeds.isEmpty
        ? 'a balanced workout direction'
        : profile.detectedNeeds.join(', ');
    final conditionText = condition.isNone
        ? 'with general safety rules'
        : 'while accounting for ${condition.name.toLowerCase()}';

    return 'I matched $resultCount exercises for $focus $conditionText.';
  }

  static String _buildSafetyNote(MedicalConditionOption condition) {
    if (condition.isNone) {
      return 'No condition filter is active, so recommendations are based on your prompt and lower-risk defaults only.';
    }

    return 'Safety filter active for ${condition.name}: ${condition.description}';
  }
}

class _ScoredExercise {
  final Map<String, String> exercise;
  final int score;
  final String reason;

  const _ScoredExercise({
    required this.exercise,
    required this.score,
    required this.reason,
  });
}

class _PromptProfile {
  final List<String> requestedBodyParts;
  final List<String> requestedTypes;
  final List<String> requiredEquipment;
  final List<String> promptKeywords;
  final List<String> detectedNeeds;
  final bool requiresHomeFriendly;
  final bool isGentleRequest;
  final bool needsLowImpact;
  final String? preferredLevel;
  final int resultLimit;

  const _PromptProfile({
    required this.requestedBodyParts,
    required this.requestedTypes,
    required this.requiredEquipment,
    required this.promptKeywords,
    required this.detectedNeeds,
    required this.requiresHomeFriendly,
    required this.isGentleRequest,
    required this.needsLowImpact,
    required this.preferredLevel,
    required this.resultLimit,
  });

  factory _PromptProfile.fromPrompt(String prompt) {
    final text = prompt.toLowerCase();

    final bodyPartKeywords = <String, List<String>>{
      'abdominals': ['abs', 'core', 'abdominal'],
      'chest': ['chest', 'pec'],
      'back': ['back', 'lats', 'upper back'],
      'lower back': ['lower back', 'lumbar'],
      'shoulders': ['shoulder', 'delts'],
      'biceps': ['biceps', 'arms'],
      'triceps': ['triceps', 'arms'],
      'quadriceps': ['quads', 'quadriceps', 'legs'],
      'hamstrings': ['hamstrings', 'posterior chain'],
      'glutes': ['glutes', 'glute', 'butt'],
      'calves': ['calves', 'calf'],
      'full body': ['full body', 'whole body', 'all body'],
    };

    final typeKeywords = <String, List<String>>{
      'strength': ['strength', 'muscle', 'build'],
      'cardio': ['cardio', 'fat loss', 'endurance', 'conditioning'],
      'stretching': ['stretch', 'mobility', 'warm up', 'cool down', 'recovery'],
    };

    final equipmentKeywords = <String, List<String>>{
      'body only': ['no equipment', 'bodyweight', 'at home', 'home'],
      'dumbbell': ['dumbbell', 'dumbbells'],
      'bands': ['band', 'bands', 'resistance band'],
      'barbell': ['barbell'],
      'kettlebells': ['kettlebell'],
      'cable': ['cable', 'machine'],
    };

    final requestedBodyParts = <String>[
      for (final entry in bodyPartKeywords.entries)
        if (entry.value.any(text.contains)) entry.key,
    ];

    final requestedTypes = <String>[
      for (final entry in typeKeywords.entries)
        if (entry.value.any(text.contains)) entry.key,
    ];

    final requiredEquipment = <String>[
      for (final entry in equipmentKeywords.entries)
        if (entry.value.any(text.contains)) entry.key,
    ];

    final isGentleRequest = _hasAny(text, [
      'beginner',
      'easy',
      'gentle',
      'light',
      'recovery',
      'rehab',
    ]);
    final needsLowImpact =
        isGentleRequest ||
        _hasAny(text, ['low impact', 'pain', 'joint', 'safe']);
    final requiresHomeFriendly = _hasAny(text, [
      'home',
      'no equipment',
      'bodyweight',
      'small space',
    ]);

    String? preferredLevel;
    if (_hasAny(text, ['beginner', 'easy', 'gentle', 'recovery', 'rehab'])) {
      preferredLevel = 'beginner';
    } else if (_hasAny(text, ['intermediate'])) {
      preferredLevel = 'intermediate';
    } else if (_hasAny(text, ['advanced', 'hard', 'intense'])) {
      preferredLevel = 'expert';
    }

    final tokens = text
        .split(RegExp(r'[^a-z0-9]+'))
        .where((token) => token.length >= 3)
        .toSet()
        .toList();

    final detectedNeeds = <String>[
      ...requestedBodyParts.map(_labelize),
      ...requestedTypes.map(_labelize),
      if (requiresHomeFriendly) 'home workout',
      if (needsLowImpact) 'low impact',
    ];

    var resultLimit = 6;
    final durationMatch = RegExp(
      r'(\d+)\s*(min|mins|minutes)',
    ).firstMatch(text);
    if (durationMatch != null) {
      final minutes = int.tryParse(durationMatch.group(1) ?? '');
      if (minutes != null && minutes <= 15) {
        resultLimit = 4;
      } else if (minutes != null && minutes >= 45) {
        resultLimit = 8;
      }
    }

    return _PromptProfile(
      requestedBodyParts: requestedBodyParts,
      requestedTypes: requestedTypes,
      requiredEquipment: requiredEquipment,
      promptKeywords: tokens,
      detectedNeeds: detectedNeeds.toSet().toList(),
      requiresHomeFriendly: requiresHomeFriendly,
      isGentleRequest: isGentleRequest,
      needsLowImpact: needsLowImpact,
      preferredLevel: preferredLevel,
      resultLimit: resultLimit,
    );
  }

  static bool _hasAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  static String _labelize(String value) {
    return value
        .split(' ')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}
