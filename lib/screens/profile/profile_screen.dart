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
            GetBuilder(
              builder: (UserDetail controller) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.grey.shade300,
                    ),
                    height: ht(96),
                    width: ht(96),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: NetworkImageCustom(
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                            image: controller.userData.user?.avatar?? ''),
                      ),
                    ),
                  ),
                );
              },
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
                    if (controller.myPosts.value.posts?.isNotEmpty == true &&  controller.isDataFetched.value) {
                      return Wrap(
                        // spacing: 0,
                        // runSpacing: 0,
                        children: controller.myPosts.value.posts
                            ?.asMap()
                            .entries
                            .map((entry) {
                          int index = entry.key; // The index
                          var post = entry.value; // The post object
                          return BuildVideoCard(
                            thumbnail :post.thumbnail ??
                                'https://via.placeholder.com/150?text=Video+${index + 1}',
                            cardWidth :cardWidth,
                            cardheight: cardheight,
                            url: post.video ?? '',
                            videoId :post.id??0,
                            onSelected :(value) {
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

                            // Handle if video is null
                          );
                        }).toList() ??
                            [],
                      );
                    }else if(controller.isDataFetched.value){
                      return  Center(child: Text("No Videos available",style: TextStyle(fontSize: 18),),);
                    }

                    return Center(
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
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

  // Widget buildCard(
  //     String thumbnail, double cardWidth, double cardheight, String url, int videoId,void Function(String)? onSelected,BuildContext context) {
  //   return GestureDetector(
  //     onTap: () {
  //       Get.to(VideoScreen(url: url,));
  //     },
  //     child: SizedBox(
  //       width: cardWidth,
  //       child: Card(
  //         color: Colors.transparent, // Make the card background transparent
  //         elevation: 0,
  //         child: Stack(
  //           children: [
  //             Uri.parse(thumbnail).isAbsolute? CachedNetworkImage(imageUrl: thumbnail, errorWidget: (context,error , trace)=> SizedBox(
  //               height: cardWidth,
  //                 width: cardWidth,
  //                 child: Icon(Icons.video_file_rounded, color: AppColors.primaryColor,),),):Image.file(
  //               File(thumbnail),
  //               fit: BoxFit.cover,
  //               height: cardheight,
  //               width: cardWidth,
  //             ),
  //             Positioned(
  //               bottom: 1.0,
  //               left: 1.0,
  //               right: 1.0,
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Flexible(
  //                     child: IconButton(
  //                       icon:  ImageIcon(const AssetImage('assets/images/video_message_icon.png'), color: AppColors.white,),
  //                       onPressed: () {
  //                         Get.to(FollowRequestsScreen(thumbnail: thumbnail, videoId: videoId,));
  //
  //                       },
  //                     ),
  //                   ),
  //                   Flexible(
  //                     child: PopupMenuButton<String>(
  //                       onSelected: onSelected,
  //                       itemBuilder: (BuildContext context) {
  //                         return {'Stats', 'Delete Video'}
  //                             .map((String choice) {
  //                           IconData icon;
  //                           switch (choice) {
  //                             case 'Stats':
  //                               icon = Icons.query_stats;
  //                               break;
  //                             case 'Delete Video':
  //                               icon = Icons.delete;
  //                               break;
  //                             default:
  //                               icon = Icons.info;
  //                           }
  //
  //                           return PopupMenuItem<String>(
  //                             value: choice,
  //                             child: Row(
  //                               children: [
  //                                 Icon(icon),
  //                                 const SizedBox(width: 4),
  //                                 Text(choice),
  //                               ],
  //                             ),
  //                           );
  //                         }).toList();
  //                       },
  //                       icon: const Icon(Icons.more_vert, color: Colors.white),
  //                       // Customizing the appearance of the dropdown menu
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(10),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

class BuildVideoCard extends StatelessWidget {
  const BuildVideoCard({super.key, required this.thumbnail, required this.cardWidth, required this.cardheight, required this.url, required this.videoId, this.onSelected});

  final String thumbnail;
  final double cardWidth;
  final double cardheight;
  final String url;
      final int videoId;
  final void Function(String)? onSelected;

  @override
  Widget build(BuildContext context) {
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
