import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/data/datasource/api_client.dart';
import 'package:local_govt_mw/client/api_constants.dart';
import 'package:local_govt_mw/features/profile/screens/help_center_screen.dart';
import 'package:local_govt_mw/routes/app_routes.dart';

class LinkExistingAccountScreen extends StatefulWidget {
  const LinkExistingAccountScreen({super.key});

  @override
  State<LinkExistingAccountScreen> createState() =>
      _LinkExistingAccountScreenState();
}

class _LinkExistingAccountScreenState extends State<LinkExistingAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();

  String selectedCountryCode = '+265';
  bool isAgreed = false;
  bool isSubmitting = false;

  final Color primaryColor = const Color(0xFF153871);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text(
          'Link your existing account',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please provide your details to link your existing investment account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),

                _inputLabel('First name'),
                _textField(
                  controller: firstNameController,
                  hint: 'Enter your first name',
                  icon: Icons.person_outline,
                ),

                _inputLabel('Surname'),
                _textField(
                  controller: surnameController,
                  hint: 'Enter your surname',
                  icon: Icons.person_outline,
                ),

                _inputLabel('Email address'),
                _textField(
                  controller: emailController,
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                _inputLabel('Phone number'),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCountryCode,
                          items: ['+265', '+1', '+44', '+91']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              selectedCountryCode = val!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _textField(
                        controller: phoneNumberController,
                        hint: 'Phone number',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),

                _inputLabel('National ID'),
                _textField(
                  controller: nationalIdController,
                  hint: 'Enter your national ID',
                  icon: Icons.badge_outlined,
                ),

                _inputLabel('Client Code'),
                _textField(
                  controller: accountNumberController,
                  hint: 'Enter your client code',
                  icon: Icons.confirmation_number_outlined,
                ),

                const SizedBox(height: 16),

                InkWell(
                  onTap: () {
                    setState(() {
                      isAgreed = !isAgreed;
                    });
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: isAgreed,
                        activeColor: primaryColor,
                        onChanged: (val) {
                          setState(() {
                            isAgreed = val ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'I confirm that the information provided is accurate and I agree to the ',
                                ),
                                TextSpan(
                                  text: 'User Agreement and Privacy Policy',
                                  style: const TextStyle(
                                    color: Color(0xFF153871),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(() => HelpCenterScreen());
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Submit request',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ----------------------------
  /// SUBMIT LOGIC
  /// ----------------------------
  Future<void> _submit() async {
  if (!(_formKey.currentState?.validate() ?? false) || !isAgreed) {
    Get.snackbar(
      'Missing information',
      'Please complete all fields and agree to the terms.',
      snackPosition: SnackPosition.BOTTOM,
    );
    return;
  }

  setState(() => isSubmitting = true);

  try {
    final api = ApiClient();
    final payload = {
      'firstname': firstNameController.text.trim(),
      'surname': surnameController.text.trim(),
      'email': emailController.text.trim(),
      'account': accountNumberController.text.trim(),
      'Nat_id_number': nationalIdController.text.trim(),
      'phone': '$selectedCountryCode${phoneNumberController.text.trim()}',
    };

    final response = await api.post(ApiConstants.createAccount, payload);

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(
        response.body is Map && response.body['message'] != null
            ? response.body['message']
            : 'Submission failed',
      );
    }

    /// ✅ SUCCESS TOAST
    Get.snackbar(
      'Request Submitted',
      'Your request has been submitted successfully.\n'
      'You will receive an email after account verification in 48hours to activate your account and set your password.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );

    /// ⏳ Delay then redirect
    await Future.delayed(const Duration(seconds: 3));
    Get.offAllNamed(AppRoutes.loginScreen);
  } catch (e) {
    Get.snackbar(
      'Error',
      e.toString(),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  } finally {
    setState(() => isSubmitting = false);
  }
}

  /// ----------------------------
  /// UI HELPERS
  /// ----------------------------
  Widget _inputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) =>
              value == null || value.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
    );
  }
}
