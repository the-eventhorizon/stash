import 'package:country_flags/country_flags.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vana_sky_stash/providers/auth_provider.dart';
import 'package:vana_sky_stash/screens/login_screen.dart';
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

  void changePassword(BuildContext context) async {
    final trans = AppLocalizations.of(context)!;
    final ApiProvider api = ApiProvider();

    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final userId = await AuthProvider().getCurrentUserId();

    bool isPasswordVisible = false;
    bool loading = false;
    String? errorMessage;

    if (!context.mounted) return;
    final result = await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trans.auth_password_change,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: currentPasswordController,
                        decoration: InputDecoration(
                          labelText: trans.auth_password_current,
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return trans.auth_password_invalid;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: newPasswordController,
                        decoration:
                            InputDecoration(labelText: trans.auth_password_new),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return trans.auth_password_too_short;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                            labelText: trans.auth_password_confirmation),
                        obscureText: true,
                        validator: (value) {
                          if (value == null ||
                              value != newPasswordController.text) {
                            return trans.auth_password_no_match;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      if (loading)
                        CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        )
                      else
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              setState(() {
                                loading = true;
                                errorMessage = null;
                              });
                            }
                            try {
                              await api.changePassword(
                                  context,
                                  currentPasswordController.text,
                                  newPasswordController.text,
                                  confirmPasswordController.text,
                                  userId);
                              if (!context.mounted) return;
                              Navigator.pop(context, true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(trans.auth_password_changed),
                                ),
                              );
                            } catch (e) {
                              setState(() {
                                errorMessage = e.toString();
                              });
                            } finally {
                              setState(() {
                                loading = false;
                              });
                            }
                          },
                          child: Text(trans.auth_password_change),
                        ),
                      if (errorMessage != null)
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(errorMessage!),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
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
                            {launchUrl(Uri.parse(updateInfo['url']))}
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
              leading: Icon(Icons.lock_reset),
              title: Text(trans.auth_password_change),
              onTap: () => changePassword(context),
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
