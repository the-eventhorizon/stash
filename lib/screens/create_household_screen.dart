import 'package:flutter/material.dart';
import 'package:vana_sky_stash/providers/api_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateHouseholdScreen extends StatefulWidget {
  const CreateHouseholdScreen({super.key});

  @override
  State<CreateHouseholdScreen> createState() => CreateHouseholdScreenState();
}

class CreateHouseholdScreenState extends State<CreateHouseholdScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ApiProvider apiProvider = ApiProvider();
  bool loading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
  }

  void createHousehold() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      try {
        await apiProvider.createHousehold(context, nameController.text.trim());
        if (!mounted) return;
        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        errorMessage = e.toString();
      } finally {
        loading = false;
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(trans.household_create)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: trans.household_name),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return trans.household_empty;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => createHousehold(),
              ),
              SizedBox(height: 16.0),
              if (loading)
                CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                )
              else
                ElevatedButton(
                  onPressed: createHousehold,
                  child: Text(trans.household_create),
                ),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
