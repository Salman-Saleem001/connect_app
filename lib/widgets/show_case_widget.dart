
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:showcaseview/showcaseview.dart';

import '../controllers/mainScreen_controllers/navbar_controller.dart';

class AppShowCaseWidget extends StatelessWidget {
  const AppShowCaseWidget(
      {super.key,
      required this.globalKey,
      required this.title,
      required this.description,
      required this.child,
      this.tooltipPosition = TooltipPosition.right});

  final GlobalKey globalKey;
  final String title;
  final String description;
  final Widget child;
  final TooltipPosition tooltipPosition;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavBarController());
    return Showcase(
      targetShapeBorder: CircleBorder(),
      disableBarrierInteraction: true,
      targetPadding: EdgeInsets.all(5),
      overlayOpacity: 0.4,
      tooltipPosition: tooltipPosition,
      key: globalKey,
      title: title,
      description: description,
      titleTextAlign: TextAlign.start,
      descriptionTextAlign: TextAlign.start,
      titleAlignment: AlignmentGeometry.topLeft,
      titlePadding: EdgeInsets.symmetric(horizontal: 10),
      descriptionPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),

      textColor: AppColors.white,
      tooltipBackgroundColor: AppColors.primaryColor,
      tooltipActions: [
        TooltipActionButton(
            type: TooltipDefaultActionType.skip,
            textStyle: normalText(color: AppColors.primaryColor),
            backgroundColor: AppColors.white,
            hideActionWidgetForShowcase: [controller.likeButton]),
        TooltipActionButton(
            type: TooltipDefaultActionType.next,
            textStyle: normalText(color: AppColors.primaryColor),
            backgroundColor: AppColors.white,
            hideActionWidgetForShowcase: [controller.profilePage]),
      ],
      child: child,
    );
  }
}

