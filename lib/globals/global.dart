import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
// import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/result.dart';
import '../utils/app_colors.dart';
import '../utils/text_styles.dart';
import 'app_views.dart';
import 'constants.dart';
import 'container_properties.dart';
import 'enum.dart';

//Main Global class
class Global {
  // All String
  static const String poppins = "poppins";

  static showAlert(BuildContext contextM, String strMessage) {
    if (strMessage.isEmpty) {
      strMessage = 'Interval Server Error';
    }
    showSimpleNotification(
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackgroundColor,
            border: Border.all(width: 1, color: AppColors.bgGrey),
          ),
          child: Text(
            strMessage,
            style: Theme.of(contextM)
                .textTheme
                .titleSmall
                ?.merge(const TextStyle(color: Colors.white)),
          ),
        ),
        duration: const Duration(seconds: 3),
        background: AppColors.scaffoldBackgroundColor);
  }

  static showToastAlert(
      {required BuildContext context,
      String strTitle = '',
      required String strMsg,
      Widget? action,
      required TOAST_TYPE toastType}) {
    if (!Global.checkNull(strMsg)) {
      strMsg = 'Server not responding';
    }
    Widget widgetM = Container();
    Color bgColor = Colors.green.shade400;
    String strIcon = 'ic_alert_circle.png';
    switch (toastType) {
      case TOAST_TYPE.toastInfo:
        bgColor = AppColors.primaryColor;
        strIcon = 'ic_alert_circle.png';

        break;

      case TOAST_TYPE.toastSuccess:
        bgColor = Colors.green;
        strIcon = 'ic_check_circle.png';
        break;

      case TOAST_TYPE.toastWarning:
        bgColor = Colors.orange;
        strIcon = 'ic_alert_triangle.png';

        break;

      case TOAST_TYPE.toastError:
        bgColor = Colors.red;
        strIcon = 'ic_alert_octagon.png';
        break;
    }

    widgetM = Container(
      margin: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: ContainerProperties.borderDecoration(borderColor: bgColor)
            .copyWith(color: Colors.white),
        child: Container(
          alignment: Alignment.center,
          width: double.maxFinite,
          child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsetsDirectional.only(end: 25),
                    height: 40,
                    width: 40,
                    // decoration: BoxDecoration(
                    //     color: bgColor.withOpacity(0.2),
                    //     shape: BoxShape.circle),
                    // padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/$strIcon',
                      color: bgColor,
                    ),
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '$strMsg.',
                        textAlign: TextAlign.start,
                        style: normalText(size: 14),
                      ),
                    ],
                  )),
                  action ?? Container()
                ],
              )),
        ),
      ),
    );

    showSimpleNotification(widgetM,
        background: Colors.transparent,
        elevation: 0,
        slideDismissDirection: DismissDirection.up);
  }

  static showNoInternetDialog(BuildContext contextM) {
    showDialogM(
        contextM, AppAlert.ALERT, AppAlert.ALERT_NO_INTERNET_CONNECTION);
  }

  // show dialog
  static showDialogM(BuildContext contextM, String strTitle, String strMsg) {
    // return object of type Dialog
    var alert = AlertDialog(
      title: Text(strTitle),
      content: Text(strMsg),
      actions: <Widget>[
        // usually buttons at the bottom of the dialog
        TextButton(
          child: const Text("Close"),
          onPressed: () {
            Navigator.of(contextM, rootNavigator: true).pop();
          },
        ),
      ],
    );
    showDialog(context: contextM, builder: (context) => alert);
  }

//  set data on result
  static getInJson(String strResponse) {
    try {
      return json.decode(strResponse);
    } catch (exception) {
      return null;
    }
  }

  static bool equalsIgnoreCase(String? a, String? b) =>
      (a == null && b == null) ||
      (a != null && b != null && a.toLowerCase() == b.toLowerCase());

  static launchURL(String strUrl) async {
    if (strUrl.isNotEmpty) {
      if (await launchURL(strUrl)) {
        try {
          await launchURL(strUrl);
        } catch (e) {
          log(e.toString());
        }
      } else {
        throw 'Could not launch $strUrl';
      }
    }
  }

