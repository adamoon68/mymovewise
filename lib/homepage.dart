import 'package:flutter/material.dart';
import 'package:mymovewiseapp/user.dart';
import 'package:mymovewiseapp/loginpage.dart';
import 'package:mymovewiseapp/workout_plan_page.dart';
import 'package:mymovewiseapp/history_page.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedEnergy = "Medium";
  String selectedTime = "30 mins";
  String selectedEquipment = "None";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Wellness Check")),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.user.name ?? "User"),
              accountEmail: Text(widget.user.email ?? ""),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.brown),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Workout History"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HistoryPage(user: widget.user),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "How are you feeling today?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField(
                      value: selectedEnergy,
                      items: ["Low", "Medium", "High"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedEnergy = v as String),
                      decoration: const InputDecoration(
                        labelText: "Energy",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      value: selectedTime,
                      items: ["15 mins", "30 mins", "45 mins", "60 mins"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedTime = v as String),
                      decoration: const InputDecoration(
                        labelText: "Time",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField(
                      value: selectedEquipment,
                      items: ["None", "Dumbbells", "Full Gym"]
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => selectedEquipment = v as String),
                      decoration: const InputDecoration(
                        labelText: "Equipment",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // FUNCTIONAL BUTTON: Navigates to Logic Engine
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutPlanPage(
                                user: widget.user,
                                energyLevel: selectedEnergy,
                                duration: selectedTime,
                                equipment: selectedEquipment,
                              ),
                            ),
                          );
                        },
                        child: const Text("Generate Workout"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
