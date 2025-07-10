import 'package:finalsalesrep/l10n/app_localization.dart';
import 'package:finalsalesrep/l10n/app_localization_en.dart';
import 'package:finalsalesrep/l10n/l10n.dart';
import 'package:finalsalesrep/languageprovider.dart';
import 'package:finalsalesrep/splashacreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(ChangeNotifierProvider(
      create: (_) {
        return LocalizationProvider();
      },
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocalizationProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      locale: provider.locale,
      supportedLocales: const [
        Locale('en'),
        Locale('te'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
      //  isLoggedIn ? const AgentDashBoardScreen() :
    );
  }
}
