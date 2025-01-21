import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vana_sky_stash/models/household.dart';
import 'package:vana_sky_stash/providers/api_provider.dart';

class CreateShoppingListScreen extends StatefulWidget {
  const CreateShoppingListScreen({super.key, required this.household});

  final Household household;

  @override
  State<CreateShoppingListScreen> createState() =>
      CreateShoppingListScreenState();
}

class CreateShoppingListScreenState extends State<CreateShoppingListScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ApiProvider apiProvider = ApiProvider();
  bool loading = false;
  String? errorMessage;

  void createShoppingList() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      try {
        await apiProvider.createList(
            context, widget.household.id, nameController.text.trim());
        if (!mounted) return;
        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      } finally {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.list_create),
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
                decoration: InputDecoration(
                    labelText: trans.list_name),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return trans.list_empty;
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
                  onPressed: createShoppingList,
                  child: Text(trans.list_create),
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
