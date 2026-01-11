import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mymovewiseapp/myconfig.dart';
import 'package:mymovewiseapp/registerpage.dart';
import 'package:mymovewiseapp/homepage.dart';
import 'package:mymovewiseapp/admin_dashboard.dart';
import 'package:mymovewiseapp/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool visible = true;
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My MoveWise Login")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: 400,
              child: Column(
                children: [
                  const Icon(
                    Icons.fitness_center,
                    size: 100,
                    color: Colors.brown,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => visible = !visible),
                        icon: const Icon(Icons.visibility),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text("Remember Me"),
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() => isChecked = value!);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loginUser,
                      child: const Text("Login"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text("New to MoveWise? Register here."),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void loginUser() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    // Save Prefs if checked
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      prefs.setString("email", emailController.text);
      prefs.setString("password", passwordController.text);
      prefs.setBool("rememberMe", true);
    } else {
      prefs.clear();
    }

    try {
      var url = Uri.parse(
        "${MyConfig.baseUrl}/mymovewise/backend/login_user.php",
      );
      var response = await http.post(
        url,
        body: {
          "email": emailController.text,
          "password": passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res['status'] == 'success') {
          User user = User.fromJson(res['data']);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login Success")));

          if (user.role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AdminDashboard(user: user)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage(user: user)),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Failed. Check credentials.")),
          );
        }
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Server Error")));
    }
  }

  void loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("rememberMe") == true) {
      emailController.text = prefs.getString("email") ?? "";
      passwordController.text = prefs.getString("password") ?? "";
      setState(() => isChecked = true);
    }
  }
}
