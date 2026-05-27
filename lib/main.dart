import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:easy_localization/easy_localization.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'providers/accessibility_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GoogleSignIn.instance.initialize(
    serverClientId:
        '684299378154-08c0u5hvsd2nsvvah5gj6sjdvvthjl44.apps.googleusercontent.com',
  );

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: [Locale('es'), Locale('en')],
        path: 'assets/translations',
        fallbackLocale: Locale('es'),
        child: MainApp(),
      ),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessState = ref.watch(accessibilityProvider);

    // El tema ahora se inyecta directamente a través de AppTheme.getTheme

    // Mapeo de textScale de Slider (0 a 1) a textScaleFactor (0.85 a 1.15)
    // 0.5 -> 1.0 (Normal)
    // Rango ajustado para evitar errores de Overflow en el diseño
    final double textScaleFactor = 0.85 + (accessState.textScale * 0.3);

    return MaterialApp.router(
      title: 'ecommerce_uxui_guía'.tr(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.getTheme(accessState.nightMode, accessState.highContrast),
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: child!,
        );
      },
      routerConfig: appRouter,
    );
  }
}
