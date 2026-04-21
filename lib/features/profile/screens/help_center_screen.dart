import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const Color kBg = Color(0xFFF3F4F6);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kPrimaryGreen = Color(0xFF1E7F4F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: CustomAppBar(
        title: "Terms & Conditions",
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.description_outlined, size: 48, color: kPrimaryGreen),
                const SizedBox(height: 12),
                Text(
                  "Terms and Conditions",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Last updated: April 2026",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _section(
            number: "1",
            title: "Introduction",
            body: "These Terms and Conditions govern your use of the Local Government Revenue Collection System, developed by NICO Technologies Ltd in partnership with the Government of Malawi through the Ministry of Local Government and respective Councils (City, District, Town, and Municipal Councils).",
          ),
          _section(
            number: "2",
            title: "System Purpose",
            body: "This application is designed to facilitate efficient revenue collection, business licensing inspection, and management of local government services. Authorized users include revenue collectors and licensing inspectors from participating councils.",
          ),
          _section(
            number: "3",
            title: "User Accounts",
            body: "Access is granted only to authorized personnel of participating councils. You are responsible for maintaining the confidentiality of your login credentials and for all activities conducted under your account.",
          ),
          _section(
            number: "4",
            title: "Acceptable Use",
            body: "You agree to use this system solely for official council business purposes. Unauthorized access, data manipulation, or attempts to compromise system security are strictly prohibited and may result in legal action.",
          ),
          _section(
            number: "5",
            title: "Data Accuracy",
            body: "While NICO Technologies Ltd and partner councils strive to maintain accurate information, we do not warrant the completeness or accuracy of all data. Users should verify critical information through official channels when necessary.",
          ),
          _section(
            number: "6",
            title: "Intellectual Property",
            body: "The application, its code, design, and content are the intellectual property of NICO Technologies Ltd and the Government of Malawi. Unauthorized reproduction or distribution is prohibited.",
          ),
          _section(
            number: "7",
            title: "Limitation of Liability",
            body: "NICO Technologies Ltd and partner councils shall not be liable for any indirect, incidental, or consequential damages arising from the use or inability to use this system, including data loss or service interruptions.",
          ),
          _section(
            number: "8",
            title: "System Availability",
            body: "While we strive for continuous availability, we do not guarantee uninterrupted access. Scheduled maintenance or unforeseen technical issues may temporarily affect system accessibility.",
          ),
          _section(
            number: "9",
            title: "Amendments",
            body: "NICO Technologies Ltd reserves the right to modify these Terms and Conditions at any time. Continued use of the system after changes constitutes acceptance of the updated terms.",
          ),
          _section(
            number: "10",
            title: "Governing Law",
            body: "These Terms and Conditions are governed by the laws of the Republic of Malawi. Any disputes shall be resolved through the appropriate Malawian legal channels.",
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _section({required String number, required String title, required String body}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kPrimaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: kPrimaryGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: kText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: kMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}