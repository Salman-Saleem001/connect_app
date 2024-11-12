import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../extensions/color_extensions.dart';
import '../../screens/auth_screens/login.dart';
import '../../utils/size_config.dart';
import '../../utils/text_styles.dart';
import '../../widgets/primary_button.dart';

class passwordChangedScreen extends StatefulWidget {
  const passwordChangedScreen({Key? key}) : super(key: key);

  @override
  _passwordChangedScreenState createState() => _passwordChangedScreenState();
}

class _passwordChangedScreenState extends State<passwordChangedScreen> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: ht(130),
              ),
              Container(
                height: 200,
                child: Stack(
                  children: [
                    Center(
                        child: Image.asset(
                            "assets/images/_x35_96_x2C__App_x2C__Check_x2C__Essential_x2C__Ui.png")),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Image.asset(
                            "assets/images/Vector.png",
                            height: 100,
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: ht(50),
              ),
              Text(
                'Password Changed!',
                style: headingText(size: 24),
              ),
              SizedBox(
                height: ht(10),
              ),
              SizedBox(
                width: wd(260),
                child: Text(
                  "Your password has been changed successfully.",
                  textAlign: TextAlign.center,
                  style: regularText(size: 16, color: HexColor('#8391A1')),
                ),
              ),
              SizedBox(
                height: ht(30),
              ),
              PrimaryButton(
                  label: 'Back to Login',
                  onPress: () {
                    Get.offAll(() => LoginScreen());
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
