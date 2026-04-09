// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:local_govt_mw/common/basewidget/custom_icon_button.dart';
// import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
// import 'package:local_govt_mw/features/notification/controllers/notification_controller.dart';
// import 'package:local_govt_mw/data/local/notification_dao.dart';
// import 'package:local_govt_mw/theme/app_style.dart';
// import 'package:local_govt_mw/theme/custom_theme_colour.dart';
// import 'package:local_govt_mw/utill/images.dart';
// import 'package:local_govt_mw/utill/size_utils.dart';
// import 'package:flutter/material.dart';
//
// class NotificationScreen extends GetWidget<NotificationController> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: const Color(0xFF153871),
//         body: SafeArea(
//           child: Container(
//               height: size.height,
//               width: size.width,
//               child: Stack(children: [
//                 Align(
//                     alignment: Alignment.center,
//                     child: Container(
//                         height: size.height,
//                         width: size.width,
//                         child: Stack(
//                             alignment: Alignment.topRight,
//                             children: [
//                               Align(
//                                   alignment: Alignment.topLeft,
//                                   child: Container(
//                                       height: getVerticalSize(251.00),
//                                       width: getHorizontalSize(width),
//                                       padding: getPadding(
//                                           left: 24,
//                                           top: 16,
//                                           right: 24,
//                                           bottom: 16),
//                                       decoration: BoxDecoration(
//                                           image: DecorationImage(
//                                               image: AssetImage(
//                                                   ImageConstant
//                                                       .imgGroup14),
//                                               fit: BoxFit.fill)),
//                                       child: Stack(children: [
//                                         CustomIconButton(
//                                             height: 50,
//                                             width: 50,
//                                             variant: IconButtonVariant
//                                                 .FillWhiteA70014,
//                                             alignment: Alignment.topLeft,
//                                             onTap: () {
//                                               onTapBtnArrowleft();
//                                             },
//                                             child: CustomImageView(
//                                                 svgPath: ImageConstant
//                                                     .imgArrowleftWhiteA70050x50))
//                                       ]))),
//                               Align(
//                                   alignment: Alignment.topRight,
//                                   child: Container(
//                                       width: getHorizontalSize(253.00),
//                                       padding: getPadding(
//                                           left: 11,
//                                           top: 27,
//                                           right: 11,
//                                           bottom: 27),
//                                       decoration: BoxDecoration(
//                                           image: DecorationImage(
//                                               image: AssetImage(
//                                                   ImageConstant
//                                                       .imgRectangle1933),
//                                               fit: BoxFit.cover)),
//                                       child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             Padding(
//                                                 padding: getPadding(
//                                                     bottom: 94),
//                                                 child: Text(
//                                                     "Notifications".tr,
//                                                     overflow: TextOverflow
//                                                         .ellipsis,
//                                                     textAlign:
//                                                         TextAlign.left,
//                                                     style: AppStyle
//                                                         .txtInterSemiBold20
//                                                         .copyWith(
//                                                             height:
//                                                                 getVerticalSize(
//                                                                     1.12))))
//                                           ]))),
//                               Align(
//                                   alignment: Alignment.bottomCenter,
//                                   child: Container(
//                                       height: getVerticalSize(682.00),
//                                       width: size.width,
//                                       decoration: BoxDecoration(
//                                           color: ColorConstant.whiteA700,
//                                           borderRadius: BorderRadius.only(
//                                               topLeft: Radius.circular(
//                                                   getHorizontalSize(
//                                                       32.00)),
//                                               topRight: Radius.circular(
//                                                   getHorizontalSize(
//                                                       32.00)))))),
//                               Align(
//                                   alignment: Alignment.bottomCenter,
//                                   child: Padding(
//                                       padding:
//                                           getPadding(left: 24, right: 24, top: 94),
//                                       child: FutureBuilder<List<Map<String, dynamic>>>(
//                                           future: NotificationDao().getNotifications(),
//                                           builder: (context, snap) {
//                                             final items = snap.data ?? [];
//
//                                             if (items.isEmpty) {
//                                               return Padding(
//                                                 padding: getPadding(top: 90, left: 24, right: 24),
//                                                 child: Center(
//                                                   child: Text(
//                                                     'You currently have no notifications'.tr,
//                                                     textAlign: TextAlign.center,
//                                                     style: AppStyle.txtInterRegular16Gray800.copyWith(
//                                                       height: getVerticalSize(1.3),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               );
//                                             }
//
//                                             // partition into today / yesterday
//                                             final now = DateTime.now();
//                                             final today = <Map<String, dynamic>>[];
//                                             final yesterday = <Map<String, dynamic>>[];
//                                             for (var it in items) {
//                                               final ts = (it['timestamp'] is int)
//                                                   ? DateTime.fromMillisecondsSinceEpoch(it['timestamp'])
//                                                   : DateTime.tryParse(it['timestamp']?.toString() ?? '') ?? now;
//                                               final diff = now.difference(DateTime(ts.year, ts.month, ts.day)).inDays;
//                                               if (diff == 0) {
//                                                 today.add(it);
//                                               } else if (diff == 1) {
//                                                 yesterday.add(it);
//                                               }
//                                             }
//
//                                             return ListView(
//                                               children: [
//                                                 Text("Today".tr,
//                                                     overflow: TextOverflow.ellipsis,
//                                                     textAlign: TextAlign.left,
//                                                     style: AppStyle.txtInterBold14Gray800.copyWith(height: getVerticalSize(1.19))),
//                                                 Padding(
//                                                     padding: getPadding(top: 24),
//                                                     child: ListView.separated(
//                                                       physics: NeverScrollableScrollPhysics(),
//                                                       shrinkWrap: true,
//                                                       separatorBuilder: (context, index) => Container(
//                                                           height: getVerticalSize(1.00),
//                                                           width: getHorizontalSize(327.00),
//                                                           decoration: BoxDecoration(color: ColorConstant.gray200)).paddingOnly(bottom: 16),
//                                                       itemCount: today.length,
//                                                       itemBuilder: (context, index) {
//                                                         final model = today[index];
//                                                         return ListTile(
//                                                           title: Text(model['title'] ?? '', style: AppStyle.txtInterMedium16),
//                                                           subtitle: Text(model['body'] ?? ''),
//                                                           isThreeLine: true,
//                                                         );
//                                                       },
//                                                     )),
//                                                 Padding(
//                                                     padding: getPadding(top: 41),
//                                                     child: Text("Yesterday".tr,
//                                                         overflow: TextOverflow.ellipsis,
//                                                         textAlign: TextAlign.left,
//                                                         style: AppStyle.txtInterBold14Gray800.copyWith(height: getVerticalSize(1.19)))),
//                                                 Padding(
//                                                     padding: getPadding(top: 24),
//                                                     child: ListView.separated(
//                                                       physics: NeverScrollableScrollPhysics(),
//                                                       shrinkWrap: true,
//                                                       separatorBuilder: (context, index) => Container(
//                                                           height: getVerticalSize(1.00),
//                                                           width: getHorizontalSize(327.00),
//                                                           decoration: BoxDecoration(color: ColorConstant.gray200)).paddingOnly(bottom: 16),
//                                                       itemCount: yesterday.length,
//                                                       itemBuilder: (context, index) {
//                                                         final model = yesterday[index];
//                                                         return ListTile(
//                                                           title: Text(model['title'] ?? '', style: AppStyle.txtInterMedium16),
//                                                           subtitle: Text(model['body'] ?? ''),
//                                                           isThreeLine: true,
//                                                         );
//                                                       },
//                                                     ))
//                                               ],
//                                             );
//                                           })))
//                             ])))
//               ])),
//         ));
//   }
//
//   onTapBtnArrowleft() {
//     Get.back();
//   }
// }
