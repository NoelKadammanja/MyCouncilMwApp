import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/features/auth/controllers/login_controller.dart';
import 'package:local_govt_mw/routes/app_routes.dart';
import 'package:local_govt_mw/utill/validation_utils.dart';

/// ✅ Login with TOP background image (covers behind appbar/status bar)
/// - No back arrow
/// - Image header goes to the very top (behind system status bar)
/// - White card below
/// - Hides top content when keyboard is active for better input visibility
/// - Auto-scrolls to input fields when keyboard opens
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.put(LoginController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // ✅ Brand colors
  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kAccentGold = Color(0xFFF4C430);

  static const Color kTextDark = Color(0xFF111827);
  static const Color kTextMuted = Color(0xFF6B7280);
  static const Color kFieldBg = Color(0xFFF8FAFC);
  static const Color kBorder = Color(0xFFE5E7EB);

  // ✅ Header background image
  static const String kHeaderLoginImage = 'assets/images/login.png';

  // Track if keyboard is visible
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // ✅ Make status bar icons white on top of image
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark, // iOS
      statusBarIconBrightness: Brightness.light, // Android
    ));

    // Add focus listeners to detect keyboard visibility and auto-scroll
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final hasFocus = _emailFocusNode.hasFocus || _passwordFocusNode.hasFocus;
    if (_isKeyboardVisible != hasFocus) {
      setState(() {
        _isKeyboardVisible = hasFocus;
      });
    }

    // Auto-scroll when keyboard opens
    if (hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients && mounted) {
          if (_emailFocusNode.hasFocus) {
            // Small scroll for email field (optional)
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else if (_passwordFocusNode.hasFocus) {
            // Calculate exact scroll for password field
            final passwordFieldContext = _passwordFocusNode.context;
            if (passwordFieldContext != null) {
              final renderBox = passwordFieldContext.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final offset = renderBox.localToGlobal(Offset.zero);
                final media = MediaQuery.of(context);
                final keyboardHeight = media.viewInsets.bottom;
                final screenHeight = media.size.height;
                final fieldBottom = offset.dy + renderBox.size.height;

                final scrollAmount = (fieldBottom - (screenHeight - keyboardHeight)) + 20;

                if (scrollAmount > 0) {
                  _scrollController.animateTo(
                    _scrollController.offset + scrollAmount,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              }
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _scrollController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint.tr,
      hintStyle: const TextStyle(color: kTextMuted, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: kFieldBg,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      prefixIcon: Icon(icon, color: kPrimaryGreen),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimaryGreen, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  void _onLoginPressed() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      controller.login();
    }
  }

  void _showForgotPasswordDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Password Recovery",
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          "Please contact your account manager or ICT helpdesk to reset your account.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final headerHeight = media.size.height * 0.44;
    final topInset = media.padding.top;

    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(AppRoutes.onboardingScreen);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,

        // ✅ Allow the image to go behind status bar
        extendBodyBehindAppBar: true,

        body: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: Column(
            children: [
              // ✅ TOP IMAGE HEADER (covers behind status bar)
              SizedBox(
                height: headerHeight + topInset,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      kHeaderLoginImage,
                      fit: BoxFit.cover,
                    ),
                    // dark overlay for readability
                    Container(color: Colors.black.withOpacity(0.60)),

                    // Only show text content when keyboard is NOT visible
                    if (!_isKeyboardVisible)
                      Padding(
                        padding: EdgeInsets.fromLTRB(18, topInset + 18, 18, 18),
                        child: Column(
                          children: [
                            const Spacer(),
                            const Text(
                              "WELCOME!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Sign in to continue".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ✅ WHITE CARD
              Transform.translate(
                offset: const Offset(0, -22),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: kBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              "My Council App",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: _isKeyboardVisible ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          const Text(
                            "Email Address",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: controller.emailController,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_passwordFocusNode);
                            },
                            validator: (value) {
                              if (value == null ||
                                  !isValidEmail(value, isRequired: true)) {
                                return "Please enter a valid email";
                              }
                              return null;
                            },
                            decoration: _fieldDecoration(
                              hint: "name@domain.com",
                              icon: Icons.mail_outline,
                            ),
                          ),

                          const SizedBox(height: 14),

                          const Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                                () => TextFormField(
                              controller: controller.passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: controller.hidePassword.value,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _onLoginPressed(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter your password";
                                }
                                return null;
                              },
                              decoration: _fieldDecoration(
                                hint: "Enter your password",
                                icon: Icons.lock_outline,
                                suffix: IconButton(
                                  icon: Icon(
                                    controller.hidePassword.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: kPrimaryGreen,
                                  ),
                                  onPressed: () {
                                    controller.hidePassword.value =
                                    !controller.hidePassword.value;
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _showForgotPasswordDialog,
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: kAccentGold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Obx(
                                () => SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : _onLoginPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryGreen,
                                  disabledBackgroundColor:
                                  kPrimaryGreen.withOpacity(0.6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Please wait...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                )
                                    : const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "SIGN IN",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.login_rounded,
                                        color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Hide logo and footer when keyboard is visible
                          if (!_isKeyboardVisible) ...[
                            const SizedBox(height: 14),
                            Center(
                              child: Image.asset(
                                'assets/images/mglogo.png',
                                height: 52,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Center(
                              child: Text(
                                "Secure access • Transparency • Accountability".tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: kTextMuted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}