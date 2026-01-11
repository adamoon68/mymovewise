import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:mymovewiseapp/user.dart';
import 'package:mymovewiseapp/loginpage.dart';
import 'package:mymovewiseapp/admin_exercise_detail_page.dart';

class AdminDashboard extends StatefulWidget {
  final User user;
  const AdminDashboard({super.key, required this.user});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<List<dynamic>> _allExercises = [];
  List<Map<String, String>> _displayList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  void loadCsvData() async {
    try {
      final rawData = await rootBundle.loadString("assets/megaGymDataset.csv");
      List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
      _allExercises = csvTable;
      
      List<Map<String, String>> initialList = [];
      for (var i = 1; i < _allExercises.length; i++) {
        var row = _allExercises[i];
        initialList.add({
          "name": row[1].toString(),
          "desc": row[2].toString(),
          "type": row[3].toString(),
          "level": row[6].toString(),
        });
      }
      // Sort A-Z
      initialList.sort((a, b) => a['name']!.compareTo(b['name']!));

      setState(() {
        _displayList = initialList;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading CSV: $e");
      setState(() => isLoading = false);
    }
  }

  void filterSearch(String query) {
    List<Map<String, String>> results = [];
    if (query.isEmpty) {
      results = _allExercises.skip(1).map((row) => {
        "name": row[1].toString(),
        "desc": row[2].toString(),
        "type": row[3].toString(),
        "level": row[6].toString(),
      }).toList().cast<Map<String, String>>();
    } else {
      var fullList = _allExercises.skip(1).map((row) => {
        "name": row[1].toString(),
        "desc": row[2].toString(),
        "type": row[3].toString(),
        "level": row[6].toString(),
      }).toList().cast<Map<String, String>>();

      results = fullList
          .where((item) => item['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    results.sort((a, b) => a['name']!.compareTo(b['name']!));
    setState(() => _displayList = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Admin Panel"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: filterSearch,
              decoration: InputDecoration(
                hintText: "Search Database...",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          ),
          
          // --- List Content ---
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _displayList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            child: const Icon(Icons.edit, color: Colors.blueAccent),
                          ),
                          title: Text(
                            _displayList[index]['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${_displayList[index]['type']} • ${_displayList[index]['level']}",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminExerciseDetailPage(
                                  exercise: _displayList[index],
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
}