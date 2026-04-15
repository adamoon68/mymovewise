import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymovewiseapp/myconfig.dart';
import 'package:mymovewiseapp/user.dart';

class AdminUserManagementPage extends StatefulWidget {
  final User adminUser;

  const AdminUserManagementPage({super.key, required this.adminUser});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _allUsers = [];
  List<User> _displayUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${MyConfig.baseUrl}/mymovewise/backend/get_users.php"),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to load users");
      }

      final decoded = jsonDecode(response.body);
      if (decoded['status'] != 'success' || decoded['data'] is! List) {
        throw Exception("Invalid response");
      }

      final users =
          (decoded['data'] as List).map((item) => User.fromJson(item)).toList()
            ..sort(
              (a, b) => (a.name ?? '').toLowerCase().compareTo(
                (b.name ?? '').toLowerCase(),
              ),
            );

      if (!mounted) return;
      setState(() {
        _allUsers = users;
        _displayUsers = users;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to load user profiles.")),
      );
    }
  }

  void _filterUsers(String query) {
    final trimmed = query.trim().toLowerCase();
    final results = trimmed.isEmpty
        ? List<User>.from(_allUsers)
        : _allUsers.where((user) {
            final haystack = [
              user.name ?? '',
              user.email ?? '',
              user.phone ?? '',
              user.chronicCondition ?? '',
            ].join(' ').toLowerCase();
            return haystack.contains(trimmed);
          }).toList();

    setState(() => _displayUsers = results);
  }

  Future<void> _confirmDelete(User user) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User Profile"),
        content: Text(
          "Delete ${user.name ?? 'this user'} and their workout history? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.baseUrl}/mymovewise/backend/delete_user.php"),
        body: {"user_id": user.id, "admin_id": widget.adminUser.id},
      );

      if (response.statusCode != 200) {
        throw Exception("Delete failed");
      }

      final decoded = jsonDecode(response.body);
      if (decoded['status'] != 'success') {
        throw Exception(decoded['message'] ?? 'Delete failed');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${user.name ?? 'User'} deleted.")),
      );
      _loadUsers();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to delete the selected user.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Manage User Profiles"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blueAccent,
            child: TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                hintText: "Search users by name, email, phone...",
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayUsers.isEmpty
                ? const Center(child: Text("No user profiles found."))
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _displayUsers.length,
                      itemBuilder: (context, index) {
                        final user = _displayUsers[index];
                        final isAdmin = user.role == 'admin';
                        final isCurrentAdmin = user.id == widget.adminUser.id;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: isAdmin
                                  ? Colors.orange.withValues(alpha: 0.15)
                                  : Colors.blueAccent.withValues(alpha: 0.15),
                              child: Icon(
                                isAdmin
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                color: isAdmin
                                    ? Colors.orange
                                    : Colors.blueAccent,
                              ),
                            ),
                            title: Text(
                              user.name ?? 'User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${user.email ?? '-'}\nCondition: ${user.chronicCondition?.isEmpty == false ? user.chronicCondition : 'None'}",
                            ),
                            isThreeLine: true,
                            trailing: isAdmin
                                ? Chip(
                                    label: Text(
                                      isCurrentAdmin ? "You" : "Admin",
                                    ),
                                    backgroundColor: Colors.orange.withValues(
                                      alpha: 0.12,
                                    ),
                                  )
                                : IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmDelete(user),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
