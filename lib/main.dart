import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/localization/app_translations.dart';
import 'core/themes/app_theme.dart';
import 'routes/routes.dart';
import 'core/bootstrap/app_bootstrap_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrapController.init();
  runApp(ItalyApp(initialRoute: AppPages.initial));
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
        return GetMaterialApp(
          initialBinding: InitialBindings(),
          debugShowCheckedModeBanner: false,
          title: 'Italir Pothe',
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          theme: AppTheme.lightTheme,
          getPages: AppPages.pages,
          initialRoute: initialRoute,
        );
      },
    );
  }
}
