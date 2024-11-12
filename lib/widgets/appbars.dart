import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connect_app/globals/adaptive_helper.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';

PreferredSize customAppBar(
    {String title = '',
    Widget? lable,
    bool backButton = true,
    Color? titleColor,
    actions,
    double marginTop = 0}) {
  return PreferredSize(
    preferredSize: const Size(double.infinity, 70),
    child: AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      flexibleSpace: Container(
        margin: EdgeInsets.only(top: marginTop),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              backButton
                  ? GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 1.0,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: AppColors.primaryIconColor,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Image.asset(
                        'assets/images/kora_logo.png',
                        width: wd(40),
                        height: ht(40),
                      ),
                    ), // Placeholder for backButton space
              Expanded(
                child: Center(
                  child: lable ??
                      Text(
                        title,
                        style: headingText(
                            size: 20,
                            color: titleColor ?? AppColors.textPrimary),
                      ),
                ),
              ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions,
                )
              else
                const SizedBox(width: 48), // Placeholder for actions space
            ],
          ),
        ),
      ),
    ),
  );
}

PreferredSize customAppBarTransparent({
  String title = '',
  Widget? lable,
  bool backButton = true,
  List<Widget>? actions,
  double marginTop = 0,
}) {
  return PreferredSize(
    preferredSize: const Size(double.infinity, 70),
    child: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        title,
        style: headingText(size: 20, color: AppColors.white),
      ),
      centerTitle: true,
      leading: backButton
          ? GestureDetector(
              onTap: () {
                // Adjust navigation according to your setup
                Get.back();
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors
                        .grey, // Replace with AppColors.borderColor if defined
                    width: 1.0,
                  ),
                  color: AppColors.white,
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 15,
                    color: Colors
                        .black, // Replace with AppColors.primaryIconColor if defined
                  ),
                ),
              ),
            )
          : const SizedBox(width: 48),
    ),
  );
}

PreferredSize customAppBarIcon({
  String title = '',
  Widget? lable,
  bool backButton = true,
  List<Widget>? actions,
  double marginTop = 0,
}) {
  return PreferredSize(
    preferredSize: const Size(double.infinity, 70),
    child: AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      flexibleSpace: Container(
        margin: EdgeInsets.only(top: marginTop),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              backButton
                  ? GestureDetector(
                      onTap: () {
                        // Adjust navigation according to your setup
                        Get.back();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors
                                .grey, // Replace with AppColors.borderColor if defined
                            width: 1.0,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 20,
                            color: Colors
                                .black, // Replace with AppColors.primaryIconColor if defined
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: 48), // Placeholder for backButton space
              Expanded(
                child: Center(
                  child: lable ??
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors
                              .black, // Replace with AppColors.textPrimary if defined
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions,
                )
              else
                const SizedBox(width: 48), // Placeholder for actions space
            ],
          ),
        ),
      ),
    ),
  );
}
