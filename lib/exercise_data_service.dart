import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:mymovewiseapp/myconfig.dart';

class ExerciseDataService {
  static Future<List<Map<String, String>>> loadExercises({
    bool sortAlphabetically = true,
  }) async {
    final rawData = await rootBundle.loadString("assets/megaGymDataset.csv");
    final csvTable = const CsvToListConverter().convert(
      rawData,
      eol: '\n',
      shouldParseNumbers: false,
    );

    final deletedNames = await _fetchDeletedExerciseNames();
    final exercises = <Map<String, String>>[];

    for (var i = 1; i < csvTable.length; i++) {
      final row = csvTable[i];
      if (row.length < 7) continue;

      final name = row[1].toString().trim();
      if (name.isEmpty || deletedNames.contains(name.toLowerCase())) {
        continue;
      }

      exercises.add({
        "name": name,
        "desc": row[2].toString(),
        "type": row[3].toString(),
        "bodyPart": row[4].toString(),
        "equipment": row[5].toString(),
        "level": row[6].toString(),
      });
    }

    if (sortAlphabetically) {
      exercises.sort(
        (a, b) => a['name']!.toLowerCase().compareTo(b['name']!.toLowerCase()),
      );
    }

    return exercises;
  }

  static Future<Set<String>> _fetchDeletedExerciseNames() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${MyConfig.baseUrl}/mymovewise/backend/get_deleted_exercises.php",
        ),
      );

      if (response.statusCode != 200) {
        return <String>{};
      }

      final decoded = jsonDecode(response.body);
      if (decoded['status'] != 'success' || decoded['data'] is! List) {
        return <String>{};
      }

      return (decoded['data'] as List)
          .map((item) => item.toString().toLowerCase())
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }
}
