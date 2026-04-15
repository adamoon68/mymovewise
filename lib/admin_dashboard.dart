import 'package:flutter/material.dart';
import 'package:mymovewiseapp/admin_user_management_page.dart';
import 'package:mymovewiseapp/exercise_data_service.dart';
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
  List<Map<String, String>> _allExerciseMaps = [];
  List<Map<String, String>> _displayList = [];
  TextEditingController searchController = TextEditingController();
  String _selectedLetter = 'All';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  void loadCsvData() async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    try {
      final initialList = await ExerciseDataService.loadExercises(
        sortAlphabetically: true,
      );
      if (!mounted) return;
      setState(() {
        _allExerciseMaps = initialList;
        isLoading = false;
      });
      _applyFilters(query: searchController.text, letter: _selectedLetter);
    } catch (e) {
      print("Error loading CSV in Admin: $e");
      setState(() => isLoading = false);
    }
  }

  void filterSearch(String query) {
    _applyFilters(query: query, letter: _selectedLetter);
  }

  void _applyFilters({String? query, String? letter}) {
    final activeQuery = query ?? searchController.text;
    final activeLetter = letter ?? _selectedLetter;

    final results = _allExerciseMaps.where((item) {
      final name = item['name'] ?? '';
      final matchesQuery =
          activeQuery.isEmpty ||
          name.toLowerCase().contains(activeQuery.toLowerCase());
      final matchesLetter =
          activeLetter == 'All' || name.toUpperCase().startsWith(activeLetter);
      return matchesQuery && matchesLetter;
    }).toList();

    setState(() {
      _selectedLetter = activeLetter;
      _displayList = results;
    });
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
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // --- Search Bar ---
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

          SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              children: [
                _buildLetterChip('All'),
                ...List.generate(
                  26,
                  (index) => _buildLetterChip(String.fromCharCode(65 + index)),
                ),
              ],
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[100],
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
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
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminExerciseDetailPage(
                                  exercise: _displayList[index],
                                ),
                              ),
                            ).then((_) => loadCsvData());
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

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Colors.blueAccent),
            accountName: Text(
              widget.user.name ?? "Admin",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(widget.user.email ?? ""),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                color: Colors.blueAccent,
                size: 38,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people_alt, color: Colors.blueAccent),
            title: const Text("Manage User Profiles"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AdminUserManagementPage(adminUser: widget.user),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.blueAccent),
            title: const Text("Refresh Workouts"),
            onTap: () {
              Navigator.pop(context);
              loadCsvData();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLetterChip(String letter) {
    final isSelected = _selectedLetter == letter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(letter),
        selected: isSelected,
        onSelected: (_) => _applyFilters(letter: letter),
        selectedColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        side: const BorderSide(color: Colors.white),
        labelStyle: TextStyle(
          color: isSelected ? Colors.blueAccent : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
