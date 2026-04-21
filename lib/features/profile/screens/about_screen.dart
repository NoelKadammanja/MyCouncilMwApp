import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';

class AboutDinvestScreen extends StatefulWidget {
  const AboutDinvestScreen({Key? key}) : super(key: key);

  @override
  State<AboutDinvestScreen> createState() => _AboutDinvestScreenState();
}

class _AboutDinvestScreenState extends State<AboutDinvestScreen> {
  static const Color kBg = Color(0xFFF3F4F6);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kPrimaryGreen = Color(0xFF1E7F4F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: CustomAppBar(
        title: "About App",
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Icon
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/ntech.png',
              fit: BoxFit.contain,
            ),
          ),

          Center(
            child: Text(
              "NICO Technologies Ltd",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: kText,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "Local Government Revenue Management System",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kMuted,
              ),
            ),
          ),
          const SizedBox(height: 32),

          _section(
            title: "Our Mission",
            body: "Offering our clients solutions that aid digital transformation.",
          ),
          _section(
            title: "Our Vision",
            body: "Enabling excellent customer experience through innovative technology solutions.",
          ),
          _section(
            title: "About NICO Technologies Ltd",
            body: "NICO Technologies Limited was incorporated in January 2002 under the Companies Act of Malawi. The company evolved from a self-accounting IT department of The National Insurance Company Limited, where it had been in existence since 1982.",
          ),
          _section(
            title: "Our Background",
            body: "We are a purely Malawian company with strong financial backing and access to Professional Indemnity insurance cover, ensuring our commitment to service delivery. We believe in collaborating with various players locally and internationally through strategic alliances.",
          ),
          _section(
            title: "About This App",
            body: "This Local Government Revenue Collection System was developed by NICO Technologies Ltd in partnership with the Government of Malawi through the Ministry of Local Government and respective Councils (City, District, Town, and Municipal Councils).",
          ),
          _section(
            title: "System Purpose",
            body: "The app facilitates efficient revenue collection and business licensing inspection services. Revenue collectors can process payments from vendors and businesses, while licensing inspectors can conduct and submit inspection reports for business premises.",
          ),
          _section(
            title: "Data Security",
            body: "We take data security seriously. All personal and financial information is protected using industry-standard encryption and security protocols. Access is restricted to authorized council personnel only.",
          ),
          _section(
            title: "Key Features",
            body: "• Mobile revenue collection with receipt generation\n• Business licensing inspection checklists\n• Real-time assignment tracking for inspectors\n• Secure authentication and role-based access\n• Council-specific data management\n• Offline capability for field operations",
          ),
          _section(
            title: "Support",
            body: "For technical support or inquiries, please contact your respective council's ICT department or reach out to NICO Technologies Ltd support team.",
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _section({required String title, required String body}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: kPrimaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: kText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
    );
  }
}