import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:showcaseview/showcaseview.dart';

import '../controllers/mainScreen_controllers/navbar_controller.dart';
import '../utils/app_colors.dart';
import '../utils/login_details.dart';
import '../utils/text_styles.dart';

class TakeTour extends StatelessWidget {
  const TakeTour({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.onTapContinue,
  });

  final ValueNotifier<bool> isSelected;
  final VoidCallback onTap;
  final VoidCallback onTapContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Align(
            alignment: AlignmentGeometry.topRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.close,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          Text(
            "Let's take a quick tour !",
            style: subHeadingText(color: AppColors.primaryColor, size: 20),
          ),
          Text(
            "Here are some helpful tips to get you started with the Connect Giant app",
            style: normalText(
              color: AppColors.bgGrey,
              size: 14,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onTap,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isSelected,
                      builder: (BuildContext context, bool value, Widget? child) {
                        if (value) {
                          return Icon(
                            Icons.done,
                            color: AppColors.primaryColor,
                            size: 16,
                          );
                        }
                        return SizedBox.square(
                          dimension: 12,
                        );
                      },
                    ),
                  ),
                ),
              ),
              Text(
                "  Don't ask again",
                style: normalText(color: AppColors.txtGrey),
              ),
            ],
          ),
          GestureDetector(
            onTap: onTapContinue,
            child: SizedBox(
              height: 50,
              width: double.maxFinite,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Continue",
                    style: subHeadingText(color: AppColors.white, size: 20),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

void display() {
  ValueNotifier<bool> isSelected = ValueNotifier(false);
  final controller = Get.put(NavBarController());
  final userDetails = Get.put(UserDetail());
  showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          child: TakeTour(
            isSelected: isSelected,
            onTapContinue: () {
              Navigator.pop(context);
              ShowcaseView.get().startShowCase([
                controller.likeButton,
                controller.commentButton,
                controller.shareButton,
                controller.moreButton,
                controller.feedTab,
                controller.trendingTab,
                controller.recommendedTab,
                controller.homePage,
                controller.searchPage,
                controller.createVideo,
                controller.chatPage,
                controller.profilePage,
              ]);
            },
            onTap: () {
              isSelected.value = !isSelected.value;
              userDetails.setHasUserCanceledAppOverView(isSelected.value);
            },
          ),
        );
      }).whenComplete(() => isSelected.dispose());
}
