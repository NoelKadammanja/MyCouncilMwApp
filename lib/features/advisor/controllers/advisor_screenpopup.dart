import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Call this from anywhere → showAdvisorPopup(context);
void showAdvisorPopup(BuildContext context) {
  const advisorEmail = 'maturities@nicoassetmanagers.com';
  const advisorPhone = '+265111832085';

  Future<void> _callAdvisor() async {
    final uri = Uri(scheme: 'tel', path: advisorPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _emailAdvisor() async {
    final uri = Uri(
      scheme: 'mailto',
      path: advisorEmail,
      queryParameters: {
        'subject': 'Investment Enquiry: From Mobile App',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent,
                  size: 34,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 16),

              /// TITLE
              const Text(
                "Speak to an Advisor",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// SUBTITLE
              const Text(
                "Our advisors are available\nMonday to Friday, 8AM – 4PM",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 24),

              /// CALL BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _callAdvisor();
                  },
                  icon: const Icon(Icons.call),
                  label: const Text("Call Advisor"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// EMAIL BUTTON
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _emailAdvisor();
                  },
                  icon: const Icon(Icons.email_outlined),
                  label: const Text("Send Email"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// CLOSE
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
