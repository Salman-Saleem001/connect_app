import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:connect_app/controllers/mainScreen_controllers/home_page_cont.dart';
import 'package:connect_app/globals/video_view.dart';
import 'package:connect_app/models/posts_model.dart';
import 'package:connect_app/screens/main_screens/chat_view/chatScreen.dart';
import 'package:connect_app/screens/other_screens/add_post_screens/camera_screens.dart';
import 'package:connect_app/utils/login_details.dart';
import 'package:connect_app/utils/size_config.dart';
import 'package:connect_app/utils/text_styles.dart';

class HomePageFeed extends StatefulWidget {
  const HomePageFeed({super.key});

  @override
  State<HomePageFeed> createState() => _HomePageFeedState();
}

class _HomePageFeedState extends State<HomePageFeed> {
  var controller = Get.put(HomeFeedController());

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              PostModel selectedPostModel;
              bool isLoading;
              // Determine the content to display based on the selected category
              switch (controller.selectedCategory.value) {
                case 'Trending':
                  selectedPostModel = controller.trendingPosts;
                  isLoading = controller.fetchingTrending.value;
                  break;
                case 'Featured':
                  selectedPostModel = controller.featuredPosts;
                  isLoading = controller.fetchingFeatured.value;
                  break;
                case 'Events':
                  selectedPostModel = controller.eventPosts;
                  isLoading = controller.fetchingEvents.value;
                  break;
                case 'Recommended':
                default:
                  selectedPostModel = controller.recommendedPosts??PostModel(posts: []);
                  isLoading = controller.fetchingRecommended.value;
                  break;
              }

              // Display content based on the selected category
              return isLoading
                  ? const SizedBox.expand()
                  : selectedPostModel.posts?.isEmpty==true
                  ? Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'No Latest Videos',
                        style: subHeadingText().copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              )
                  : PageView.builder(
                                  onPageChanged: ((i) => controller.changePage(i)),
                                  scrollDirection: Axis.vertical,
                                  controller: controller.pageController,
                                  itemCount: selectedPostModel.posts!.length,
                                  itemBuilder: (context, index) {
                  Post? video = selectedPostModel.posts![index];

                  return SizedBox(
                    height: double.infinity,
                    child: Stack(
                      children: [
                        VideoView(
                          url: video.video ?? "",
                          id: video.id,
                          country: video.country,
                        ),
                        Positioned(
                          bottom: 20,
                          left: 11,
                          right: 70,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  '@${video.user?.firstName?.toLowerCase() ?? ''}',
                                  style: subHeadingText().copyWith(color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                video.info ?? '',
                                style: normalText(size: 12).copyWith(color: Colors.white),
                              ),
                              SizedBox(
                                height: ht(13),
                              ),
                              if (video.id != null)
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/ic_video_camera.png',
                                          height: 18,
                                          errorBuilder: (_, error, trace) {
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          video.title ?? '',
                                          style: normalText(size: 12).copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        GetBuilder<HomeFeedController>(builder: (value) {
                          return Positioned(
                            top: 252,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset('assets/images/kora_logo.png',scale: 2.2,),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      value.toggle(video.id??0);
                                      video.isLiked= !(video.isLiked??false);
                                      if(video.isLiked??false){
                                        video.likesCount= (video.likesCount??0)+1;
                                      }
                                      value.update();
                                    },
                                    child: Image.asset(
                                      'assets/images/ic_heart.png',
                                      height: 40,
                                      color: (video.isLiked??false) ? Colors.red : Colors.white,
                                    )),
                                Text(
                                  "${(video.likesCount ?? 0)} Likes",
                                  style: normalText().copyWith(color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Opacity(
                                  opacity: video.userId == Get.find<UserDetail>().userData.user!.id
                                      ? 0.4
                                      : 1,
                                  child: GestureDetector(
                                      onTap: ()async {
                                                    if ((video.userId ?? 0) !=
                                                        (Get.find<UserDetail>()
                                                                .userData
                                                                .user
                                                                ?.id ??
                                                            0)) {

                                                      Get.to(() =>
                                                          ChatDetailScreenNew(
                                                            secondUserId:
                                                                (video.userId ??
                                                                        0)
                                                                    .toString(),
                                                            userName: video.user!.firstName?.toLowerCase(),
                                                            tags: video.tags,
                                                            videoId: video.id,
                                                            description: video.info,
                                                            userAvatar: video.user?.avatar,
                                                          ));
                                                    }
                                                  },
                                                  child: Image.asset(
                                                    'assets/images/ic_comments.png',
                                                    height: 34,
                                                    color: Colors.white,
                                                  )),
                                            ),
                                            Text(
                                              "Chats",
                                              style: normalText().copyWith(
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            InkWell(
                                                onTap: () async {
                                                  final result =
                                                      await Share.share(
                                                          video.video ?? "");

                                      if (result.status == ShareResultStatus.success) {
                                        debugPrint('Thank you for sharing my website!');
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/images/ic_share.png',
                                      height: 25,
                                      color: Colors.white,
                                    )),
                                Text(
                                  "Share",
                                  style: normalText().copyWith(
                                      color: Colors.white),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          );
                        }),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 20,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Get.to(() => CameraScreen(cameras: controller.cameras));
                              },
                              child: Container(
                                height: 68,
                                width: 68,
                                decoration: BoxDecoration(
                                    color: const Color(0xffE92A4F),
                                    borderRadius: BorderRadius.circular(80)),
                                child: const Icon(
                                  Icons.add,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                                  },
                                );
            }),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Obx(
                        () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            controller.selectedCategory.value = 'Recommended';
                            controller.getRecommendedContent();
                          },
                          child: Text(
                            'Recommended',
                            style: subHeadingText(
                              color: controller.selectedCategory.value == 'Recommended'
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () {
                            controller.selectedCategory.value = 'Trending';
                            controller.getTrendingContent();
                          },
                          child: Text(
                            'Trending',
                            style: subHeadingText(
                              color: controller.selectedCategory.value == 'Trending'
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () {
                            controller.selectedCategory.value = 'Featured';
                            controller.getFeaturedContent();
                          },
                          child: Text(
                            'Featured',
                            style: subHeadingText(
                              color: controller.selectedCategory.value == 'Featured'
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () {
                            controller.selectedCategory.value = 'Events';
                            controller.getEventContent();
                          },
                          child: Text(
                            'Events',
                            style: subHeadingText(
                              color: controller.selectedCategory.value == 'Events'
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }
}
