import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controllers/sign_up_controller.dart';
import '../../globals/adaptive_helper.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_fields.dart';
import 'login.dart';
import 'otp_verification.dart';


class ForgetPassword extends StatelessWidget {
  const ForgetPassword({super.key,  this.fromChangePassword=false});

  final bool fromChangePassword;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // backgroundColor: AppColors.scaffoldBackgroundColor,
      // appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          // padding: EdgeInsets.symmetric(horizontal: wd(30), vertical: ht(15)),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/kora_logo.png',
                  width: wd(150),
                  height: ht(180),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fromChangePassword?'Change Password!':'Forgot Password!',
                      style: headingText(size: 28),
                    ),
                    SizedBox(
                      height: ht(8),
                    ),
                    Text(
                      'Glad to see you again!',
                      style: normalText(size: 16),
                    ),
                    SizedBox(
                      height: ht(34),
                    ),
                  ]),
            ),
            Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                children: [
                  SizedBox(
                    height: ht(20),
                  ),
                  GetBuilder<SignUpController>(
                    init: SignUpController(),
                      builder: (value) {
                    return Column(
                      children: [
                        _userSignUp(value),
                        SizedBox(
                          height: ht(20),
                        ),
                        PrimaryButton(
                          label: 'Submit',
                          onPress: () {
                            Get.to(() => OTPScreen(
                                  otp: '0000',
                                ),

                            );
                            // controller.resestPassowrd();
                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: ht(40)),
            if(!fromChangePassword)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Remember your password? ", style: normalText()),
                InkWell(
                  onTap: () {
                    Get.off(LoginScreen());
                  },
                  child: Text("login",
                      style: subHeadingText(color: AppColors.primaryColor)),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _userSignUp(SignUpController value) {
    var controller = Get.put(SignUpController());
    return Column(
      children: [
        customTextFiled(
            controller.controllerEmail,
            controller.focusNodeEmail,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_email.png',
                  height: 13,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'Enter your email'),
      ],
    );
  }
}
