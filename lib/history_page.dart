import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymovewiseapp/user.dart';
import 'package:mymovewiseapp/myconfig.dart';

class HistoryPage extends StatefulWidget {
  final User user;
  const HistoryPage({super.key, required this.user});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List historyLog = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() {
    http
        .post(
          Uri.parse(
            "${MyConfig.baseUrl}/mymovewise/backend/get_workout_history.php",
          ),
          body: {"user_id": widget.user.id},
        )
        .then((response) {
          if (response.statusCode == 200) {
            var res = jsonDecode(response.body);
            if (res['status'] == 'success') {
              setState(() {
                historyLog = res['data'];
              });
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: historyLog.isEmpty
          ? const Center(child: Text("No workouts completed yet."))
          : ListView.builder(
              itemCount: historyLog.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(historyLog[index]['exercise_name']),
                    subtitle: Text(historyLog[index]['date_completed']),
                  ),
                );
              },
            ),
    );
  }
}
