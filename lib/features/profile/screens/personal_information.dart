import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({Key? key}) : super(key: key);

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  static const Color kBg = Color(0xFFF3F4F6);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kBorder = Color(0xFFE5E7EB);

  late final Future<Map<String, dynamic>?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = UserDao().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: CustomAppBar(
        title: "Account Information",
        showBackButton: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: userFuture,
        builder: (context, snapshot) {
          final user = snapshot.data ?? {};
          final name = (user['name'] ?? user['full_name'])?.toString() ?? '';
          final email = user['email']?.toString() ?? '';
          final councilName = user['council_name']?.toString() ?? '';
          final role = user['role']?.toString() ?? '';
          final phone = user['phone']?.toString() ?? 'Not provided';

          String initials = '';
          if (name.isNotEmpty) {
            final parts = name.split(RegExp(r"\s+"));
            initials = parts.length == 1
                ? parts.first[0].toUpperCase()
                : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimaryGreen.withOpacity(0.1),
                      ),
                      child: Center(
                        child: initials.isNotEmpty
                            ? Text(
                          initials,
                          style: GoogleFonts.poppins(
                            color: kPrimaryGreen,
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                            : Icon(
                          Icons.person,
                          size: 50,
                          color: kPrimaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name.isNotEmpty ? name : "User",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: kText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.isNotEmpty ? role : "Role",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      councilName.isNotEmpty ? councilName : "Council",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Information Sections
              _infoCard(
                icon: Icons.person_outline,
                title: "Full Name",
                value: name.isNotEmpty ? name : "Not provided",
              ),
              _infoCard(
                icon: Icons.email_rounded,  // Fixed: Changed from email_outline to email_rounded
                title: "Email Address",
                value: email.isNotEmpty ? email : "Not provided",
              ),
              _infoCard(
                icon: Icons.phone_android,
                title: "Phone Number",
                value: phone,
              ),
              _infoCard(
                icon: Icons.business,
                title: "Council",
                value: councilName.isNotEmpty ? councilName : "Not provided",
              ),
              _infoCard(
                icon: Icons.work_outline,
                title: "Role",
                value: role.isNotEmpty ? role : "Not provided",
              ),
              _infoCard(
                icon: Icons.verified_user,
                title: "Account Status",
                value: "Active",
                valueColor: kPrimaryGreen,
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPrimaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimaryGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? kText,
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