import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connect_app/controllers/mainScreen_controllers/home_page_cont.dart';
import 'package:connect_app/controllers/mainScreen_controllers/navbar_controller.dart';
import 'package:connect_app/controllers/mainScreen_controllers/profile_controller.dart';
import 'package:connect_app/globals/container_properties.dart';
import 'package:connect_app/screens/other_screens/home_page.dart';
import 'package:connect_app/screens/profile/profile_screen.dart';
import 'package:connect_app/screens/search/search_screen.dart';
import 'package:connect_app/utils/text_styles.dart';

import '../../controllers/searchScreen_controller.dart';
import '../../globals/adaptive_helper.dart';
import '../../utils/app_colors.dart';
import 'chat_view/all_chats.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen>
    with SingleTickerProviderStateMixin {
  var controller = Get.put(NavBarController());

  @override
  void initState() {
    controller.changeTab(0);
    super.initState();
    controller.animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavBarController>(
        init: NavBarController(),
        builder: (value) {
          return bottomScreen(value);
        });
  }

  Container bottomScreen(NavBarController value) {
    return Container(
      decoration: ContainerProperties.shadowDecoration(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        body: SafeArea(
          child: IndexedStack(
            index: value.currentIndex,
            children: [
              Visibility(
                maintainState: true,
                visible: value.currentIndex == 0,
                child: const HomePageFeed(),
              ),
              Visibility(
                maintainState: true,
                visible: value.currentIndex == 1,
                child: SearchScreen(),
              ),
              Visibility(
                visible: value.currentIndex == 2,
                child: const ChatScreen(),
                // child: Container(),
              ),
              Visibility(
                visible: value.currentIndex == 3,
                child: const ProfileScreen(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(left: wd(10), right: wd(10), top: 5),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            BoxShadow(
                color: AppColors.borderColor.withOpacity(0.2),
                offset: const Offset(0, -2),
                spreadRadius: 3,
                blurRadius: 5)
          ]),
          height: ht(60),
          child: Row(
            children: [
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  value.changeTab(0);
                  var homeController = Get.put(HomeFeedController());
                  homeController.selectedCategory.value = 'Recommended';
                  if (homeController.recommendedPosts?.posts?.isEmpty == true) {
                    homeController.getContent();
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  margin: _mar(),
                  padding: padd(),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/ic_home.png',
                        height: 25,
                        color: _iconColor(0, value),
                      ),
                      Expanded(
                        child: Text(
                          'Home',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: _iconColor(0, value)),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 4,
                        decoration: ContainerProperties.simpleDecoration(
                            color: _lineColor(0, value)),
                      )
                    ],
                  ),
                ),
              )),
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  value.changeTab(1);
                  var controller = Get.put(SearchScreenController());
                  if (controller.selectedPreferences.isNotEmpty) {
                    controller.selectedPreferences.clear();
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  // decoration: _dec(1, value),
                  margin: _mar(),
                  padding: padd(),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/ic_search.png',
                        height: 25,
                        color: _iconColor(1, value),
                      ),
                      Expanded(
                        child: Text(
                          'Search',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: _iconColor(1, value)),
                        ),
                      ),

                      Container(
                        width: 30,
                        height: 4,
                        decoration: ContainerProperties.simpleDecoration(
                            color: _lineColor(1, value)),
                      )
                    ],
                  ),
                ),
              )),
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  value.changeTab(2);
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  margin: _mar(),
                  padding: padd(),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/ic_message.png',
                        height: 25,
                        color: _iconColor(2, value),
                      ),
                      Expanded(
                        child: Text(
                          'Chats',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: _iconColor(2, value)),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 4,
                        decoration: ContainerProperties.simpleDecoration(
                            color: _lineColor(2, value)),
                      )
                    ],
                  ),
                ),
              )),
              Expanded(
                  child: GestureDetector(
                onTap: () {
                  value.changeTab(3);
                  var controller = Get.put(ProfileController());
                  if (controller.myPosts.value.posts?.isNotEmpty == true) {
                  } else {
                    controller.getMyOwnPost();
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  // decoration: _dec(2, value),
                  margin: _mar(),
                  padding: padd(),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/ic_person.png',
                        height: 25,
                        color: _iconColor(3, value),
                      ),
                      Expanded(
                        child: Text(
                          'Profile',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: _iconColor(3, value)),
                        ),
                      ),

                      Container(
                        width: 30,
                        height: 4,
                        decoration: ContainerProperties.simpleDecoration(
                            color: _lineColor(3, value)),
                      )
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle style(int i, NavBarController value) {
    return regularText(
        size: 10,
        color: controller.currentIndex != i
            ? HexColor('#667085')
            : AppColors.primaryColor);
  }

  EdgeInsets padd() => const EdgeInsets.symmetric(horizontal: 3);

  EdgeInsets _mar() => EdgeInsets.only(top: ht(5), bottom: 2);
  Color _iconColor(int index, NavBarController value) =>
      controller.currentIndex != index
          ? Colors.black.withOpacity(0.2)
          : AppColors.primaryColor;
  Color _lineColor(int index, NavBarController value) =>
      controller.currentIndex != index
          ? Colors.transparent
          : AppColors.primaryColor;
}

class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.primaryColor // Change this color to the desired color
      ..style = PaintingStyle.fill;

    double centerX = size.width / 2;
    double centerY = size.height / 2;

    double radius = size.width / 2;

    Path path = Path();

    for (int i = 0; i < 6; i++) {
      double angle =
          (pi / 3) * i - pi / 2; // Adjusted angle to start from the top
      double x = centerX + radius * cos(angle);
      double y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
