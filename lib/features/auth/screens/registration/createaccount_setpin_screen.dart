import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/routes/app_routes.dart';

class SetUpPinScreen extends StatefulWidget {
  const SetUpPinScreen({super.key});

  @override
  State<SetUpPinScreen> createState() => _SetUpPinScreenState();
}

class _SetUpPinScreenState extends State<SetUpPinScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();
  bool _passwordVisible = false;
  bool _rePasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FA),
        title: const Text('Set up 2-step verification'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Help screen navigation
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              const Text(
                "Enter your phone number so we can text you an authentication code",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              // Password Field
              const Text(
                "Password",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Re-enter Password Field
              const Text(
                "Re-enter Your Password",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: rePasswordController,
                obscureText: !_rePasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Re-enter your password',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _rePasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _rePasswordVisible = !_rePasswordVisible;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (passwordController.text == rePasswordController.text) {
                      // Navigate to the Login screen
                      Get.toNamed(AppRoutes.loginScreen); // Changed this line to redirect to LoginScreen
                    } else {
                      // Show error
                      Get.snackbar('Error', 'Passwords do not match!');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF153871),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
