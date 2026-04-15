import 'package:flutter/material.dart';
import 'package:mymovewiseapp/user.dart';

class WellnessQuestPage extends StatefulWidget {
  final User user;

  const WellnessQuestPage({super.key, required this.user});

  @override
  State<WellnessQuestPage> createState() => _WellnessQuestPageState();
}

class _WellnessQuestPageState extends State<WellnessQuestPage> {
  late final List<_QuestItem> _quests;
  int _bonusIndex = 0;

  @override
  void initState() {
    super.initState();
    _quests = _buildQuests();
  }

  List<_QuestItem> _buildQuests() {
    final condition = (widget.user.chronicCondition ?? 'None').toLowerCase();

    if (condition.contains('asthma')) {
      return [
        _QuestItem(
          title: "Breathe Easy Reset",
          subtitle: "Try 2 minutes of calm nose breathing at your own pace.",
          icon: Icons.air,
          points: 15,
        ),
        _QuestItem(
          title: "Gentle Warm-Up",
          subtitle: "Do 5 shoulder rolls and 5 ankle circles per side.",
          icon: Icons.self_improvement,
          points: 10,
        ),
        _QuestItem(
          title: "Hydration Check",
          subtitle: "Take a few sips of water before your next movement set.",
          icon: Icons.water_drop,
          points: 10,
        ),
        _QuestItem(
          title: "Comfort Walk",
          subtitle:
              "Walk slowly for 3 minutes and stop if breathing feels off.",
          icon: Icons.directions_walk,
          points: 20,
        ),
      ];
    }

    if (condition.contains('arthritis') || condition.contains('joint')) {
      return [
        _QuestItem(
          title: "Joint Wake-Up",
          subtitle: "Do easy wrist, shoulder, and ankle circles for 2 minutes.",
          icon: Icons.sync,
          points: 15,
        ),
        _QuestItem(
          title: "Posture Pause",
          subtitle:
              "Sit tall, relax your shoulders, and breathe slowly for 1 minute.",
          icon: Icons.accessibility_new,
          points: 10,
        ),
        _QuestItem(
          title: "Mini Mobility",
          subtitle:
              "Pick one pain-free stretch and hold it gently for 20 seconds.",
          icon: Icons.fitness_center,
          points: 15,
        ),
        _QuestItem(
          title: "Recovery Reward",
          subtitle: "Finish with a warm drink or a short rest break.",
          icon: Icons.local_cafe,
          points: 10,
        ),
      ];
    }

    return [
      _QuestItem(
        title: "Mood Boost Breath",
        subtitle: "Take 5 slow breaths and let your shoulders drop.",
        icon: Icons.spa,
        points: 10,
      ),
      _QuestItem(
        title: "Desk Reset",
        subtitle: "Stand up and stretch your arms overhead for 20 seconds.",
        icon: Icons.chair_alt,
        points: 10,
      ),
      _QuestItem(
        title: "Water Win",
        subtitle: "Drink some water before your workout or recovery session.",
        icon: Icons.water_drop,
        points: 10,
      ),
      _QuestItem(
        title: "Move Break",
        subtitle: "Do a gentle 3-minute walk around your space.",
        icon: Icons.directions_walk,
        points: 20,
      ),
    ];
  }

  List<String> get _bonusCards {
    final condition = widget.user.chronicCondition?.trim().isNotEmpty == true
        ? widget.user.chronicCondition!
        : "None";

    return [
      "Bonus card: play your favorite song and do a calm stretch during the chorus.",
      "Bonus card: rate your energy from 1 to 5 and choose the gentlest option that still feels good.",
      "Bonus card: if $condition affects you today, cut your session in half and count that as a win.",
      "Bonus card: message yourself one small health win from today after you finish a quest.",
    ];
  }

  int get _completedCount => _quests.where((quest) => quest.isDone).length;

  int get _totalPoints => _quests
      .where((quest) => quest.isDone)
      .fold(0, (sum, quest) => sum + quest.points);

  @override
  Widget build(BuildContext context) {
    final progress = _quests.isEmpty ? 0.0 : _completedCount / _quests.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4ED),
      appBar: AppBar(
        title: const Text("Daily Comfort Quest"),
        backgroundColor: const Color(0xFF1E6F5C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: Color(0xFF1E6F5C),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Small wins for ${widget.user.name?.split(' ').first ?? 'you'}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Made to stay gentle, low-pressure, and easier to enjoy with health conditions in mind.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Progress: $_completedCount/${_quests.length} quests",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.2,
                            ),
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFF2C14E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Comfort points: $_totalPoints",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConditionBanner(),
                  const SizedBox(height: 18),
                  const Text(
                    "Today's Quests",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._quests.map(_buildQuestCard),
                  const SizedBox(height: 18),
                  _buildBonusCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionBanner() {
    final condition = widget.user.chronicCondition?.trim().isNotEmpty == true
        ? widget.user.chronicCondition!
        : "None";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3B23C)),
      ),
      child: Row(
        children: [
          const Icon(Icons.health_and_safety, color: Color(0xFFE3B23C)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Current condition setting: $condition. Keep everything pain-free and stop if anything feels unsafe.",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B4A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(_QuestItem quest) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CheckboxListTile(
        value: quest.isDone,
        onChanged: (value) {
          setState(() => quest.isDone = value ?? false);
        },
        controlAffinity: ListTileControlAffinity.trailing,
        secondary: CircleAvatar(
          backgroundColor: const Color(0xFF1E6F5C).withValues(alpha: 0.12),
          child: Icon(quest.icon, color: const Color(0xFF1E6F5C)),
        ),
        title: Text(
          quest.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text("${quest.subtitle}\n+${quest.points} comfort points"),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _buildBonusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3F0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Feel-Good Bonus",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _bonusCards[_bonusIndex],
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _bonusIndex = (_bonusIndex + 1) % _bonusCards.length;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E6F5C),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.casino_outlined),
            label: const Text("Show Another Bonus"),
          ),
        ],
      ),
    );
  }
}

class _QuestItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final int points;
  bool isDone = false;

  _QuestItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.points,
  });
}