//   * Replace Currency Code to Currency Sign.

  static checkValidEmail(String strEmail) {
    if (strEmail.isNotEmpty) {
//      return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//          .hasMatch(strEmail);
      return RegExp(Constants.EMAIL_REGX).hasMatch(strEmail);
    } else {
      return false;
    }
  }

  static checkValidPassWord(String strMobile) {
    if (strMobile.isNotEmpty) {
      return RegExp(Constants.PASSWORD_REGX).hasMatch(strMobile);
    } else {
      return false;
    }
  }

  static showAlertDialog(BuildContext mContext, String strTitle,
      String strMessage, List<Widget> widgetActions) {
    return showDialog(
      context: mContext,
      builder: (context) => AlertDialog(
        title: Text(strTitle,
            style: Theme.of(mContext).textTheme.titleSmall?.merge(
                  const TextStyle(color: Colors.black),
                )),
        content: Text(strMessage,
            style: Theme.of(mContext).textTheme.titleSmall?.merge(
                  const TextStyle(color: Colors.black),
                )),
        actions: widgetActions,
      ),
    );
  }

  static showAlertDialogN(
      BuildContext mContext,
      String strTitle,
      String strMessage,
      List<Widget> widgetActions,
      bool isBarrierDismissible) {
    return showDialog(
      context: mContext,
      barrierDismissible: isBarrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(
          strTitle,
          style: Theme.of(mContext)
              .textTheme
              .titleSmall
              ?.merge(const TextStyle(color: Colors.black)),
        ),
        content: Text(strMessage,
            style: Theme.of(mContext).textTheme.titleSmall?.merge(
                  const TextStyle(color: Colors.black),
                )),
        actions: widgetActions,
      ),
    );
  }

  static bool isKeyLengthValid(String key) {
    return key.length == 16 || key.length == 24 || key.length == 32;
  }

  static updateVersionCode(BuildContext mContext, bool isUpdate,
      bool isForceFullUpdate, String strRedirectUrl) {
    if (isUpdate || isForceFullUpdate) {
      if (!Constants.FLAG_DIALOG_APP_UPDATE) {
        List<Widget> widgetActions;

        if (isForceFullUpdate) {
          widgetActions = <Widget>[
            // ignore: argument_type_not_assignable
            TextButton(
              onPressed: () {
                Global.launchURL(strRedirectUrl);
              },
              child: Text(Constants.KEY_UPDATE_APP,
                  style: Theme.of(mContext).textTheme.titleSmall?.merge(
                        const TextStyle(color: Colors.black),
                      )),
            )
          ];
        } else {
          widgetActions = <Widget>[
            // ignore: argument_type_not_assignable
            TextButton(
              onPressed: () =>
                  Navigator.of(mContext, rootNavigator: true).pop(),
              child: Text(Constants.KEY_NO_THANKS,
                  style: Theme.of(mContext).textTheme.titleSmall?.merge(
                        const TextStyle(color: Colors.black),
                      )),
            ),
            TextButton(
              onPressed: () {
                Global.launchURL(strRedirectUrl);
              },
              child: Text(Constants.KEY_UPDATE_APP,
                  style: Theme.of(mContext).textTheme.titleSmall?.merge(
                        const TextStyle(color: Colors.black),
                      )),
            ),
          ];
        }
        return Global.showAlertDialogN(mContext, Constants.KEY_APP_UPDATE_TITLE,
            Constants.KEY_APP_UPDATE_MESSAGE, widgetActions, false);
      }
    }
  }

  static showLogoutDialog(BuildContext mContext) {
    AppViews.showCustomAlert(
        context: mContext,
        strTitle: Constants.STRING_SIGN_OUT,
        strMessage: Constants.STRING_SIGN_OUT_MSG,
        strLeftBtnText: Constants.TEXT_CANCEL,
        onTapLeftBtn: () {
          Navigator.pop(mContext);
        },
        strRightBtnText: Constants.STRING_OK,
        onTapRightBtn: () {});
  }

  static bool checkNull(String? strString) {
    if (strString != null &&
        strString.isNotEmpty &&
        !Global.equalsIgnoreCase(strString, "null")) {
      return true;
    }
    return false;
  }

  static bool checkIsLink(String? strString) {
    if (checkNull(strString) && strString!.startsWith("http")) {
      return true;
    }
    return false;
  }

  static showAlertDialogBtnRow(BuildContext mContext, String strTitle,
      Widget widgetActions, bool isBarrierDismissible) {
    return showDialog(
      context: mContext,
      barrierDismissible: isBarrierDismissible,
      builder: (context) => AlertDialog(
          title: Text(strTitle.isNotEmpty ? strTitle : AppAlert.ALERT),
          content: widgetActions),
    );
  }

  static double convertStringToDouble(String numberAsString) {
    try {
      final double doubleParsed = double.parse(numberAsString);
      final twoDecimalString = doubleParsed.toStringAsFixed(2);
      final double twoDecimalNumber = double.parse(twoDecimalString);
      return twoDecimalNumber;
    } catch (e) {
      log(e.toString());
      return -1;
    }
  }

  static storeToken(String strAccessToken) async {
    final prefManager = await SharedPreferences.getInstance();
    if (Global.checkNull(strAccessToken)) {
      prefManager.setString(SharedPrefKey.KEY_ACCESS_TOKEN, strAccessToken);
    }
  }

  static Result? getData(String strResponse) {
    try {
      Map data = json.decode(strResponse);

      String strStatus = data[Constants.RES_STATUS].toString();
      String strMessage = data[Constants.RES_MESSAGE].toString();

      bool status = true;
      if (Global.checkNull(strStatus)) {
        if (Global.equalsIgnoreCase(strStatus, "fail") ||
            Global.equalsIgnoreCase(strStatus, "error")) {
          status = false;
        }
      }

      dynamic dataObj;
      if (status &&
          (data.containsKey(Constants.RES_RESULT) ||
              data.containsKey('results'))) {
        dataObj = data[Constants.RES_RESULT] ?? data['results'];
      } else if (!status || data.containsKey(Constants.RES_ERROR)) {
        dataObj = data[Constants.RES_ERROR];
      }
      return Result(
          responseStatus: status,
          responseMessage: strMessage,
          responseData: dataObj ?? {});
    } catch (exception) {
      log('catch error : $exception');
      return Result(
          responseStatus: false,
          responseMessage: "Please try after some time",
          responseData: "");
    }
  }

  static showNoInternet(BuildContext context) {
    Global.showToastAlert(
        context: context,
        strTitle: "",
        strMsg: AppAlert.ALERT_NO_INTERNET_CONNECTION,
        toastType: TOAST_TYPE.toastError);
  }

  static Future<void> shareText(
      {String? title,
      String? text,
      String? linkUrl,
      String? chooserTitle}) async {
    await Share.share(text!);
  }

  static taskStoreToken(String strToken) async {
    final prefManager = await SharedPreferences.getInstance();
    prefManager.setString(SharedPrefKey.KEY_FIREBASE_TOKEN, strToken);
  }

  static taskGetToken() async {
    final prefManager = await SharedPreferences.getInstance();
    String? strToken = prefManager.getString(SharedPrefKey.KEY_FIREBASE_TOKEN);

    return strToken ?? "";
  }

  static downloadImage(String strURL) async {
    var response = await http.get(Uri.parse(strURL));
    var documentDirectory = await getApplicationDocumentsDirectory();
    var firstPath = "${documentDirectory.path}/images";
    var filePathAndName = '${documentDirectory.path}/images/pic.jpg';
    await Directory(firstPath).create(recursive: true);
    File file2 = File(filePathAndName);
    file2.writeAsBytesSync(response.bodyBytes);

    return filePathAndName;
  }

  static getTimeFromDate(DateTime mDateTime, String strDateFormate) {
    String strDate = "";
    var formatter = DateFormat(strDateFormate);
    strDate = formatter.format(mDateTime);
    return strDate;
  }

  static capitalizeFirstofEach(String strValue) {
    return strValue
        .replaceAll(RegExp('_'), ' ')
        .split(" ")
        .map((str) => inCaps(str))
        .join(" ");
  }

  static inCaps(String strValue) {
    return strValue.isNotEmpty
        ? '${strValue[0].toUpperCase()}${strValue.substring(1)}'
        : '';
  }

