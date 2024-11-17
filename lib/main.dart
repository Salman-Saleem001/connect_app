import 'dart:ui';
import 'package:connect_app/screens/splash/splash_video.dart';
import 'package:connect_app/services/google_map/google_map_screen_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:connect_app/bindings/initial_binding.dart';
import 'package:connect_app/globals/adaptive_helper.dart';
import 'package:connect_app/screens/main_screens/bottom_bar_screen.dart';
import 'package:connect_app/services/google_map/home_provider.dart';
import 'package:connect_app/services/local_notifications_helper.dart';
import 'package:connect_app/utils/app_theme_input_dec.dart';
import 'package:connect_app/utils/login_details.dart';
import 'package:connect_app/widgets/error_handler.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();



  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    EasyLoading.dismiss();
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    Future.delayed(Duration.zero, () {
      EasyLoading.dismiss();
    });
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return CustomError(
      errorDetails: errorDetails,
    );
  };
  LocalNotificationChannel.initializer();
  EasyLoading().dismissOnTap = false;
  EasyLoading().userInteractions = false;

  var user = Get.put(UserDetail());
  await user.getUserData();
  var login = await user.isLogin();

  runApp(OverlaySupport(child: BoosterMaterialApp(login: login)));
}

class BoosterMaterialApp extends StatelessWidget {
  final bool login;
  const BoosterMaterialApp({super.key, required this.login});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider(), lazy: true,),
        ChangeNotifierProvider<GoogleMapScreenProvider>(create: (_) => GoogleMapScreenProvider(), lazy: true,),
      ],
      child: LayoutBuilder(
        builder: (context, constraint) {
          Responsive.init(constraint.maxHeight, constraint.maxWidth);
          return GetMaterialApp(
              title: 'Connect Giant',
              themeMode: ThemeMode.light,
              theme: AppTheme.data(),
              fallbackLocale: const Locale('en', 'US'),
              locale: const Locale('en', 'US'),
              defaultTransition: Transition.cupertino,
              debugShowCheckedModeBanner: false,
              initialBinding: InitialBinding(),
              home: login ? const NavBarScreen() : const SplashVideo(),
              builder: EasyLoading.init());
        },
      ),
    );
  }
}
