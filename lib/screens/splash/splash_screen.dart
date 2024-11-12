import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connect_app/globals/adaptive_helper.dart';
import 'package:connect_app/globals/container_properties.dart';
import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/screens/auth_screens/login.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/primary_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<Map> data = [
    {
      'title': 'Dream. Connect. Do.',
      'subtitle': 'Connect to the things you want, need & love',
      'image': 'assets/images/bg_image1.png'
    },
    {
      'title': 'Dream. Connect. Do.',
      'subtitle': 'Connect to the things you want, need & love',
      'image': 'assets/images/bg_image.png'
    },
  ];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (i) => setState(() {
              index = i;
            }),
            children: List.generate(
                data.length,
                (index) => SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Image.asset(
                        data[index]['image'],
                        fit: BoxFit.cover,
                      ),
                    )),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/kora_logo.png',
                      ),
                    ],
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          data[index]['title'],
                          textAlign: TextAlign.center,
                          style: headingText(color: Colors.white, size: 28),
                        ),
                        Text(
                          data[index]['subtitle'],
                          textAlign: TextAlign.center,
                          style: regularText(color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ),
                  40.hp,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        data.length,
                        (i) => Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                decoration:
                                    ContainerProperties.simpleDecoration(
                                        color: Color(0xffD9D9D9)
                                            .withOpacity(index == i ? 1 : 0.4),
                                        radius: 60),
                                height: 16,
                                width: 16,
                              ),
                            )),
                  ),
                  43.hp,
                  PrimaryButton(
                    label: 'Get Started',
                    onPress: () {
                      Get.off(() => LoginScreen());
                    },
                    whiteButton: false,
                  ),
                  SizedBox(
                    height: ht(40),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
