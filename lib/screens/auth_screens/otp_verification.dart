import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controllers/password_controller.dart';
import '../../globals/enum.dart';
import '../../globals/global.dart';
import '../../utils/app_colors.dart';
import '../../utils/size_config.dart';
import '../../utils/text_styles.dart';
import '../../widgets/otp/src/otp_pin_field_input_type.dart';
import '../../widgets/otp/src/otp_pin_field_style.dart';
import '../../widgets/otp/src/otp_pin_field_widget.dart';
import '../../widgets/primary_button.dart';
import 'create_new_password.dart';

class OTPScreen extends StatefulWidget {
  final String otp;
  const OTPScreen({required this.otp});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  var controller = Get.put(ForgetPasswordController());

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // appBar: customAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.only(top: 40, left: 10),
                width: double.infinity,
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_image.png'),
                    fit: BoxFit
                        .cover, // You can adjust the fit as per your requirement
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_left),
                          iconSize: 32,
                          color: Colors.black, // Adjust icon color as needed
                          onPressed: () => Get
                              .back(), // Assuming Get.back() is used for navigation
                        ))
                  ],
                )),
            SizedBox(height: ht(33)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'OTP Verification',
                    style: headingText(size: 24),
                  ),
                  SizedBox(height: ht(18)),
                  Text(
                    "Enter the verification code that was sent to your email address.",
                    style: regularText(size: 16, color: HexColor('#86878B')),
                  ),
                  SizedBox(height: ht(57)),
                  Container(
                    child: OtpPinField(
                      otpPinFieldInputType: OtpPinFieldInputType.none,
                      onSubmit: (text) {
                        controller.otp.text = text;
                        debugPrint('${widget.otp.toString()} and ${controller.otp.text}');
                        if (text == widget.otp.toString()) {
                          Get.off(() => NewPasswordScreen());
                        } else {
                          Global.showToastAlert(
                              context: Get.overlayContext!,
                              strTitle: "",
                              strMsg: 'Invalid OTP',
                              toastType: TOAST_TYPE.toastError);
                        }
                      },
                      otpPinFieldStyle: OtpPinFieldStyle(
                        defaultFieldBorderColor: AppColors.primaryColorBottom,
                        activeFieldBorderColor: AppColors.primaryColor,
                        defaultFieldBackgroundColor: AppColors.white,
                        activeFieldBackgroundColor: AppColors
                            .white, // Background Color for active/focused Otp_Pin_Field
                      ),
                      maxLength: 4,
                      highlightBorder: true,
                      // fieldWidth: otpwidth,
                      fieldHeight: 60,

                      keyboardType: TextInputType.number,
                      autoFocus: true,
                      otpPinFieldDecoration:
                          OtpPinFieldDecoration.defaultPinBoxDecoration,
                    ),
                  ),
                  SizedBox(height: ht(50)),
                  PrimaryButton(
                      label: 'Verify',
                      onPress: () {
                        if (controller.otp.text == widget.otp.toString()) {
                          Get.off(() => NewPasswordScreen());
                        } else {
                          Global.showToastAlert(
                              context: Get.overlayContext!,
                              strTitle: "",
                              strMsg: 'Invalid OTP',
                              toastType: TOAST_TYPE.toastError);
                        }
                      }),
                  SizedBox(height: ht(40)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Didn't receive the code? ", style: normalText()),
                      InkWell(
                        onTap: () {},
                        child: Text("Resend",
                            style:
                                subHeadingText(color: AppColors.primaryColor)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
