import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vana_sky_stash/providers/api_provider.dart';
import 'package:vana_sky_stash/screens/login_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => UserScreenState();
}

class UserScreenState extends State<UserScreen> {
  final ApiProvider apiProvider = ApiProvider();
  bool loading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
  }

  void logout() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      await apiProvider.logout(context);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      loading = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.user),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(trans.user_pending_invitations),
              onTap: () {
                Navigator.pushNamed(context, '/pending_invitations');
              },
            ),
            ListTile(
              title: Text(trans.user_pending_requests),
              onTap: () {
                Navigator.pushNamed(context, '/pending-requests');
              },
            ),
          ],
        ),
      ),
    );
  }
}