// Static Data

// get product list data

  static getScalFactor() {
    return 1.0;
  }

  static String getCapitalizeString({required String str}) {
    if (str.length <= 1) {
      return str.toUpperCase();
    }
    return '${str[0].toUpperCase()}${str.substring(1)}';
  }

  static String getString(String strValue) {
    if (Global.checkNull(strValue)) {
      return strValue;
    }
    return '';
  }

  static bool isURL(String strURL) {
    if (Global.checkNull(strURL)) {
      if (strURL.startsWith("http")) {
        return true;
      }
    }
    return false;
  }

  static getCurrentDateTime() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    return formattedDate;
  }

  static getDoubleFromString(String strValue) {
    double dSubTotal = 0.0;
    if (Global.checkNull(strValue)) {
      dSubTotal = double.parse(strValue);
    }
    return dSubTotal;
  }

  static navigateToThankYou(BuildContext context) {
    Navigator.pushReplacementNamed(context, Constants.ACT_HOME_WITH_THANKS);
  }

  static getColorByStatus(String strStatus) {
    if (Global.checkNull(strStatus)) {
      switch (strStatus) {
        case "Success":
          return Colors.green;

        case "Fail":
          return Colors.red;
      }
    }
    return Colors.black;
  }

  // static getCropFile(
  //     {required String imagePath,
  //     required double mRatioX,
  //     required double mRatioY,
  //     required int mMaxHeight,
  //     required int mMaxWidth}) async {
  //   CroppedFile? croppedFile = await ImageCropper().cropImage(
  //       sourcePath: imagePath,
  //       aspectRatio: CropAspectRatio(ratioX: mRatioX, ratioY: mRatioY),
  //       maxHeight: mMaxHeight,
  //       maxWidth: mMaxWidth,
  //       // androidUiSettings: AndroidUiSettings(
  //       //     toolbarTitle: 'Crop Image',
  //       //     toolbarColor: AppColors.scaffoldBackgroundColor,
  //       //     toolbarWidgetColor: AppColors.bgGrey),
  //       // iosUiSettings: const IOSUiSettings(title: 'Crop Image')
  //       );
  //
  //   return croppedFile;
  // }

  static shareApp() {
    String strAppURL = Constants.STR_APP_URL_ANDROID;
    if (Platform.isAndroid) {
      strAppURL = Constants.STR_APP_URL_ANDROID;
    } else if (Platform.isIOS) {
      strAppURL = Constants.STR_APP_URL_IOS;
    }
    String strShareMessage =
        "${Constants.APP_NAME} is really useful. Try it !!! \n\n$strAppURL";

    shareText(
        title: Constants.APP_NAME,
        text: strShareMessage,
        chooserTitle: "Share",
        linkUrl: "");
  }

  // String _getVideoSize({required File file}) => formatBytes(file.lengthSync(), 2);

  static Future<double> getFileSize(String filepath) async {
    var file = File(filepath);
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);

    return sizeInMb;
  }

  argData(String keyName) {
    if (Get.arguments == null) return null;
    Map data = Get.arguments as Map;
    return data.containsKey(keyName) ? data[keyName] : null;
  }
}
