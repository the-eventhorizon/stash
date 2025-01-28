import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vana_sky_stash/screens/home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.appTitle),
        actions: [
          if (kDebugMode)
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen())),
              icon: Icon(Icons.code)
            ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: AssetImage('assets/app_icon.png'),
              width: 100,
              height: 100,
            ),
            SizedBox(height: 16.0),
            Text(
              trans.ui_welcome,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text(trans.ui_welcome_message),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: Text(trans.ui_welcome_login),
            ),
          ],
        ),
      ),
    );
  }
}
