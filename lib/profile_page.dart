import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymovewiseapp/user.dart';
import 'package:mymovewiseapp/myconfig.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController conditionController;
  late TextEditingController passwordController;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    phoneController = TextEditingController(text: widget.user.phone);
    conditionController = TextEditingController(text: widget.user.chronicCondition);
    passwordController = TextEditingController(); // Empty default (don't show old pass)
  }

  void saveProfile() {
    http.post(
      Uri.parse("${MyConfig.baseUrl}/mymovewise/backend/update_profile.php"),
      body: {
        "user_id": widget.user.id,
        "name": nameController.text,
        "phone": phoneController.text,
        "chronic_condition": conditionController.text,
        "password": passwordController.text, // Sends empty if not changed
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['status'] == 'success') {
          setState(() {
            // Update local user object so changes reflect immediately
            widget.user.name = nameController.text;
            widget.user.phone = phoneController.text;
            widget.user.chronicCondition = conditionController.text;
            isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated Successfully!"), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Update Failed")));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                if (isEditing) {
                  // Cancel edits: revert to original
                  nameController.text = widget.user.name ?? "";
                  phoneController.text = widget.user.phone ?? "";
                  conditionController.text = widget.user.chronicCondition ?? "None";
                }
                isEditing = !isEditing;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.user.name ?? "User",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    widget.user.email ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- INFO FORM ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildField("Full Name", nameController, Icons.person, isEditing),
                    const Divider(),
                    _buildField("Phone", phoneController, Icons.phone, isEditing),
                    const Divider(),
                    
                    // Special Section for Condition
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.health_and_safety, color: Colors.blueAccent, size: 20),
                              const SizedBox(width: 10),
                              Text("Chronic Condition", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          isEditing
                              ? TextField(
                                  controller: conditionController,
                                  decoration: const InputDecoration(
                                    hintText: "e.g., Asthma, Back Pain, None",
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                )
                              : Text(
                                  widget.user.chronicCondition ?? "None",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                          const SizedBox(height: 5),
                          if (isEditing)
                             const Text(
                               "Note: Setting a condition activates safety filters in workouts.",
                               style: TextStyle(fontSize: 11, color: Colors.orange),
                             ),
                        ],
                      ),
                    ),
                    const Divider(),

                    // Password Field (Only show input when editing)
                    if (isEditing) 
                      Column(
                        children: [
                          _buildField("New Password (Optional)", passwordController, Icons.lock, true),
                          const SizedBox(height: 20),
                        ],
                      ),

                    if (isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: const Text("Save Changes"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: saveProfile,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 10),
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 5),
          enabled
              ? TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Text(
                    controller.text.isEmpty ? "-" : controller.text,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
        ],
      ),
    );
  }
}