import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controllers/password_controller.dart';
import '../../controllers/mainScreen_controllers/navbar_controller.dart';
import '../../controllers/mainScreen_controllers/profile_controller.dart';
import '../../globals/loader/three_bounce.dart';
import '../../utils/app_colors.dart';
import '../../utils/login_details.dart';
import '../../utils/size_config.dart';
import '../../utils/text_styles.dart';
import '../../widgets/appbars.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_fields.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({Key? key}) : super(key: key);

  @override
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  var controller = Get.put(ForgetPasswordController());

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: customAppBar(),
      body: GetBuilder<ForgetPasswordController>(builder: (value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 5),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ht(33)),
                    Text(
                      'Create new password',
                      style: headingText(size: 24),
                    ),
                    SizedBox(height: ht(18)),
                    Text(
                      "Your new password must be unique from your previous passwords.",
                      style: regularText(size: 16, color: AppColors.bgGrey),
                    ),
                    SizedBox(height: ht(57)),
                    customTextFiled(
                        controller.passwordController,
                        controller.passwordNode,
                        [],
                        SizedBox(
                          height: 50,
                          width: 40,
                          child: Center(
                            child: Image.asset(
                              'assets/images/ic_lock.png',
                              height: 18,
                              color: AppColors.bgGrey,
                            ),
                          ),
                        ),
                        hint: 'Password',
                        obscure: controller.obscure,
                        suffixIcon: GestureDetector(
                            onTap: () {
                              controller.obscure = !controller.obscure;
                              controller.update();
                            },
                            child: Icon(
                              controller.obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.bgGrey,
                            ))),
                    SizedBox(height: ht(15)),
                    customTextFiled(
                        controller.confirmPasswordController,
                        controller.confirmPasswordNode,
                        [],
                        SizedBox(
                          height: 50,
                          width: 40,
                          child: Center(
                            child: Image.asset(
                              'assets/images/ic_lock.png',
                              height: 18,
                              color: AppColors.bgGrey,
                            ),
                          ),
                        ),
                        hint: 'Password',
                        obscure: controller.obscure,
                        suffixIcon: GestureDetector(
                            onTap: () {
                              controller.confirmObscure = !controller.confirmObscure;
                              controller.update();
                            },
                            child: Icon(
                              controller.confirmObscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.bgGrey,
                            ))),
                    SizedBox(height: ht(30)),
                    PrimaryButton(
                        label: 'Reset Password',
                        onPress: () {
                          controller.changePassword();
                          var nav= Get.put(NavBarController());
                          var profile= Get.put(ProfileController());
                          profile.clear();
                          profile.dispose();
                          nav.clear();
                          Get.find<UserDetail>().logout();
                        }),
                  ],
                ),
              ),
              GetBuilder<ForgetPasswordController>(builder: (value) {
                return Visibility(
                  visible: value.isLoading,
                  child: Container(
                    color: Colors.white60,
                    height: double.infinity,
                    width: double.infinity,
                    child: Center(
                        child:
                            SpinKitThreeBounce(color: AppColors.primaryColor)),
                  ),
                );
              })
            ],
          ),
        );
      }),
    );
  }
}
