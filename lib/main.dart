import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/localization/translation_service.dart';
import 'core/services/local_notification_service.dart';
import 'core/themes/app_theme.dart';
import 'routes/routes.dart';
import 'core/bootstrap/app_bootstrap_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  await LocalNotificationService.instance.initialize();
  LocalNotificationService.instance.listenToForegroundMessages();

  await AppBootstrapController.init();
  runApp(ItalyApp(initialRoute: AppRoutes.bootstrap));
}

class ItalyApp extends StatelessWidget {
  final String initialRoute;
  //final SharedPreferences prefs;

  const ItalyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 884),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final TranslationService translationService =
            Get.find<TranslationService>();
        return GetMaterialApp(
          initialBinding: InitialBindings(),
          debugShowCheckedModeBanner: false,
          title: 'Italir Pothe',
          translations: translationService,
          locale: translationService.currentLocale,
          fallbackLocale: TranslationService.fallbackLocale,
          theme: AppTheme.lightTheme,
          getPages: AppPages.pages,
          initialRoute: initialRoute,
        );
      },
    );
  }
}
