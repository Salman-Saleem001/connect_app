import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controllers/sign_up_controller.dart';
import '../../globals/adaptive_helper.dart';
import '../../globals/radioGroups.dart';
import '../../utils/app_colors.dart';
import '../../utils/text_styles.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_fields.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SignUpController controller =
      Get.put(SignUpController()); // Instantiate your controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome!',
                    style: headingText(size: 28),
                  ),
                  SizedBox(
                    height: ht(8),
                  ),
                  Text(
                    'Let’s get started!',
                    style: normalText(size: 16),
                  ),
                  SizedBox(
                    height: ht(34),
                  ),
                  GetBuilder<SignUpController>(builder: (value) {
                    return Column(
                      children: [
                        _userSignUp(value),
                        SizedBox(
                          height: ht(20),
                        ),
                        _preferences(value),
                        SizedBox(
                          height: ht(20),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.changeTerms();
                          },
                          child: Row(
                            children: [
                              GetBuilder<SignUpController>(builder: (value) {
                                return Container(
                                  margin: const EdgeInsets.only(left: 3),
                                  height: 20,
                                  width: 20,
                                  child: Checkbox(
                                      activeColor: AppColors.primaryColor,
                                      value: value.terms,
                                      onChanged: (check) =>
                                          controller.changeTerms()),
                                );
                              }),
                              Expanded(
                                child: Text(
                                  '  Accept terms & conditions',
                                  style: normalText(
                                      size: 13, color: AppColors.borderColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ht(20),
                        ),
                        PrimaryButton(
                          label: 'Continue',
                          onPress: () async {
                            if (await controller.initvalidation()) {
                              controller.createUser();
                            }
                            // Get.offAll(() => const NavBarScreen());
                          },
                        ),
                        SizedBox(
                          height: ht(20),
                        ),
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: normalText(
                                    size: 13, color: AppColors.borderColor),
                              ),
                              Text(
                                'Sign in here',
                                style: regularText(
                                    size: 13, color: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ht(40),
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

  Widget _userSignUp(SignUpController controller) {
    return Column(
      children: [
        customTextFiled(
            controller.controllerFirstName,
            controller.focusNodeFirstName,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_person.png',
                  height: 18,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'First Name'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            controller.controllerLastName,
            controller.focusNodeLastName,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_person.png',
                  height: 18,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'Last Name'),
        SizedBox(
          height: ht(12),
        ),
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
            hint: 'Email address'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
          controller.controllerUserName,
          controller.userNameNode,
          [],
          SizedBox(
            height: 50,
            width: 40,
            child: Center(
              child: Image.asset(
                'assets/images/ic_person.png',
                height: 13,
                color: AppColors.iconColor,
              ),
            ),
          ),
          hint: 'Username',
        ),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            controller.controllerPhone,
            controller.focusNodePhone,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_phone.png',
                  height: 13,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'Phone',
            textInputType: TextInputType.number),
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
                  color: AppColors.iconColor,
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
                  color: AppColors.iconColor,
                ))),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            controller.controllerConfirmPassword,
            controller.focusNodeConfirm,
            [],
            SizedBox(
              height: 50,
              width: 40,
              child: Center(
                child: Image.asset(
                  'assets/images/ic_lock.png',
                  height: 18,
                  color: AppColors.iconColor,
                ),
              ),
            ),
            hint: 'Re-type Password',
            obscure: controller.obscure,
            suffixIcon: GestureDetector(
                onTap: () {
                  controller.obscure = !controller.obscure;
                  controller.update();
                },
                child: Icon(
                  controller.obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.iconColor,
                ))),
      ],
    );
  }

  Widget _preferences(SignUpController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          'Add Preferences',
          style: subHeadingText(size: 16),
        ),
        const SizedBox(
          height: 20,
        ),
        customTextFiled(
          controller.controllerSearchPrefs,
          controller.focusSearchPrefs,
          [],
          SizedBox(
            height: 50,
            width: 40,
            child: Center(
              child: Image.asset(
                'assets/images/ic_search.png',
                height: 18,
                color: AppColors.iconColor,
              ),
            ),
          ),
          hint: 'Search',
        ),
        SizedBox(
          height: ht(12),
        ),
        GetBuilder<SignUpController>(
          builder: (logic) {
            return RadioButtonTileGroup<String>(
              selectedValues: logic.selectedPreferences,
              onChanged: (newValues) {
                logic.selectedPreferences = newValues;
                logic.update();
              },
              selectedTileColor:
                  AppColors.primaryColorBottom, // Customize selected tile color
              borderWidth: 1.0, // Customize border width
              borderRadius: 100, // Customize border radius
              tilesPerRow: 4, // Set number of tiles per row
              tiles: [
                RadioButtonTile(title: 'Movies', value: 'movies'),
                RadioButtonTile(title: 'Games', value: 'games'),
                RadioButtonTile(title: 'Fun', value: 'fun'),
                RadioButtonTile(title: 'Recipes', value: 'recipes'),
                RadioButtonTile(title: 'Matches', value: 'matches'),
                RadioButtonTile(title: 'Latest', value: 'latest'),
              ],
            );
          },
        ),
        const SizedBox(
          height: 10,
        ),
        multiLinesTextField(
          controller.bioController,
          controller.bioNode,
          [],
          hint: 'Bio',
        ),
      ],
    );
  }
}
