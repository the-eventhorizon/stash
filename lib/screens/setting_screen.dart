import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vana_sky_stash/models/user.dart';
import 'package:vana_sky_stash/providers/api_provider.dart';
import 'package:vana_sky_stash/providers/settings_notifier.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  void logout(BuildContext context, WidgetRef ref) async {
    final ApiProvider api = ApiProvider();
    try {
      await api.logout(context);
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  String getLanguageName(String languageCode, BuildContext context) {
    final trans = AppLocalizations.of(context)!;

    switch (languageCode) {
      case 'en':
        return trans.language_en;
      case 'de':
        return trans.language_de;
      default:
        return languageCode;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.watch(settingsProvider.notifier);
    final trans = AppLocalizations.of(context)!;
    final ApiProvider api = ApiProvider();

    return Scaffold(
      appBar: AppBar(
        title: Text(trans.settings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trans.settings_general,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              title: Text(trans.settings_dark_mode),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (value) async => await notifier.toggleDarkMode(value),
            ),
            ListTile(
              title: Text(trans.settings_language),
              trailing: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    constraints: BoxConstraints(
                      minWidth: 150.0,
                    ),
                    width: constraints.maxWidth * 0.3,
                    child: DropdownButtonFormField<String>(
                      icon: Icon(Icons.arrow_drop_down),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          )),
                      value: settings.locale.languageCode,
                      onChanged: (value) async =>
                          await notifier.changeLanguage(value!),
                      items: AppLocalizations.supportedLocales.map((locale) {
                        return DropdownMenuItem(
                          value: locale.languageCode,
                          child: Row(
                            children: [
                              CountryFlag.fromLanguageCode(
                                locale.languageCode,
                                width: 25,
                                shape: const Circle(),
                              ),
                              SizedBox(width: 8.0),
                              Text(getLanguageName(
                                  locale.languageCode, context)),
                            ],
                          ),
                        );
                      }).toList(),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  );
                },
              ),
            ),
            Text(
              trans.settings_account,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder<User>(
              future: api.getUser(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  final user = snapshot.data;
                  return ListTile(
                    leading: Icon(Icons.person),
                    title: Text('${trans.user_code}: ${user!.code}'),
                    subtitle: Text(trans.user_code_tap_to_copy),
                    onTap: () {
                      try {
                        Clipboard.setData(ClipboardData(text: user.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Code copied to clipboard'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                          ),
                        );
                      }
                    },
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(trans.auth_logout),
              onTap: () => logout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
