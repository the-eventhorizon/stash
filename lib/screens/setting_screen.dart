import 'package:country_flags/country_flags.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shopping_list/screens/login_screen.dart';
import 'package:shopping_list/models/user.dart';
import 'package:shopping_list/providers/api_provider.dart';
import 'package:shopping_list/providers/settings_notifier.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  void logout(BuildContext context, WidgetRef ref) async {
    final ApiProvider api = ApiProvider();
    try {
      await api.logout(context);
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);
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

  Future<Map<String, dynamic>> checkForUpdates(BuildContext context) async {
    final String repo =
        'https://api.github.com/repos/the-eventhorizon/stash/releases/latest';
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = 'v${packageInfo.version}-${packageInfo.buildNumber}';
    final Dio dio = Dio();
    try {
      final response = await dio.get(repo);
      final latestVersion = response.data['tag_name'];
      final url = response.data['html_url'];
      return {
        'currentVersion': currentVersion,
        'latestVersion': latestVersion,
        'url': url,
      };
    } catch (e) {
      return {
        'currentVersion': currentVersion,
        'error': 'Error: $e',
      };
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
                      initialValue: settings.locale.languageCode,
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
            FutureBuilder<Map<String, dynamic>>(
              future: checkForUpdates(context),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final updateInfo = snapshot.data!;
                  return ListTile(
                    title: Text(trans.settings_check_for_updates),
                    subtitle: Row(
                      children: [
                        Text(
                            '${trans.settings_current_version}: ${updateInfo['currentVersion']}'),
                        SizedBox(width: 8.0),
                        Text(
                          '${trans.settings_latest_version}: ${updateInfo['latestVersion']}',
                          style: TextStyle(
                            color: updateInfo['currentVersion'] ==
                                    updateInfo['latestVersion']
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => {
                      if (updateInfo['currentVersion'] ==
                          updateInfo['latestVersion'])
                        {checkForUpdates(context)}
                      else
                        {
                          // Open browser to latest release
                          if (updateInfo.containsKey('url'))
                            {launchUrl(updateInfo['url'])}
                        }
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
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
