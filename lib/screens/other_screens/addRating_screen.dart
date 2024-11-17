import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:connect_app/controllers/mainScreen_controllers/home_page_cont.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/primary_button.dart';
import 'package:connect_app/widgets/text_fields.dart';

import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../main_screens/chat_view/chatScreen.dart';

// ignore: must_be_immutable
class RatingScreen extends StatelessWidget {

  const RatingScreen({super.key, this.userAvatar,this.videoId});
  final String? userAvatar;
  final int? videoId;
  @override
  Widget build(BuildContext context) {
    var homeController= Get.put(HomeFeedController());
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: customAppBarTransparent(title: 'Rate'),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height:
                    210, // Adjust this value to control the background image height
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_image_small.jpeg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Expanded(child: Container(color: Colors.transparent)),
            ],
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 110),
                  UserAvatarImage(userAvatar: userAvatar,radius: 60,),
                  const SizedBox(height: 16),
                  Text('Peter_115',
                      style: regularText(size: 18, color: AppColors.lightText)),
                  Text('Fitness Coach',
                      style: normalText(size: 14, color: AppColors.txtGrey)),
                  const SizedBox(height: 16),
                  Padding(
                      padding: const EdgeInsets.only(right: 0, left: 0),
                      child: Divider(
                        color: AppColors.borderColor,
                        thickness: 0.5,
                      )),
                  const SizedBox(height: 16),
                  Text('Your overall rating',
                      style: regularText(size: 15, color: AppColors.textLight)),
                  RatingBar.builder(
                    initialRating: 0,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      homeController.rating=rating;
                      debugPrint(homeController.rating.toString());
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                      padding: const EdgeInsets.only(right: 0, left: 0),
                      child: Divider(
                        color: AppColors.borderColor,
                        thickness: 0.5,
                      )),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Add detailed review',
                        style: subHeadingText(
                            size: 20, color: AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFieldMulti(
                    onchange: (val){
                      homeController.reviewDescrioption=val;
                    },
                    lines: 5,
                    textInputFormatter: [],
                    hint: 'Enter here',
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(label: 'Submit', onPress: () {
                    if(homeController.rating==null|| homeController.reviewDescrioption?.trim().isEmpty==true){
                      Global.showToastAlert(
                          context: Get.overlayContext!,
                          strTitle: "Message",
                          strMsg: 'Please fill the form completely',
                          toastType: TOAST_TYPE.toastError);
                    }else{
                      homeController.sendReview(videoId??0).then((val){
                        if(val){
                          Get.back();
                        }
                      });
                    }
                  })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
