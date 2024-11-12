import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:connect_app/controllers/mainScreen_controllers/profile_controller.dart';
import 'package:connect_app/globals/adaptive_helper.dart';
import 'package:connect_app/globals/enum.dart';
import 'package:connect_app/globals/global.dart';
import 'package:connect_app/globals/network_image.dart';
import 'package:connect_app/utils/login_details.dart';
import 'package:connect_app/utils/text_styles.dart';
import 'package:connect_app/widgets/appbars.dart';
import 'package:connect_app/widgets/custom_bottom_option_sheet.dart';
import 'package:connect_app/widgets/primary_button.dart';
import 'package:connect_app/widgets/text_fields.dart';

class EditDetails extends StatefulWidget {
  const EditDetails({super.key});

  @override
  State<EditDetails> createState() => _EditDetailsState();
}

class _EditDetailsState extends State<EditDetails> {
  late TextEditingController nameCont;

  late TextEditingController lastnameCont;

  late TextEditingController emailCont;
  late TextEditingController numberCont;
  late FocusNode nameFocus;

  late FocusNode numberFocus;

  late FocusNode lastname;
  late FocusNode emailFocus;

  late String imageUrl;

  File? file;
  var isLoading = false;


  selectImage(bool isCamera) async {
    XFile? image;

    ImagePicker picker = ImagePicker();
    image = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);

    file = File(image!.path);
    // debugPrint();
    setState(() {

    });
  }

  bool initvalidation() {
    if (!Global.checkNull(nameCont.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter first name',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(nameFocus);
      return false;
    }
    if (!Global.checkNull(lastnameCont.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter last name',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(lastname);
      return false;
    }
    if (!Global.checkNull(numberCont.text.toString().trim())) {
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please enter phone number',
          toastType: TOAST_TYPE.toastError);
      FocusScope.of(Get.overlayContext!).requestFocus(nameFocus);
      return false;
    }
    if(file==null){
      Global.showToastAlert(
          context: Get.overlayContext!,
          strTitle: "",
          strMsg: 'Please Select a Image',
          toastType: TOAST_TYPE.toastError);
      return false;
    }
    return true;
  }


  @override
  void initState() {
    // getProfile();
    nameCont = TextEditingController(
        text: Get
            .find<UserDetail>()
            .userData
            .user
            ?.firstName ?? '');
    lastnameCont = TextEditingController(
        text: Get
            .find<UserDetail>()
            .userData
            .user
            ?.lastName ?? '');
    emailCont = TextEditingController(
        text: Get
            .find<UserDetail>()
            .userData
            .user
            ?.email ?? '');
    numberCont = TextEditingController(
        text: (Get
            .find<UserDetail>()
            .userData
            .user
            ?.dob ?? DateTime.now())
            .toString()
            .substring(0, 10).replaceAll('-', '/'));
    nameFocus = FocusNode();
    lastname = FocusNode();
    emailFocus = FocusNode();
    numberFocus = FocusNode();
    imageUrl = Get
        .find<UserDetail>()
        .userData
        .user
        ?.avatar ?? '';
    debugPrint("Image===> $imageUrl");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      customAppBar(backButton: true, title: 'Edit Profile', marginTop: 25),
      // backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: wd(30), vertical: ht(15)),
          children: [
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                customBottomSheet(['Camera', 'Gallery'], -1, (i) {
                  if (i == 0) {
                    selectImage(true);
                  } else {
                    selectImage(false);
                  }
                });
              },
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                  ),
                  height: ht(105),
                  width: ht(105),
                  child: file == null ? imageUrl.isEmpty
                      ?  const Icon(Icons.image):ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: NetworkImageCustom(
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        image: imageUrl),
                  ) : ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.file(
                        file!, fit: BoxFit.cover,),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "${nameCont.text} ${lastnameCont.text}",
                style: regularText(size: 16, color: Colors.white),
              ),
            ),
            Column(
              children: [
                _userSignUp(),
                SizedBox(
                  height: ht(80),
                ),
                PrimaryButton(
                  label: 'Update Profile',
                  onPress: () {
                    var controller = Get.put(ProfileController());
                    if (initvalidation()) {
                      controller.updateProfile(
                          image: file ?? File(''), firstName: nameCont.text,
                          lastName: lastnameCont.text,
                          email: emailCont.text,
                          dob: numberCont.text.substring(0,10).replaceAll('/', '-')).whenComplete(() {
                        Get.back();
                      });
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _userSignUp() {
    return Column(
      children: [
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(nameCont, nameFocus, [], null, hint: 'First Name'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(lastnameCont, lastname, [], null, hint: 'Last Name'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(
            numberCont,
            numberFocus,
            [
              FilteringTextInputFormatter.deny(RegExp(r'[.:-]')),
            ],
            null,
            textInputType: TextInputType.datetime,
            suffixIcon: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                showDatePicker(
                  context: context,
                  firstDate: DateTime.utc(1900),
                  lastDate: DateTime.now(),
                  initialDate: DateTime.now(),
                ).then((val) {
                  numberCont.text = DateFormat("yyyy/MM/dd")
                      .format(val ?? DateTime.now())
                      .toString();
                });
              },
              child: const Icon(Icons.calendar_month_outlined),
            ),
            hint: 'DOB'),
        SizedBox(
          height: ht(12),
        ),
        customTextFiled(emailCont, emailFocus, [], null, hint: 'Email'),
        SizedBox(
          height: ht(12),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameCont.dispose();
    lastnameCont.dispose();
    emailCont.dispose();
    numberCont.dispose();
    nameFocus.dispose();
    numberFocus.dispose();
    lastname.dispose();
    emailFocus.dispose();
    super.dispose();
  }
}
