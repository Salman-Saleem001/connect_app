import 'package:connect_app/controllers/mainScreen_controllers/profile_controller.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../profile/profile_screen.dart';
import '../profile/stats_screen.dart';

class ViewAllStats extends StatelessWidget {
  const ViewAllStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: 'Views Stats', backButton: true),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        children: [
          GetBuilder(
            builder: (ProfileController controller) {
              if ((controller.myPosts.value.posts?.isNotEmpty ?? false) &&
                  controller.isDataFetched.value) {
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
                          thumbnail: post.thumbnail ??
                              'https://via.placeholder.com/150?text=Video+${index + 1}',
                          cardWidth: MediaQuery.of(context).size.width / 2.5,
                          cardHeight:
                              MediaQuery.of(context).size.width / 3 * 1.5,
                          url: post.video ?? '',
                          videoId: post.id ?? 0,
                          onSelected: (value) {
                            debugPrint('Selected: $value');
                            if (value == 'Delete Video') {
                              controller.deleteVideo(post.id ?? 0).then((val) {
                                if (val) {
                                  controller.myPosts.value.posts
                                      ?.removeAt(index);
                                  controller.update();
                                }
                              });
                            } else {
                              Get.to(() => StatsMapScreen(
                                    id: post.id ?? 0,
                                  ));
                            }
                          }, name: post.title??'', viewsCount: post.viewsCount??0,

                          // Handle if video is null
                        );
                      }).toList() ??
                      [],
                );
              } else if (controller.isDataFetched.value) {
                return Center(
                  child: Text(
                    "No Stats available",
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
              return CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }
}
