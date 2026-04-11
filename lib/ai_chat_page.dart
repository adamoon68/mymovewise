import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mymovewiseapp/ai_service.dart';
import 'package:mymovewiseapp/exercise_detail_page.dart';
import 'package:mymovewiseapp/user.dart';

class AIChatPage extends StatefulWidget {
  final User user;

  const AIChatPage({super.key, required this.user});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final AIService _aiService = AIService();
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  final List<_ChatMessage> _messages = [];
  final List<Map<String, String>> _allExercises = [];
  List<Map<String, String>> _filteredExercises = [];

  bool _isAiLoading = false;
  bool _isSearchLoading = true;

  @override
  void initState() {
    super.initState();
    _messages.add(
      const _ChatMessage(
        sender: _MessageSender.ai,
        text:
            "Hi! I can help with workout recommendations, recovery-friendly ideas, and exercise suggestions. Ask me anything.",
      ),
    );
    _loadExercises();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    try {
      final rawData = await rootBundle.loadString("assets/megaGymDataset.csv");
      final csvTable = const CsvToListConverter().convert(
        rawData,
        eol: '\n',
        shouldParseNumbers: false,
      );

      final exercises = <Map<String, String>>[];
      for (var i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        exercises.add({
          "name": row[1].toString(),
          "desc": row[2].toString(),
          "type": row[3].toString(),
          "bodyPart": row[4].toString(),
          "equipment": row[5].toString(),
          "level": row[6].toString(),
        });
      }

      if (!mounted) return;
      setState(() {
        _allExercises
          ..clear()
          ..addAll(exercises);
        _filteredExercises = List<Map<String, String>>.from(exercises.take(12));
        _isSearchLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearchLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final prompt = _chatController.text.trim();
    if (prompt.isEmpty || _isAiLoading) return;

    setState(() {
      _messages.add(_ChatMessage(sender: _MessageSender.user, text: prompt));
      _isAiLoading = true;
    });
    _chatController.clear();

    final result = await _aiService.getRecommendation(prompt);

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(sender: _MessageSender.ai, text: result));
      _isAiLoading = false;
    });
  }

  void _filterExercises(String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      setState(() {
        _filteredExercises = List<Map<String, String>>.from(
          _allExercises.take(12),
        );
      });
      return;
    }

    final matches = _allExercises
        .where((exercise) {
          final haystack = [
            exercise["name"],
            exercise["type"],
            exercise["bodyPart"],
            exercise["equipment"],
            exercise["level"],
          ].whereType<String>().join(" ").toLowerCase();
          return haystack.contains(trimmed);
        })
        .take(20)
        .toList();

    setState(() {
      _filteredExercises = matches;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Chat with MoveWise AI"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
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
                  "Ask for workouts, recovery tips, or a quick routine, ${widget.user.name?.split(' ').first ?? 'User'}.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You can also search exercises below and open the workout details page directly.",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChatCard(),
                  const SizedBox(height: 20),
                  _buildSearchCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.smart_toy, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text(
                "MoveWise AI Chat",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            constraints: const BoxConstraints(minHeight: 180, maxHeight: 320),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _messages.length + (_isAiLoading ? 1 : 0),
              separatorBuilder: (_, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (_isAiLoading && index == _messages.length) {
                  return _buildTypingBubble();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _chatController,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendMessage(),
            decoration: InputDecoration(
              hintText:
                  "Ask for a beginner leg day, home workout, recovery plan...",
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.blueAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.search, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text(
                "Search Workouts",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Find exercises by name, body part, type, equipment, or level.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: _filterExercises,
            decoration: InputDecoration(
              hintText: "Search workouts...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_isSearchLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_filteredExercises.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "No workouts matched your search yet.",
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            ListView.builder(
              itemCount: _filteredExercises.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final exercise = _filteredExercises[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.blueAccent,
                      ),
                    ),
                    title: Text(
                      exercise["name"] ?? "Workout",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(exercise["type"] ?? "General"),
                          _buildInfoChip(exercise["bodyPart"] ?? "Full Body"),
                          _buildInfoChip(exercise["level"] ?? "All Levels"),
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
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isUser = message.sender == _MessageSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isUser ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
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

enum _MessageSender { user, ai }

class _ChatMessage {
  final _MessageSender sender;
  final String text;

  const _ChatMessage({required this.sender, required this.text});
}
