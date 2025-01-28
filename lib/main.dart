import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vana_sky_stash/providers/settings_notifier.dart';
import 'package:vana_sky_stash/routes.dart';
import 'package:vana_sky_stash/screens/welcome_screen.dart';
import 'package:vana_sky_stash/screens/home_screen.dart';
import 'package:vana_sky_stash/themes/dark.dart';
import 'package:vana_sky_stash/themes/light.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  final storage = FlutterSecureStorage();

  MyApp({super.key});

  Future<Widget> determineHomeScreen() async {
    String? authToken = await storage.read(key: 'auth_token');
    if (authToken == null) {
      return WelcomeScreen();
    }
    return HomeScreen();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return FutureBuilder<Widget>(
      future: determineHomeScreen(),
      builder: (context, snapshot) {
        Widget homeWidget;

        if (snapshot.connectionState == ConnectionState.waiting) {
          homeWidget = Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor
              ),
            )
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          homeWidget = Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          homeWidget = snapshot.data!;
        }

        return MaterialApp(
          title: 'Vana Sky Stash',
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: settings.themeMode,
          home: homeWidget,
          routes: getRoutes(),
        );
      },
    );
  }
}
