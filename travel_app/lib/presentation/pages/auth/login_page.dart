import 'package:flutter/material.dart';
import 'package:travel_app/routes/app_routes.dart';
import 'package:travel_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('Username dan password tidak boleh kosong');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(username, password);
      print("Login result: $result");

      if (result is Map && result['user'] is Map && result['token'] != null) {
        final userData = result['user'] as Map;
        final String token = result['token'].toString();
        final String role = userData['role'].toString();

        print("Detected role: $role");
        print("User data: $userData");

        // ✅ Gunakan method saveUserSession yang sudah ada di AuthService
        // Ini akan memastikan semua data tersimpan dengan konsisten
        await AuthService.saveUserSession(userData, token);
        final prefz = await SharedPreferences.getInstance();
        prefz.setString('userName', userData['name'].toString());

        final prefs = await SharedPreferences.getInstance();
        final savedUserId = prefs.getInt('userId');
        final savedToken = prefs.getString('token');

        print("✅ Verification after save:");
        print("- Saved userId: $savedUserId");
        print("- Saved token: ${savedToken?.substring(0, 20)}...");

        // ✅ Pastikan userId tersimpan sebelum navigasi
        if (savedUserId == null) {
          _showError('Gagal menyimpan data pengguna');
          return;
        }

        if (role == 'ADMIN') {
          Navigator.pushReplacementNamed(context, AppRoutes.adminTicket);
        } else if (role == 'USER') {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.homeUser,
            arguments: userData, // Pass userData as arguments
          );
        } else {
          _showError('Peran tidak dikenali');
        }
      } else {
        _showError('Format respons tidak sesuai');
        print("❌ Invalid response format: $result");
      }
    } catch (e) {
      print("❌ Login error: $e");
      _showError('Gagal login: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Login Now",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Please log in to continue our app",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: "Username",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Forgot password logic
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Color(0xFF1A4D8F)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A4D8F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: "Doesn't have an account? ",
                      style: TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF1A4D8F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
