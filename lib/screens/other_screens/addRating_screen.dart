import 'package:connect_app/controllers/mainScreen_controllers/home_page_cont.dart';
import 'package:connect_app/utils/app_colors.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/primary_button.dart';
import 'package:connect_app/widgets/text_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../main_screens/chat_view/chat_screen.dart';

// ignore: must_be_immutable
class RatingScreen extends StatelessWidget {

  const RatingScreen({super.key, this.userAvatar,this.videoId, this.name, this.bio});
  final String? userAvatar,name, bio;
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 200),
                Row(
                  children: [
                    UserAvatarImage(userAvatar: userAvatar,radius: 40,).paddingOnly(left: 0),
                    SizedBox(width: 10,),
                    Text( name??'Peter_115',
                        style: regularText(size: 18, color: AppColors.lightText)),
                  ],
                ),
                const SizedBox(height: 16),
                if((bio?? '').isNotEmpty)...[
                  Text(bio?? '',
                      style: normalText(size: 14, color: AppColors.txtGrey)).paddingOnly(left: 150),
                  const SizedBox(height: 16),
                ],
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
        ],
      ),
    );
  }
}
