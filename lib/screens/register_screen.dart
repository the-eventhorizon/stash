import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vana_sky_stash/providers/api_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool loading = false;
  String? errorMessage;

  final ApiProvider apiProvider = ApiProvider();

  @override
  void initState() {
    super.initState();
  }

  void register() async {
    if (formKey.currentState!.validate()) {
     setState(() {
       loading = true;
       errorMessage = null;
      });

      try {
        await apiProvider.register(
          context,
          nameController.text.trim(),
          passwordController.text.trim(),
          confirmPasswordController.text.trim(),
        );

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        setState(() {
         errorMessage = e.toString();
       });
      } finally {
       loading = false;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordNode.dispose();
    confirmPasswordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.auth_register),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: trans.auth_name),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return trans.auth_name_invalid;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: trans.auth_password),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return trans.auth_password_invalid;
                  }
                  if (value.length < 8) {
                    return AppLocalizations.of(context)!
                        .auth_password_too_short;
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                    labelText: trans.auth_password_confirmation),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return trans.auth_password_invalid;
                  }
                  if (value != passwordController.text) {
                    return trans.auth_password_no_match;
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.0),
              if (loading)
                CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                )
              else
                ElevatedButton(
                  onPressed: register,
                  child: Text(trans.auth_register),
                ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(height: 16.0),
              TextButton(
                onPressed: () async {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(trans.ui_welcome_login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
