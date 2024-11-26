import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connect_app/globals/adaptive_helper.dart';
import 'package:connect_app/globals/network_image.dart';
import 'package:connect_app/screens/profile/edit_details.dart';
import 'package:connect_app/screens/profile/followRequests_screen.dart';
import 'package:connect_app/screens/profile/stats_screen.dart';
import 'package:connect_app/screens/profile/video_screen.dart';
import 'package:connect_app/screens/settings/settings_screen.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/login_details.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/mainScreen_controllers/navbar_controller.dart';
import '../../controllers/mainScreen_controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final String imageUrl =
      'https://www.portotheme.com/wordpress/porto/shortcodes/wp-content/uploads/sites/32/2016/06/team-1.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
          backButton: true,
          title: Get.find<UserDetail>().userData.user?.username ?? '',
          actions: [
            GestureDetector(
              onTap: () {
                Get.to(const SettingsScreen());
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
                    Icons.settings,
                    size: 20,
                    color: AppColors.primaryIconColor,
                  ),
                ),
              ),
            )
          ]),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.shade300,
                ),
                height: ht(96),
                width: ht(96),
                child: Center(
                  child: imageUrl == ''
                      ? const Icon(Icons.image)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: NetworkImageCustom(
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                              image: Get.find<UserDetail>().userData.user?.avatar?? imageUrl),
                        ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Center(
              child: Text(
                Get.find<UserDetail>().userData.user?.username ?? '',
                style: subHeadingText(size: 15),
              ),
            ),
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${Get.find<UserDetail>().userData.user?.approvedFollowersCount ?? 0}',
                          style: regularText(
                              size: 17, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Followers',
                          style: normalText(
                              size: 13, color: AppColors.textLight),
                        )
                      ],
                    ),
                  ),
                  VerticalDivider(
                    color: AppColors.borderColor,
                    thickness: 1,
                    width: 2,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${Get.find<UserDetail>().userData.user?.approvedFollowingsCount ?? 0}',
                          style: regularText(
                              size: 17, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Following',
                          style:
                              normalText(size: 13, color: AppColors.textLight),
                        )
                      ],
                    ),
                  ),
                  VerticalDivider(
                    color: AppColors.borderColor,
                    thickness: 1,
                    width: 2,
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          "0",
                          style: regularText(
                              size: 17, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Likes',
                          style:
                              normalText(size: 13, color: AppColors.textLight),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BorderedButton(
                    text: 'Edit Profile',
                    onPressed: () {
                      Get.to(() => const EditDetails());
                    },
                  ),
                  const SizedBox(width: 20), // Add spacing between the buttons
                  BorderedButton(
                    text: 'My replies',
                    onPressed: () {
                      debugPrint('Button 2 Pressed!');
                      var controller = Get.put(NavBarController());
                      controller.changeTab(2);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final double cardWidth = (constraints.maxWidth) / 3;
                final double cardheight = (constraints.maxWidth / 3 * 1.5);

                return GetBuilder(
                  builder: (ProfileController controller) {
                    if (controller.myPosts.value.posts?.isEmpty == true) {
                      return Center(
                        child: SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                        ),
                      );
                    }
                    return Wrap(
                      // spacing: 0,
                      // runSpacing: 0,
                      children: controller.myPosts.value.posts
                              ?.asMap()
                              .entries
                              .map((entry) {
                            int index = entry.key; // The index
                            var post = entry.value; // The post object
                            return _buildCard(
                              post.thumbnail ??
                                  'https://via.placeholder.com/150?text=Video+${index + 1}',
                              cardWidth,
                              cardheight,
                              post.video ?? '',
                              post.id??0,
                                    (value) {
                                  debugPrint('Selected: $value');
                                  if(value=='Delete Video'){
                                    controller.deleteVideo(post.id??0).then((val){
                                      if(val){
                                        controller.myPosts.value.posts?.removeAt(index);
                                        controller.update();
                                      }
                                    });
                                  }else{

                                    Get.to(()=> StatsMapScreen(id: post.id??0,));
                                  }
                                },
                              context,

                              // Handle if video is null
                            );
                          }).toList() ??
                          [],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      String thumbnail, double cardWidth, double cardheight, String url, int videoId,void Function(String)? onSelected,BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(VideoScreen(url: url,));
      },
      child: SizedBox(
        width: cardWidth,
        child: Card(
          color: Colors.transparent, // Make the card background transparent
          elevation: 0,
          child: Stack(
            children: [
              Uri.parse(thumbnail).isAbsolute? CachedNetworkImage(imageUrl: thumbnail, errorWidget: (context,error , trace)=> SizedBox(
                height: cardWidth,
                  width: cardWidth,
                  child: Icon(Icons.video_file_rounded, color: AppColors.primaryColor,),),):Image.file(
                File(thumbnail),
                fit: BoxFit.cover,
                height: cardheight,
                width: cardWidth,
              ),
              Positioned(
                bottom: 1.0,
                left: 1.0,
                right: 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: IconButton(
                        icon:  ImageIcon(const AssetImage('assets/images/video_message_icon.png'), color: AppColors.white,),
                        onPressed: () {
                          Get.to(FollowRequestsScreen(thumbnail: thumbnail, videoId: videoId,));

                        },
                      ),
                    ),
                    Flexible(
                      child: PopupMenuButton<String>(
                        onSelected: onSelected,
                        itemBuilder: (BuildContext context) {
                          return {'Stats', 'Delete Video'}
                              .map((String choice) {
                            IconData icon;
                            switch (choice) {
                              case 'Stats':
                                icon = Icons.query_stats;
                                break;
                              case 'Delete Video':
                                icon = Icons.delete;
                                break;
                              default:
                                icon = Icons.info;
                            }

                            return PopupMenuItem<String>(
                              value: choice,
                              child: Row(
                                children: [
                                  Icon(icon),
                                  const SizedBox(width: 4),
                                  Text(choice),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        // Customizing the appearance of the dropdown menu
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
