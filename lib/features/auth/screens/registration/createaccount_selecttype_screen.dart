import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_govt_mw/features/auth/screens/registration/createaccount_linkinfo_screen.dart';

class SelectUserTypeScreen extends StatefulWidget {
  const SelectUserTypeScreen({super.key});

  @override
  State<SelectUserTypeScreen> createState() => _SelectUserTypeScreenState();
}

class _SelectUserTypeScreenState extends State<SelectUserTypeScreen> {
  String? _userType = 'existing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text(
          'Before we continue',
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please help us know if you already have an active investment account with us.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 32),

              /// EXISTING CUSTOMER CARD
              _optionCard(
                value: 'existing',
                title: 'I have an existing portfolio',
                subtitle: 'I want to access my account',
                icon: Icons.account_balance_wallet_outlined,
              ),

              const SizedBox(height: 16),

              /// NEW CUSTOMER CARD
              _optionCard(
                value: 'new',
                title: 'I am a new customer',
                subtitle: 'I want to create an account',
                icon: Icons.person_add_alt_1_outlined,
              ),

              const Spacer(),

              /// CONTINUE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_userType == 'existing') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LinkExistingAccountScreen(),
                        ),
                      );
                    } else {
                      _showCreateAccountAdvisorSheet(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF153871),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue',
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

  /// -----------------------------------------
  /// OPTION CARD
  /// -----------------------------------------
  Widget _optionCard({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool selected = _userType == value;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _userType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF0FA) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF153871) : Colors.black12,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: selected ? const Color(0xFF153871) : Colors.black54,
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            Radio<String>(
              value: value,
              groupValue: _userType,
              onChanged: (v) {
                setState(() {
                  _userType = v;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// -----------------------------------------
  /// ADVISOR BOTTOM SHEET
  /// -----------------------------------------
  void _showCreateAccountAdvisorSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Create a new account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'To create a new account, please speak to our friendly consultants who will assist you with setting up your account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.call),
                  label: const Text('Call Advisor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 198, 220, 255),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final uri = Uri.parse('tel:+265111832085');
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Send Email'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF153871)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final uri = Uri.parse(
                      'mailto:maturities@nicoassetmanagers.com',
                    );
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
