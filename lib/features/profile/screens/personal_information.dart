import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/common/basewidget/custom_icon_button.dart';
import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
import 'package:local_govt_mw/theme/app_decoration.dart';
import 'package:local_govt_mw/theme/app_style.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/images.dart';
import 'package:local_govt_mw/utill/size_utils.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({Key? key}) : super(key: key);

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  late final Future<Map<String, dynamic>?> userFuture;
  final TextEditingController deleteConfirmController = TextEditingController();


  @override
  void initState() {
    super.initState();
    userFuture = UserDao().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF153871),
        body: SafeArea(
          child: SizedBox(
            width: size.width,
            child: Stack(
              children: [
                CustomImageView(
                  imagePath: ImageConstant.imgGroup14,
                  height: getVerticalSize(251),
                  width: getHorizontalSize(width),
                  fit: BoxFit.fill,
                ),

                /// HEADER
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      CustomIconButton(
                        height: 50,
                        width: 50,
                        variant: IconButtonVariant.FillWhiteA70014,
                        onTap: () => Get.back(),
                        child: CustomImageView(
                          svgPath: ImageConstant.imgArrowleftWhiteA70050x50,
                        ),
                      ),
                      SizedBox(width: getHorizontalSize(68)),
                      Text(
                        "Account Info",
                        style: AppStyle.txtInterSemiBold20.copyWith(
                          height: getVerticalSize(1.12),
                        ),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 24),
                ),

                /// CONTENT
                Stack(
                  children: [
                    Container(
                      decoration: AppDecoration.fillWhiteA700.copyWith(
                        borderRadius: BorderRadiusStyle.customBorderTL32,
                      ),
                      padding: getPadding(top: 24),
                      margin: EdgeInsets.only(top: getVerticalSize(142)),
                      child: Column(
                        children: [
                          Expanded(
                            child: FutureBuilder<Map<String, dynamic>?>(
                              future: userFuture,
                              builder: (context, snapshot) {
                                final user = snapshot.data ?? {};
                                final name =
                                    (user['name'] ?? user['full_name'])
                                        ?.toString() ??
                                    '';
                                final email = user['email']?.toString() ?? '';
                                final clientId =
                                    (user['client_id'] ??
                                            user['clientID'] ??
                                            user['clientId'])
                                        ?.toString() ??
                                    '';
                                final nat =
                                    (user['Nat_number'] ??
                                            user['nat_number'] ??
                                            user['natNumber'])
                                        ?.toString() ??
                                    '';

                                return ListView(
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    SizedBox(height: getVerticalSize(69)),
                                    getMyprofileDetailFormate(
                                      ImageConstant.imgProfileIcon,
                                      "Name",
                                      name.isNotEmpty ? name : "Username".tr,
                                    ),
                                    SizedBox(height: getVerticalSize(20)),
                                    const Divider(),
                                    SizedBox(height: getVerticalSize(20)),
                                    getMyprofileDetailFormate(
                                      ImageConstant.imgMailIcon,
                                      "Email",
                                      email.isNotEmpty
                                          ? email
                                          : "Useremailaddress".tr,
                                    ),
                                    SizedBox(height: getVerticalSize(20)),
                                    const Divider(),
                                    SizedBox(height: getVerticalSize(20)),
                                    getMyprofileDetailFormate(
                                      ImageConstant.imgProfileIcon,
                                      "Client Code",
                                      clientId.isNotEmpty ? clientId : '-',
                                    ),
                                    SizedBox(height: getVerticalSize(20)),
                                    const Divider(),
                                    SizedBox(height: getVerticalSize(20)),
                                    getMyprofileDetailFormate(
                                      ImageConstant.imgProfileIcon,
                                      "National ID",
                                      nat.isNotEmpty ? nat : '-',
                                    ),
                                    SizedBox(height: getVerticalSize(24)),

                                    /// ACCOUNT DELETION ACTION (ADDED)
                                    const Divider(height: 1),

                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        24,
                                        44,
                                        24,
                                        24,
                                      ),
                                      child: GestureDetector(
                                        onTap: _showDeleteAccountBottomSheet,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            SizedBox(width: 14),
                                            Text(
                                              "Request Account Deletion",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: getVerticalSize(24)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// AVATAR
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: getVerticalSize(108),
                        width: getVerticalSize(108),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: ColorConstant.whiteA700,
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 20),
                              blurRadius: 32,
                              spreadRadius: -16,
                              color: const Color(0XFF1C1E28).withOpacity(0.12),
                            ),
                          ],
                        ),
                        child: FutureBuilder<Map<String, dynamic>?>(
                          future: userFuture,
                          builder: (context, snapshot) {
                            final name =
                                snapshot.data?['name']?.toString() ?? '';
                            String initials = '';
                            if (name.isNotEmpty) {
                              final parts = name.split(RegExp(r"\s+"));
                              initials = parts.length == 1
                                  ? parts.first[0].toUpperCase()
                                  : (parts.first[0] + parts.last[0])
                                        .toUpperCase();
                            }

                            return CircleAvatar(
                              backgroundColor: ColorConstant.whiteA700,
                              child: initials.isNotEmpty
                                  ? Text(
                                      initials,
                                      style: AppStyle.txtInterSemiBold20
                                          .copyWith(
                                            color: ColorConstant.blue700,
                                            fontSize: getFontSize(28),
                                          ),
                                    )
                                  : CustomImageView(
                                      imagePath: ImageConstant.imgAvtar,
                                    ),
                            );
                          },
                        ),
                      ).paddingOnly(top: getVerticalSize(90)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------------------------
  void _showDeleteAccountBottomSheet() {
  final TextEditingController confirmController = TextEditingController();

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 44,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              "Request Account Deletion",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "This will submit a request for account deletion. "
              "The process is not immediate and may require identity verification. "
              "You will be contacted via email once reviewed.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      // Close bottom sheet first
                      Navigator.pop(context);

                      // Show DELETE confirmation dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => AlertDialog(
                          title: const Text("Confirm Deletion"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Type DELETE below to confirm your account deletion request.",
                                style: TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: confirmController,
                                decoration: const InputDecoration(
                                  hintText: "Type DELETE",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                if (confirmController.text.trim() != "DELETE") {
                                  Get.snackbar(
                                    "Confirmation required",
                                    "Please type DELETE exactly to proceed.",
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  return;
                                }

                                Navigator.pop(context);

                                Get.snackbar(
                                  "Request submitted",
                                  "Your account deletion request has been sent. Our team will contact you via email.",
                                  snackPosition: SnackPosition.BOTTOM,
                                );

                                // TODO: Call deletion API here
                              },
                              child: const Text("Confirm"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Submit"),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}



  Widget getMyprofileDetailFormate(
    String iconImage,
    String cetegoryName,
    String userDetail,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getHorizontalSize(24)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImageView(svgPath: iconImage),
          SizedBox(width: getHorizontalSize(16)),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cetegoryName,
                  style: TextStyle(
                    color: ColorConstant.gray600,
                    fontSize: getFontSize(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getVerticalSize(7)),
                Text(
                  userDetail,
                  style: TextStyle(
                    color: ColorConstant.black900,
                    fontSize: getFontSize(16),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
