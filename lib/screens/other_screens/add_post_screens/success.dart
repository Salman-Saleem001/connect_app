
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/primary_button.dart';

import '../../../controllers/mainScreen_controllers/home_page_cont.dart';

class SuccessUploaded extends StatefulWidget {
  const SuccessUploaded({
    super.key,
  });

  @override
  State<SuccessUploaded> createState() => _SuccessUploadedState();
}

class _SuccessUploadedState extends State<SuccessUploaded> {

  var getController = Get.put(HomeFeedController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            child: Column(
              children: [
                Expanded(
                    child: Image.asset(
                  width: double.infinity,
                  height: double.infinity,
                  'assets/images/bg_image1.png',
                  fit: BoxFit.cover,
                )),
                Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    width: double.infinity,
                    child: Column(
                      children: [
                        44.hp,
                        Text(
                          'Successful Upload',
                          style: headingText(color: Colors.black, size: 24),
                        ),
                        Text(
                          'Your Dream Connection starts Now',
                          style: regularText(size: 16, color: Colors.grey),
                        ),
                        50.hp,
                        PrimaryButton(
                            label: 'Continue',
                            onPress: () {
                              getController.getContent();
                              Get.back();
                            }),
                      ],
                    ))
              ],
            ),
          ),
          Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Dream. Connect. Do.',
                  style: headingText(size: 26, color: Colors.white),
                ),
              )),
        ],
      )),
    );
  }
}
