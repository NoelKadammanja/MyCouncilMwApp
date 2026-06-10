import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/features/auth/controllers/login_controller.dart';
import 'package:local_govt_mw/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.put(LoginController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _identifierFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kAccentGold = Color(0xFFF4C430);
  static const Color kTextDark = Color(0xFF111827);
  static const Color kTextMuted = Color(0xFF6B7280);
  static const Color kFieldBg = Color(0xFFF8FAFC);
  static const Color kBorder = Color(0xFFE5E7EB);
  static const String kHeaderLoginImage = 'assets/images/login.png';

  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ));

    _identifierFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final hasFocus =
        _identifierFocusNode.hasFocus || _passwordFocusNode.hasFocus;
    if (_isKeyboardVisible != hasFocus) {
      setState(() {
        _isKeyboardVisible = hasFocus;
      });
    }

    if (hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients && mounted) {
          if (_passwordFocusNode.hasFocus) {
            final passwordFieldContext = _passwordFocusNode.context;
            if (passwordFieldContext != null) {
              final renderBox =
              passwordFieldContext.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final offset = renderBox.localToGlobal(Offset.zero);
                final media = MediaQuery.of(context);
                final keyboardHeight = media.viewInsets.bottom;
                final screenHeight = media.size.height;
                final fieldBottom = offset.dy + renderBox.size.height;
                final scrollAmount =
                    (fieldBottom - (screenHeight - keyboardHeight)) + 20;
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
    _identifierFocusNode.dispose();
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
      hintText: hint,
      hintStyle:
      const TextStyle(color: kTextMuted, fontWeight: FontWeight.w500),
      filled: true,
      fillColor: kFieldBg,
      contentPadding:
      const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
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
        borderSide:
        const BorderSide(color: Colors.redAccent, width: 1.2),
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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Password Recovery',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
          'Please contact your account manager or ICT helpdesk to reset your account.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final headerHeight = media.size.height * 0.40;
    final topInset = media.padding.top;

    return WillPopScope(
      onWillPop: () async {
        Get.offAllNamed(AppRoutes.onboardingScreen);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: Column(
            children: [
              // ── Header image ─────────────────────────────────────
              SizedBox(
                height: headerHeight + topInset,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(kHeaderLoginImage, fit: BoxFit.cover),
                    Container(color: Colors.black.withOpacity(0.60)),
                    if (!_isKeyboardVisible)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            18, topInset + 18, 18, 18),
                        child: Column(
                          children: [
                            const Spacer(),
                            const Text(
                              'WELCOME!',
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
                              'Sign in to continue',
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

              // ── Login card ────────────────────────────────────────
              Transform.translate(
                offset: const Offset(0, -22),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    padding:
                    const EdgeInsets.fromLTRB(16, 18, 16, 16),
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
                          // ── App title ───────────────────────────
                          Center(
                            child: Text(
                              'Inspection App',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                _isKeyboardVisible ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // // ── Identifier hint chips ───────────────
                          // if (!_isKeyboardVisible)
                          //   Center(
                          //     child: Wrap(
                          //       spacing: 6,
                          //       children: [
                          //         _IdentifierChip(label: 'Email'),
                          //         _IdentifierChip(label: 'Phone'),
                          //         _IdentifierChip(label: 'National ID'),
                          //       ],
                          //     ),
                          //   ),
                          //
                          // const SizedBox(height: 18),

                          // ── Identifier field ────────────────────
                          const Text(
                            'Username',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: kTextDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: controller.identifierController,
                            focusNode: _identifierFocusNode,
                            // Accept any keyboard — user may type email,
                            // phone or national ID.
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(_passwordFocusNode);
                            },
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email, phone number, or national ID';
                              }
                              return null;
                            },
                            decoration: _fieldDecoration(
                              hint:
                              'Email, phone or national ID',
                              icon: Icons.person_outline_rounded,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── Password field ──────────────────────
                          const Text(
                            'Password',
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
                              obscureText:
                              controller.hidePassword.value,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _onLoginPressed(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                              decoration: _fieldDecoration(
                                hint: 'Enter your password',
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

                          // ── Forgot password ─────────────────────
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _showForgotPasswordDialog,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: kAccentGold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ── Sign-in button ──────────────────────
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
                                    borderRadius:
                                    BorderRadius.circular(14),
                                  ),
                                ),
                                child: controller.isLoading.value
                                    ? const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                      CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                        AlwaysStoppedAnimation<
                                            Color>(Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Please wait...',
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
                                      'SIGN IN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.login_rounded,
                                        color: Colors.white,
                                        size: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // ── Logo & footer ───────────────────────
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
                            const Center(
                              child: Text(
                                'Secure access • Transparency • Accountability',
                                textAlign: TextAlign.center,
                                style: TextStyle(
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

// ── Small chip showing accepted identifier types ──────────────────────────

class _IdentifierChip extends StatelessWidget {
  final String label;
  const _IdentifierChip({required this.label});

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withOpacity(0.07),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPrimaryGreen.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: kPrimaryGreen,
        ),
      ),
    );
  }
}