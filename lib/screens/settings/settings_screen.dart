import 'package:connect_app/controllers/mainScreen_controllers/profile_controller.dart';
import 'package:connect_app/screens/other_screens/view_all_stats.dart';
import 'package:connect_app/screens/settings/blocked_users.dart';
import 'package:connect_app/screens/settings/notifcation_settings.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/mainScreen_controllers/navbar_controller.dart';
import '../../utils/login_details.dart';
import '../../widgets/primary_button.dart';
import '../auth_screens/forget_password.dart';
import '../profile/edit_details.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        backButton: true,
        title: "Settings",
        marginTop: 20,
      ),
      body: ListView(
        children: [
          SettingsSection(
            title: 'ACCOUNT MANAGER',
            tiles: [
              SettingsTile(
                icon: Icons.person,
                title: 'Personal Details',
                onTap: () {
                  Get.to(() => const EditDetails());
                },
              ),
              SettingsTile(
                icon: Icons.bar_chart,
                title: 'Views Stats',
                onTap: () {
                  // var profileController = Get.put(ProfileController());
                  Get.to(() => ViewAllStats());
                },
              ),
              SettingsTile(
                icon: Icons.lock,
                title: 'Password & Security',
                onTap: () {
                  Get.to(() => ForgetPassword(
                        fromChangePassword: true,
                      ));
                },
              ),
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Divider(
                color: AppColors.borderColor,
              )),
          SettingsSection(
            title: 'PREFERENCES & ACTIVITY',
            tiles: [
              SettingsTile(
                icon: Icons.notifications,
                title: 'Notifications',
                // toScreen: NotificationSettingsScreen(),
                onTap: () {
                  Get.to(() => NotificationSettingsScreen());
                },
              ),
              SettingsTile(
                icon: Icons.language,
                title: 'Language & Region',
              ),
              SettingsTile(
                icon: Icons.no_accounts_outlined,
                title: 'Blocked Users',
                onTap: (){
                  final profile = Get.put(ProfileController());
                  profile.getBlockedUser();
                  Get.to(()=> BlockedUsers());
                },
              ),
              SettingsTile(
                icon: Icons.logout,
                title: 'Logout Device',
                onTap: () async {
                  var nav = Get.put(NavBarController());
                  final profile = Get.put(ProfileController());
                  profile.clear();
                  profile.dispose();
                  nav.clear();
                  Get.find<UserDetail>().logout();
                  // Get.deleteAll();
                },
              ),
              SettingsTile(
                icon: Icons.no_accounts,
                title: 'Delete Account',
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (_) {
                        return Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Delete Account", style: headingText()),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Are you sure you want to delete your account?",
                                  style: normalText(),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: BorderedButton(
                                        text: "Cancel",
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: PrimaryButton(
                                        label: 'Delete',
                                        // whiteButton: true,
                                        onPress: () {
                                          final profile = Get.put(ProfileController());
                                          profile.deleteProfile().then((val) {
                                            if (val) {
                                              var nav = Get.put(NavBarController());
                                              profile.clear();
                                              profile.dispose();
                                              nav.clear();
                                              Get.find<UserDetail>().logout();
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      });
                },
              ),
            ],
          ),
          Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Divider(
                color: AppColors.borderColor,
              )),
          SettingsSection(
            title: 'MORE INFO AND SUPPORT',
            tiles: [
              SettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
              ),
              SettingsTile(
                icon: Icons.description,
                title: 'Terms & Conditions',
              ),
              SettingsTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
              ),
              SettingsTile(
                icon: Icons.info_outline,
                title: 'About Us',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const SettingsSection({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: regularText(color: AppColors.txtGrey)),
        ),
        ...tiles,
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.txtGrey,
      ),
      title: Text(title),
      onTap: onTap,
    );
  }
}
