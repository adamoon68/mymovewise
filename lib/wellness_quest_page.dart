import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymovewiseapp/myconfig.dart';
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
  bool _isLoading = true;
  bool _isClaiming = false;
  bool _claimedToday = false;
  int _rewardWallet = 0;
  int _comfortStreak = 0;
  String? _lastQuestClaim;

  @override
  void initState() {
    super.initState();
    _quests = _buildQuests();
    _loadQuestStatus();
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

  Uri _backendUri(String fileName) {
    return Uri.parse("${MyConfig.baseUrl}${MyConfig.backend}/$fileName");
  }

  Future<Map<String, dynamic>> _postJson(
    String fileName,
    Map<String, String> body,
  ) async {
    final response = await http
        .post(_backendUri(fileName), body: body)
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("Server returned HTTP ${response.statusCode}");
    }

    final rawBody = response.body.trim();
    if (rawBody.isEmpty) {
      throw Exception("Server returned an empty response");
    }

    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw Exception("Server returned an unexpected response format");
    } on FormatException {
      throw Exception(
        "Server did not return valid JSON. Check that $fileName exists in backend/ and PHP is running.",
      );
    }
  }

  Future<void> _loadQuestStatus() async {
    try {
      final decoded = await _postJson("get_daily_quest_status.php", {
        "user_id": widget.user.id ?? "",
      });
      if (!mounted) return;

      if (decoded['status'] == 'success') {
        final data = decoded['data'] as Map<String, dynamic>;
        setState(() {
          _rewardWallet = int.tryParse(data['wellness_points'].toString()) ?? 0;
          _comfortStreak = int.tryParse(data['comfort_streak'].toString()) ?? 0;
          _lastQuestClaim = data['last_quest_claim']?.toString();
          _claimedToday = data['claimed_today'] == true;
          _isLoading = false;
        });

        widget.user.wellnessPoints = _rewardWallet;
        widget.user.comfortStreak = _comfortStreak;
        widget.user.lastQuestClaim = _lastQuestClaim;
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("Quest status load failed: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _claimReward() async {
    if (_claimedToday || !_allQuestsDone || _isClaiming) {
      return;
    }

    setState(() => _isClaiming = true);

    try {
      final decoded = await _postJson("claim_daily_quest_reward.php", {
        "user_id": widget.user.id ?? "",
        "completed_count": _completedCount.toString(),
        "total_quests": _quests.length.toString(),
      });
      if (!mounted) return;

      if (decoded['status'] == 'success') {
        final data = decoded['data'] as Map<String, dynamic>;
        final rewardEarned =
            int.tryParse(data['reward_earned'].toString()) ?? 0;

        setState(() {
          _rewardWallet = int.tryParse(data['wellness_points'].toString()) ?? 0;
          _comfortStreak = int.tryParse(data['comfort_streak'].toString()) ?? 0;
          _lastQuestClaim = data['last_quest_claim']?.toString();
          _claimedToday = data['claimed_today'] == true;
        });

        widget.user.wellnessPoints = _rewardWallet;
        widget.user.comfortStreak = _comfortStreak;
        widget.user.lastQuestClaim = _lastQuestClaim;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Reward claimed: +$rewardEarned MoveWise points. Streak is now $_comfortStreak day${_comfortStreak == 1 ? '' : 's'}.",
            ),
            backgroundColor: const Color(0xFF1E6F5C),
          ),
        );
      } else {
        final message =
            decoded['message']?.toString() ?? "Unable to claim reward.";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst("Exception: ", ""))),
      );
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
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

  int get _questPoints => _quests
      .where((quest) => quest.isDone)
      .fold(0, (sum, quest) => sum + quest.points);

  bool get _allQuestsDone => _completedCount == _quests.length;

  int get _todayRewardPreview {
    final nextStreak = _claimedToday
        ? _comfortStreak
        : (_isYesterday(_lastQuestClaim) ? _comfortStreak + 1 : 1);
    return 40 + ((nextStreak - 1) * 5).clamp(0, 30);
  }

  bool _isYesterday(String? value) {
    if (value == null || value.isEmpty) return false;

    final lastDate = DateTime.tryParse(value);
    if (lastDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final normalizedLastDate = DateTime(
      lastDate.year,
      lastDate.month,
      lastDate.day,
    );
    return today.difference(normalizedLastDate).inDays == 1;
  }

  String get _rewardBadge {
    if (_comfortStreak >= 14) return "Gold";
    if (_comfortStreak >= 7) return "Silver";
    if (_comfortStreak >= 3) return "Bronze";
    return "Starter";
  }

  @override
  Widget build(BuildContext context) {
    final progress = _quests.isEmpty ? 0.0 : _completedCount / _quests.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4ED),
      appBar: AppBar(
        title: const Text("Daily Reward Quest"),
        backgroundColor: const Color(0xFF1E6F5C),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          "Earn rewards with gentle wins",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Complete every quest, then claim today's reward to grow your streak and your MoveWise points.",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildRewardSummary(progress),
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
                        _buildRewardCard(),
                        const SizedBox(height: 18),
                        const Text(
                          "Today's Quests",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildRewardSummary(double progress) {
    return Container(
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
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF2C14E)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Quest effort points today: $_questPoints",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _claimedToday
                ? "Today's reward already claimed."
                : "Finish all quests to unlock +$_todayRewardPreview MoveWise points.",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 14,
            ),
          ),
        ],
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

  Widget _buildRewardCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Daily Reward",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  icon: Icons.stars_rounded,
                  label: "Wallet",
                  value: "$_rewardWallet pts",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatChip(
                  icon: Icons.local_fire_department,
                  label: "Streak",
                  value: "$_comfortStreak day${_comfortStreak == 1 ? '' : 's'}",
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatChip(
                  icon: Icons.workspace_premium,
                  label: "Badge",
                  value: _rewardBadge,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatChip(
                  icon: Icons.card_giftcard,
                  label: "Today",
                  value: _claimedToday
                      ? "Claimed"
                      : "+$_todayRewardPreview pts",
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _claimedToday || !_allQuestsDone || _isClaiming
                  ? null
                  : _claimReward,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E6F5C),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: _isClaiming
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.redeem),
              label: Text(
                _claimedToday
                    ? "Reward Claimed Today"
                    : _allQuestsDone
                    ? "Claim Daily Reward"
                    : "Complete All Quests To Claim",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E6F5C)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
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
        onChanged: _claimedToday
            ? null
            : (value) {
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
          child: Text("${quest.subtitle}\n+${quest.points} effort points"),
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
