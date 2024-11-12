import 'package:connect_app/screens/auth_screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controllers/login_controller.dart';
import '../../globals/adaptive_helper.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_fields.dart';
import 'forget_password.dart';



class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
        child: ListView(
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
            Container(
              padding: const EdgeInsets.only(right: 20, left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back',
                    style: headingText(size: 26),
                  ),
                  // SizedBox(
                  //   height: ht(8),
                  // ),
                  Text(
                    'Glad to see you again',
                    style: normalText(size: 26),
                  ),
                  SizedBox(
                    height: ht(34),
                  ),
                  GetBuilder<LoginController>(builder: (value) {
                    return Column(
                      children: [
                        _userSignUp(value),
                        SizedBox(
                          height: ht(10),
                        ),
                        _rememberMeForgetPassword(),
                        SizedBox(
                          height: ht(20),
                        ),
                        PrimaryButton(
                          label: 'SIGN IN',
                          // whiteButton: true,
                          onPress: () {
                            controller.getLogin();
                          },
                        ),
                        const SizedBox(
                          height: 23,
                        ),
                        Text(
                          'or login with',
                          style:
                          regularText(color: AppColors.lightText, size: 12),
                        ),
                        const SizedBox(
                          height: 23,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SocialButton(onTap: (){},icon: const Icon(
                              Icons.facebook,
                              color: Colors.blue,
                            ),),
                            SocialButton(
                              onTap: (){
                                Get.to(() => const SignUpScreen());
                              },
                            ),
                            if(GetPlatform.isIOS)
                              SocialButton(onTap: (){},icon: const Icon(
                                Icons.apple,
                                color: Colors.black,
                              ),),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: regularText(
                                  color: AppColors.lightText, size: 12),
                            ),
                            InkWell(
                              onTap: () => Get.to(() => const SignUpScreen()),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  " Register Now",
                                  style: regularText(
                                      color: AppColors.primaryColorBottom,
                                      size: 12),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 20,
                            )
                          ],
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userSignUp(LoginController value) {
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
                ),
              ),
            ),
            hint: 'Email address'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            controller.controllerPassword,
            controller.focusNodePassword,
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
                  controller.obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.bgGrey,
                ))),
        SizedBox(
          height: ht(12),
        ),
      ],
    );
  }

  _rememberMeForgetPassword() => Row(
        children: [
          Expanded(child: Container()),
          InkWell(
            onTap: () => Get.to(() => const ForgetPassword()),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Forget Password?',
                style: regularText(size: 13, color: AppColors.borderColor),
              ),
            ),
          )
        ],
      );
}

class SocialButton extends StatelessWidget {
  const SocialButton({
    super.key, this.icon, required this.onTap,
  });

  final Widget? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border:
              Border.all(color: AppColors.lightBorder),
          borderRadius: BorderRadius.circular(15),
        ),
        // width: 55,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 20, horizontal: GetPlatform.isIOS? 50: 65),
          child: icon?? Image.asset(
            'assets/images/ic_google.png',
            fit: BoxFit.contain,
            scale: 1.2,
          ),
        ),
      ),
    );
  }
}
