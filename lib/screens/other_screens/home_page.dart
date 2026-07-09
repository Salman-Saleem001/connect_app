import 'package:connect_app/controllers/mainScreen_controllers/home_page_cont.dart';
import 'package:connect_app/globals/video_view.dart';
import 'package:connect_app/models/posts_model.dart';
import 'package:connect_app/screens/main_screens/chat_view/chat_screen.dart';
import 'package:connect_app/screens/other_screens/add_post_screens/camera_screens.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/login_details.dart';
import 'package:connect_app/utils/size_config.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/show_case_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../controllers/mainScreen_controllers/navbar_controller.dart';
import '../../globals/network_image.dart';
import '../../widgets/report_widget.dart';

class HomePageFeed extends StatelessWidget {
  const HomePageFeed({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var controller = Get.put(HomeFeedController());
    var navController = Get.put(NavBarController());
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              PostModel? selectedPostModel;
              bool isLoading;
              // Determine the content to display based on the selected category
              switch (controller.selectedCategory.value) {
                case 'My feed':
                  controller.featuredPosts.posts?.clear();
                  controller.recommendedPosts.posts?.clear();
                  selectedPostModel = controller.trendingPosts;
                  isLoading = controller.fetchingTrending.value;
                  break;
                case 'Trending':
                  controller.trendingPosts.posts?.clear();
                  controller.recommendedPosts.posts?.clear();
                  selectedPostModel = controller.featuredPosts;
                  isLoading = controller.fetchingFeatured.value;
                  break;
                default:
                  controller.trendingPosts.posts?.clear();
                  controller.featuredPosts.posts?.clear();
                  selectedPostModel = controller.recommendedPosts;
                  isLoading = controller.fetchingRecommended.value;
                  break;
              }

              // Display content based on the selected category
              return isLoading
                  ? const SizedBox.expand()
                  : selectedPostModel.posts?.isEmpty == true
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
                          itemCount: selectedPostModel.posts?.length,
                          itemBuilder: (context, index) {
                            Post? video = selectedPostModel?.posts?[index];
                            return Stack(
                              children: [
                                VideoView(
                                  url: video?.video ?? "",
                                  id: video?.id,
                                  fit: BoxFit.cover,
                                  // country: video.country,
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
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(50),
                                              child: NetworkImageCustom(
                                                image: video?.user?.avatar ?? '',
                                                fit: BoxFit.cover,
                                                height: 50,
                                                width: 50,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              '@${video?.user?.firstName?.toLowerCase() ?? ''}',
                                              style: subHeadingText().copyWith(color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          video?.info ?? '',
                                          style: normalText(size: 12).copyWith(color: Colors.white),
                                        ),
                                      ),
                                      if (video?.id != null)
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
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
                                                  video?.title ?? '',
                                                  style: normalText(size: 12).copyWith(color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      SizedBox(
                                        height: ht(30),
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
                                            child: Image.asset(
                                              'assets/images/kora_logo.png',
                                              scale: 22.0,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            value.toggle(video?.id ?? 0);
                                            video?.isLiked = !(video.isLiked ?? false);
                                            if (video?.isLiked ?? false) {
                                              video?.likesCount = (video.likesCount ?? 0) + 1;
                                            }
                                            value.update();
                                          },
                                          child: AppShowCaseWidget(
                                            globalKey: navController.likeButton,
                                            title: 'Like Button',
                                            description: "Hit the Like button to like the video",
                                            child: Image.asset(
                                              'assets/images/ic_heart.png',
                                              height: 40,
                                              color: (video?.isLiked ?? false) ? Colors.red : Colors.white,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${(video?.likesCount ?? 0)} Likes",
                                          style: normalText().copyWith(color: Colors.white),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Opacity(
                                          opacity: video?.userId == Get.find<UserDetail>().userData.user!.id ? 0.4 : 1,
                                          child: GestureDetector(
                                              onTap: () async {
                                                if ((video?.userId ?? 0) !=
                                                    (Get.find<UserDetail>().userData.user?.id ?? 0)) {
                                                  Get.to(() => ChatDetailScreenNew(
                                                        secondUserId: (video?.userId ?? 0).toString(),
                                                        userName: video?.user?.firstName?.toLowerCase(),
                                                        tags: video?.tags,
                                                        videoId: video?.id,
                                                        description: video?.info,
                                                        userAvatar: video?.user?.avatar,
                                                        bio: video?.user?.bio ?? '',
                                                      ));
                                                }
                                              },
                                              child: AppShowCaseWidget(
                                                globalKey: navController.commentButton,
                                                title: 'Connect with Friends',
                                                description:
                                                    " Connect with friends by sharing the video and getting feedback",
                                                child: Image.asset(
                                                  'assets/images/ic_comments.png',
                                                  height: 34,
                                                  color: Colors.white,
                                                ),
                                              )),
                                        ),
                                        Text(
                                          "Connect",
                                          style: normalText().copyWith(color: Colors.white),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        InkWell(
                                            onTap: () async {
                                              final result = await SharePlus.instance
                                                  .share(ShareParams(uri: Uri.tryParse(video?.video ?? "")));

                                              if (result.status == ShareResultStatus.success) {
                                                debugPrint('Thank you for sharing my website!');
                                              }
                                            },
                                            child: AppShowCaseWidget(
                                              globalKey: navController.shareButton,
                                              title: 'Share with others',
                                              description:
                                                  'Share the video outside the app with others and get feedback',
                                              child: Image.asset(
                                                'assets/images/ic_share.png',
                                                height: 25,
                                                color: Colors.white,
                                              ),
                                            )),
                                        Text(
                                          "Share",
                                          style: normalText().copyWith(color: Colors.white),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (_) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      spacing: 5,
                                                      children: [
                                                        Text(
                                                          "Actions",
                                                          style: headingText(size: 20, color: AppColors.bgGrey),
                                                        ),
                                                        SizedBox(
                                                          height: .5,
                                                          width: double.infinity,
                                                          child: ColoredBox(color: AppColors.bgGrey),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                            showModalBottomSheet(
                                                                context: context,
                                                                isScrollControlled: true,
                                                                builder: (sheetContext) {
                                                                  return ReportWidget(
                                                                    onSubmit: (String val) {
                                                                      controller
                                                                          .reportPost(
                                                                              postId: video?.id ?? 0, reason: val)
                                                                          .then((val) {
                                                                        if (val) {
                                                                          switch (controller.selectedCategory.value) {
                                                                            case 'My feed':
                                                                              controller.trendingPosts.posts
                                                                                  ?.removeAt(index);
                                                                              selectedPostModel =
                                                                                  controller.trendingPosts;
                                                                              break;
                                                                            case 'Trending':
                                                                              controller.featuredPosts.posts
                                                                                  ?.removeAt(index);
                                                                              selectedPostModel =
                                                                                  controller.featuredPosts;
                                                                              break;
                                                                            default:
                                                                              controller.recommendedPosts.posts
                                                                                  ?.removeAt(index);
                                                                              selectedPostModel =
                                                                                  controller.recommendedPosts;
                                                                              break;
                                                                          }
                                                                        }
                                                                      });
                                                                    },
                                                                  );
                                                                });
                                                          },
                                                          child: Row(
                                                            spacing: 10,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.report_gmailerrorred,
                                                                color: AppColors.redColor,
                                                                size: 26,
                                                              ),
                                                              Text(
                                                                "Report",
                                                                style: subHeadingText(size: 18)
                                                                    .copyWith(color: AppColors.bgGrey),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: .1,
                                                          width: double.infinity,
                                                          child: ColoredBox(color: AppColors.bgGrey),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            controller
                                                                .blockUser(
                                                              userId: video?.userId ?? 0,
                                                            )
                                                                .then((val) {
                                                              if (val) {
                                                                switch (controller.selectedCategory.value) {
                                                                  case 'My feed':
                                                                    controller.trendingPosts.posts?.removeAt(index);
                                                                    selectedPostModel = controller.trendingPosts;
                                                                    break;
                                                                  case 'Trending':
                                                                    controller.featuredPosts.posts?.removeAt(index);
                                                                    selectedPostModel = controller.featuredPosts;
                                                                    break;
                                                                  default:
                                                                    controller.recommendedPosts.posts?.removeAt(index);
                                                                    selectedPostModel = controller.recommendedPosts;
                                                                    break;
                                                                }
                                                              }
                                                            });
                                                          },
                                                          child: Row(
                                                            spacing: 10,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.block,
                                                                color: AppColors.redColor,
                                                                size: 24,
                                                              ),
                                                              Text(
                                                                "Block",
                                                                style: subHeadingText(size: 18)
                                                                    .copyWith(color: AppColors.bgGrey),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          child: AppShowCaseWidget(
                                            globalKey: navController.moreButton,
                                            title: 'More Options',
                                            description: 'Report inappropriate content or block users',
                                            child: Icon(
                                              Icons.more_horiz,
                                              color: AppColors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
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
                            controller.selectedCategory.value = 'My feed';
                            controller.getTrendingContent();
                          },
                          child: AppShowCaseWidget(
                            globalKey: navController.feedTab,
                            title: 'Your Personal Feed',
                            tooltipPosition: TooltipPosition.bottom,
                            description: 'View content tailored to your interests and connections',
                            child: Text(
                              'My feed',
                              style: subHeadingText(
                                color: controller.selectedCategory.value == 'My feed' ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () {
                            controller.selectedCategory.value = 'Trending';
                            controller.getFeaturedContent();
                          },
                          child: AppShowCaseWidget(
                            globalKey: navController.trendingTab,
                            title: 'Explore Trending Content',
                            tooltipPosition: TooltipPosition.bottom,
                            description: 'Discover the most popular and trending videos right now',
                            child: Text(
                              'Trending',
                              style: subHeadingText(
                                color: controller.selectedCategory.value == 'Trending' ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () {
                            controller.selectedCategory.value = 'Recommended';
                            controller.getRecommendedContent();
                          },
                          child: AppShowCaseWidget(
                            globalKey: navController.recommendedTab,
                            title: 'Explore Recommended Content',
                            tooltipPosition: TooltipPosition.bottom,
                            description: 'Discover personalized content recommendations based on your interests',
                            child: Text(
                              'Recommended',
                              style: subHeadingText(
                                color: controller.selectedCategory.value == 'Recommended' ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Get.off(() => CameraScreen(cameras: controller.cameras));
                  },
                  child: AppShowCaseWidget(
                    globalKey: navController.createVideo,
                    tooltipPosition: TooltipPosition.top,
                    title: 'Create Your Video',
                    description: 'Tap to start recording and sharing your content',
                    child: Container(
                      height: 68,
                      width: 68,
                      decoration:
                          BoxDecoration(color: const Color(0xffE92A4F), borderRadius: BorderRadius.circular(80)),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
