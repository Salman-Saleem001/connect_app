import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connect_app/controllers/mainScreen_controllers/home_page_cont.dart';
import 'package:connect_app/controllers/searchScreen_controller.dart';
import 'package:connect_app/globals/adaptive_helper.dart';
import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/globals/global.dart';
import 'package:connect_app/globals/radioGroups.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/login_details.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';

import '../../controllers/mainScreen_controllers/navbar_controller.dart';
import '../../globals/network_image.dart';
import '../../models/posts_model.dart';

// ignore: must_be_immutable
class SearchScreen extends StatelessWidget {
  var controller= Get.put(SearchScreenController());
  var homeController = Get.put(HomeFeedController());
  var navBar = Get.put(NavBarController());

  SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: customAppBar(title: 'Search', backButton: false),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GetBuilder(
                  init: SearchScreenController(),
                    builder: (SearchScreenController searchController){
                  return TextField(
                    focusNode: searchController.controllerNode,
                    cursorColor: AppColors.primaryColor,
                    decoration: InputDecoration(
                      suffixIcon: searchController.isSearchOn.value? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                          onTap: (){
                            searchController.changeSearch(false);
                            searchController.controllerNode.unfocus();
                            searchController.isSearchCompleted.value=false;
                          },
                          child: Icon(Icons.cancel, color: AppColors.primaryColor,)) :const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(color: AppColors.white, width: .1)
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey, width: .5)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: AppColors.primaryColor)),
                        hintText: 'Search'),
                    onChanged: (String val) {
                      if (val.length > 3) {
                        searchController.getSearchData(val);
                      }

                      if(val.isEmpty){
                        searchController.recommendedPosts.value.posts?.clear();
                        searchController.update();
                      }
                    },
                    onTap: () {
                      searchController.changeSearch(true);
                    },
                  );
                }),
                10.hp,
                Expanded(
                  child: GetBuilder(
                      builder: (SearchScreenController searchController) {
                    if (searchController.isSearchOn.value) {
                      if (!searchController.isSearchCompleted.value&& searchController
                              .recommendedPosts.value.posts?.isEmpty ==
                          true) {
                        return ListView(
                          children: [
                            const SizedBox(height: 5),
                            Divider(
                              color: AppColors.borderlight,
                              thickness: 0.5,
                            ),
                            _buildSectionTitle('Search History'),
                            const SizedBox(height: 10),
                            _buildChips(controller.selectedPreferences, [
                              'Movies',
                              'Games',
                              'Fun',
                              'Recipes',
                              'Matches',
                              'Latest'
                            ]),
                            const SizedBox(height: 15),
                            Divider(
                              color: AppColors.borderlight,
                              thickness: 0.5,
                            ),
                            _buildSectionTitle('Trending Searches'),
                            const SizedBox(height: 10),
                            const SizedBox(height: 16),
                            _buildChips(controller.selectedPreferences, [
                              'Movies',
                              'Games',
                              'Fun',
                              'Recipes',
                              'Matches',
                              'Latest'
                            ]),
                            const SizedBox(height: 60),
                          ],
                        );
                      } else {
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          itemBuilder: (_, index) {
                            if(searchController
                                .recommendedPosts.value.posts?.isEmpty==true){
                              return const Center(child: Text('No Result Found',style: TextStyle(color: Colors.black),));
                            }
                            return PostTile(
                                selectedPostModel:
                                    searchController.recommendedPosts.value,

                                index: index,
                                onTap: () {
                                  homeController.selectedCategory.value='Recommended';
                                  homeController.recommendedPosts?.posts?.clear();
                                  homeController.recommendedPosts= searchController.recommendedPosts.value;
                                  navBar.changeTab(0);
                                  homeController.pageController.animateToPage(
                                      index,
                                      duration: const Duration(
                                          milliseconds: 300),
                                      curve: Curves.ease);
                                }, onFollowIconPressed: () {
                              if(searchController.recommendedPosts.value.posts?[index].user?.followed=='notFollowed'){
                                searchController.followRequest(searchController.recommendedPosts.value.posts?[index].userId??0).then((val){
                                  if(val){
                                    searchController.recommendedPosts.value.posts?[index].user?.followed='requested';
                                    searchController.update();
                                  }
                                });
                              }else if(searchController.recommendedPosts.value.posts?[index].user?.followed=='requested'){
                                Global.showToastAlert(context: context, strMsg: 'Your request is not approved yet.', toastType: TOAST_TYPE.toastInfo);
                              }else{
                                searchController.unFollowRequest(searchController.recommendedPosts.value.posts?[index].userId??0).then((val){
                                  if(val){
                                    searchController.recommendedPosts.value.posts?[index].user?.followed='notFollowed';
                                    searchController.update();
                                  }
                                });
                              }
                            },);
                          },
                          itemCount: (searchController
                                  .recommendedPosts.value.posts?.length ??
                              0)==0? 1: (searchController
                              .recommendedPosts.value.posts?.length ??
                              0),
                        );
                      }
                    } else {
                      return Column(
                        children: [
                          TabBar(
                            tabs: const [
                              Tab(
                                text: 'Recommended',
                              ),
                              Tab(
                                text: 'Trending',
                              ),
                              Tab(
                                text: 'Featured',
                              ),
                              Tab(
                                text: 'Events',
                              )
                            ],
                            labelPadding: EdgeInsets.zero,
                            labelColor: AppColors.primaryColor,
                            indicatorColor: AppColors.primaryColor,
                            onTap: (index) {
                              debugPrint('Here is the index==>$index');
                              if (index == 1) {
                                homeController.selectedCategory.value =
                                    'Trending';
                                if (homeController
                                        .trendingPosts.posts?.isEmpty ==
                                    true) {
                                  homeController.getTrendingContent();
                                }
                              } else if (index == 2) {
                                homeController.selectedCategory.value =
                                    'Featured';
                                if (homeController
                                        .featuredPosts.posts?.isEmpty ==
                                    true) {
                                  homeController.getFeaturedContent();
                                }
                              } else if (index == 3) {
                                homeController.selectedCategory.value = 'Event';
                                if (homeController.eventPosts.posts?.isEmpty ==
                                    true) {
                                  homeController.getEventContent();
                                }
                              } else {
                                homeController.selectedCategory.value =
                                    'Recommended';
                                if (homeController
                                        .recommendedPosts?.posts?.isEmpty ==
                                    true) {
                                  homeController.getContent();
                                }
                              }
                            },
                          ),
                          Expanded(child: GetBuilder(
                              builder: (HomeFeedController homeFeed) {
                            PostModel selectedPostModel;
                            bool isLoading;
                            switch (homeFeed.selectedCategory.value) {
                              case 'Trending':
                                selectedPostModel = homeFeed.trendingPosts;
                                isLoading = homeFeed.fetchingTrending.value;
                                break;
                              case 'Featured':
                                selectedPostModel = homeFeed.featuredPosts;
                                isLoading = homeFeed.fetchingFeatured.value;
                                break;
                              case 'Events':
                                selectedPostModel = homeFeed.eventPosts;
                                isLoading = homeFeed.fetchingEvents.value;
                                break;
                              case 'Recommended':
                              default:
                                selectedPostModel = homeFeed.recommendedPosts??PostModel();
                                isLoading = homeFeed.fetchingRecommended.value;
                                break;
                            }
                            if (isLoading) {
                              return CircularProgressIndicator(
                                color: AppColors.primaryColor,
                              );
                            } else {
                              return ListView.builder(
                                  itemBuilder: (_, index) {
                                    return PostTile(
                                      selectedPostModel: selectedPostModel,
                                      index: index,
                                      onTap: () {
                                        navBar.changeTab(0);
                                        homeFeed.pageController.animateToPage(
                                            index,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.ease);
                                      }, onFollowIconPressed: () {
                                      if(selectedPostModel.posts?[index].user?.followed=='notFollowed'){
                                        searchController.followRequest(selectedPostModel.posts?[index].userId??0).then((val){
                                          if(val){
                                            selectedPostModel.posts?[index].user?.followed='requested';
                                            searchController.update();
                                          }
                                        });

                                      }else if(selectedPostModel.posts?[index].user?.followed=='requested'){
                                        Global.showToastAlert(context: context, strMsg: 'Your request is not approved yet.', toastType: TOAST_TYPE.toastInfo);
                                      }else{
                                        searchController.unFollowRequest(selectedPostModel.posts?[index].userId??0).then((val){
                                          if(val){
                                            selectedPostModel.posts?[index].user?.followed='notFollowed';
                                            searchController.update();
                                          }
                                        });
                                      }
                                    },
                                    );
                                  },
                                  itemCount:
                                      selectedPostModel.posts?.length ?? 0);
                            }
                          }))
                        ],
                      );
                    }
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: headingText(
            size: 20,
          )),
    );
  }

  Widget _buildChips(controller, List<String> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetBuilder<SearchScreenController>(
          builder: (logic) {
            return RadioButtonTileGroup<String>(
              selectedValues: logic.selectedPreferences,
              onChanged: (newValues) {
                logic.selectedPreferences = newValues;
               if(newValues.isNotEmpty){
                 logic.getSearchData(newValues.last);
               }
                logic.update();
              },

              selectedTileColor: AppColors.primaryColorBottom,
              // Customize selected tile color
              borderWidth: 1.0,
              // Customize border width
              borderRadius: 100,
              // Customize border radius
              tilesPerRow: 4,
              // Set number of tiles per row
              tiles: labels
                  .map((label) => RadioButtonTile(title: label, value: label))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class PostTile extends StatelessWidget {
  const PostTile({
    super.key,
    required this.selectedPostModel,
    required this.index,
    required this.onTap, required this.onFollowIconPressed,
  });

  final PostModel selectedPostModel;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onFollowIconPressed;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: NetworkImageCustom(
                  image: selectedPostModel.posts?[index].user?.avatar,
                  fit: BoxFit.cover,
                  height: 60,
                  width: 60,
                ),
              ),
              5.wp,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '@${selectedPostModel.posts?[index].user?.username ?? "ben_offiicial99"}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    ' ${(selectedPostModel.posts?[index].state ?? 'California').capitalizeFirst}, ${(selectedPostModel.posts?[index].country ?? 'USA').capitalizeFirst}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.txtGrey),
                  ),
                ],
              ),
              const Spacer(),
              if(selectedPostModel.posts?[index].userId != Get.find<UserDetail>().userData.user?.id)
              IconButton(
                  onPressed: onFollowIconPressed,
                  color: AppColors.primaryColor,
                  icon:  selectedPostModel.posts?[index].user?.followed!='notFollowed'? const Icon(Icons.person_add_disabled_outlined) :const Icon(Icons.person_add_alt_outlined)),
            ],
          ),
          20.hp,
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const ColoredBox(
                  color: Colors.black,
                  child: SizedBox(
                    height: 300,
                    width: double.maxFinite,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: ColoredBox(
                    color: AppColors.primaryColor,
                    child: Icon(
                      Icons.play_arrow,
                      color: AppColors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Text(
                  '${selectedPostModel.posts?[index].viewsCount ?? 0} Views',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
          5.hp,
          Text(
            selectedPostModel.posts?[index].info ??
                'Anyone heading to Phoenix Game Tonight?',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          Builder(builder: (context) {
            String tags = '';
            selectedPostModel.posts?[index].tags?.forEach((element) {
              tags = tags + element;
            });
            return Text(
              tags,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            );
          }),
          Row(
            children: [
              ...List.generate(
                  5,
                  (index1) => const Icon(
                        Icons.star,
                        color: Color(0xffFFB400),
                      )),
              const Spacer(),
              Text(
                'Expires in ${DateTime.parse(selectedPostModel.posts?[index].expiryDate ?? DateTime.now().toIso8601String()).difference(DateTime.now()).inDays} days',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.txtGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
