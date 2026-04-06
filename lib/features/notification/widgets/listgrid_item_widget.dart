import 'package:get/get.dart';
import 'package:local_govt_mw/common/basewidget/custom_icon_button.dart';
import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
import 'package:local_govt_mw/features/notification/controllers/notification_controller.dart';
import 'package:local_govt_mw/features/notification/domain/models/list_grid_item_model.dart';
import 'package:local_govt_mw/theme/app_style.dart';
import 'package:local_govt_mw/utill/images.dart';
import 'package:local_govt_mw/utill/size_utils.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ListgridItemWidget extends StatelessWidget {
  ListgridItemWidget(this.listgridItemModelObj);

  ListgridItemModel listgridItemModelObj;

  var controller = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomIconButton(
          height: 44,
          width: 44,
          margin: getMargin(bottom: 46),
          variant: IconButtonVariant.FillBlue700,
          shape: IconButtonShape.CircleBorder22,
          padding: IconButtonPadding.PaddingAll10,
          child: CustomImageView(
            svgPath: ImageConstant.imgGrid,
          ),
        ),

        const SizedBox(width: 12),

        /// FIX: Wrap the entire right section in Expanded
        Expanded(
          child: Padding(
            padding: getPadding(top: 1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /// Title
                    Expanded(
                      child: Text(
                        "Support Ticket".tr,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.txtInterBold16.copyWith(
                          height: getVerticalSize(1.24),
                        ),
                      ),
                    ),

                    /// FIX: Spacer replaces bad left: 160
                    const Spacer(),

                    /// Time
                    Text(
                      "3:12 pm".tr,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyle.txtInterRegular12.copyWith(
                        height: getVerticalSize(1.27),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 11),

                /// Message content
                Text(
                  "Support ticket has been submitted successfully".tr,
                  maxLines: null,
                  style: AppStyle.txtInterRegular14WhiteA700.copyWith(
                    height: getVerticalSize(1.19),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
