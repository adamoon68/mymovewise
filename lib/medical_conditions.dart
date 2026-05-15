class MedicalConditionOption {
  final String name;
  final String description;
  final List<String> avoidTypes;
  final List<String> avoidBodyParts;
  final List<String> avoidKeywords;
  final List<String> preferredTypes;

  const MedicalConditionOption({
    required this.name,
    required this.description,
    this.avoidTypes = const [],
    this.avoidBodyParts = const [],
    this.avoidKeywords = const [],
    this.preferredTypes = const [],
  });

  bool get isNone => name.toLowerCase() == 'none';
}

class MedicalConditionCatalog {
  static const List<MedicalConditionOption> options = [
    MedicalConditionOption(
      name: 'None',
      description:
          'No known condition selected. MoveWise will still prioritize balanced and beginner-friendly suggestions when your prompt sounds cautious.',
    ),
    MedicalConditionOption(
      name: 'Osteoarthritis',
      description:
          'Osteoarthritis is joint wear-and-tear that often causes stiffness and pain, especially during high-impact or repetitive loading.',
      avoidTypes: ['Plyometrics', 'Olympic Weightlifting', 'Strongman'],
      avoidKeywords: ['jump', 'explosive', 'impact', 'sprint'],
      preferredTypes: ['Stretching', 'Cardio', 'Strength'],
    ),
    MedicalConditionOption(
      name: 'Rheumatoid Arthritis',
      description:
          'Rheumatoid arthritis is an inflammatory joint condition that may flare unpredictably, so workouts should stay low-impact and easy to scale.',
      avoidTypes: ['Plyometrics', 'Olympic Weightlifting', 'Strongman'],
      avoidKeywords: ['jump', 'explosive', 'impact', 'max effort'],
      preferredTypes: ['Stretching', 'Cardio'],
    ),
    MedicalConditionOption(
      name: 'Knee Arthritis',
      description:
          'Knee arthritis can make deep knee bending, jumping, and repetitive impact uncomfortable, so exercise choice should protect the joints.',
      avoidTypes: ['Plyometrics'],
      avoidKeywords: ['jump', 'lunge', 'deep squat', 'bounding', 'sprint'],
      preferredTypes: ['Stretching', 'Strength'],
    ),
    MedicalConditionOption(
      name: 'Slip Disc',
      description:
          'A slip disc or herniated disc may be aggravated by heavy spinal loading, twisting, and repeated bending under tension.',
      avoidTypes: ['Olympic Weightlifting', 'Powerlifting', 'Strongman'],
      avoidBodyParts: ['Lower Back'],
      avoidKeywords: [
        'twist',
        'rotation',
        'sit-up',
        'crunch',
        'deadlift',
        'good morning',
        'swing',
      ],
      preferredTypes: ['Stretching'],
    ),
    MedicalConditionOption(
      name: 'Sciatica',
      description:
          'Sciatica can cause radiating pain from the lower back into the leg, so low-impact movements with minimal spinal irritation are safer.',
      avoidTypes: ['Plyometrics', 'Olympic Weightlifting'],
      avoidBodyParts: ['Lower Back'],
      avoidKeywords: ['jump', 'twist', 'deadlift', 'sprint', 'swing'],
      preferredTypes: ['Stretching', 'Cardio'],
    ),
    MedicalConditionOption(
      name: 'Osteoporosis',
      description:
          'Osteoporosis weakens bone density, so workouts should avoid forceful twisting, high impact, and risky loaded spinal flexion.',
      avoidTypes: ['Plyometrics', 'Olympic Weightlifting', 'Strongman'],
      avoidKeywords: ['jump', 'twist', 'crunch', 'sit-up', 'impact'],
      preferredTypes: ['Strength', 'Stretching'],
    ),
    MedicalConditionOption(
      name: 'Asthma',
      description:
          'Asthma can limit breathing tolerance during intense efforts, so steady pacing, warm-ups, and manageable cardio intervals are important.',
      avoidKeywords: ['all-out sprint', 'max effort', 'burpee test'],
      preferredTypes: ['Cardio', 'Stretching', 'Strength'],
    ),
    MedicalConditionOption(
      name: 'Hypertension',
      description:
          'Hypertension means blood pressure may rise too much during intense straining, so avoid all-out efforts and very heavy lifts.',
      avoidTypes: ['Powerlifting', 'Strongman', 'Olympic Weightlifting'],
      avoidKeywords: ['max effort', 'heavy', 'all-out'],
      preferredTypes: ['Cardio', 'Stretching'],
    ),
    MedicalConditionOption(
      name: 'Type 2 Diabetes',
      description:
          'Type 2 diabetes often benefits from regular aerobic and resistance exercise, with steady intensity and consistency over extreme effort.',
      preferredTypes: ['Cardio', 'Strength'],
    ),
    MedicalConditionOption(
      name: 'Shoulder Impingement',
      description:
          'Shoulder impingement can be irritated by repeated overhead pressing and unstable shoulder positions, so exercise choice should protect range of motion.',
      avoidBodyParts: ['Shoulders'],
      avoidKeywords: ['overhead', 'upright row', 'snatch', 'jerk'],
      preferredTypes: ['Stretching', 'Strength'],
    ),
  ];

  static MedicalConditionOption findByName(String? name) {
    final normalized = normalize(name);
    return options.firstWhere(
      (option) => normalize(option.name) == normalized,
      orElse: () => options.first,
    );
  }

  static String normalize(String? value) {
    final text = (value ?? '').trim().toLowerCase();
    return text.isEmpty ? 'none' : text;
  }
}
