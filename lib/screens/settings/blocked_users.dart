import 'package:connect_app/controllers/mainScreen_controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../globals/network_image.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/appbars.dart';



class BlockedUsers extends StatelessWidget {
  const BlockedUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Get.put(ProfileController());
    return Scaffold(
      appBar: customAppBar(title: 'Manage Users', marginTop: 25),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Blocked Users', style: regularText(color: AppColors.txtGrey)),
          ),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (_, index) => Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: NetworkImageCustom(
                        image: profile.blockedUser[index].avatar ?? '',
                        fit: BoxFit.contain,
                        height: 50,
                        width: 50,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${profile.blockedUser[index].firstName ?? ""} ${profile.blockedUser[index].lastName ?? ""}",
                            style: normalText(),
                          ),
                          Text(
                            "@${profile.blockedUser[index].username ?? ""}",
                            style: normalText(color: AppColors.borderlight),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        profile.unBlockUser(userId: profile.blockedUser[index].id ?? 0 , index: index);
                      },
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(AppColors.redColor),
                        backgroundColor: WidgetStatePropertyAll(AppColors.redColor),
                        shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8))),
                      ),
                      child: Text(
                        "Unblock",
                        style: normalText(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
                itemCount: profile.blockedUser.length,
              );
            }),
          ),
        ],
      ),
    );
  }
}
