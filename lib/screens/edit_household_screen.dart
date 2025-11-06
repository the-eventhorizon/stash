import 'package:flutter/material.dart';
import 'package:shopping_list/l10n/app_localizations.dart';
import 'package:shopping_list/providers/api_provider.dart';
import 'package:shopping_list/models/household.dart';

class EditHouseholdScreen extends StatefulWidget {
  final Household household;

  const EditHouseholdScreen({super.key, required this.household});

  @override
  State<EditHouseholdScreen> createState() => EditHouseholdScreenState();
}

class EditHouseholdScreenState extends State<EditHouseholdScreen> {
  final formKey1 = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final inviteController = TextEditingController();
  final ApiProvider apiProvider = ApiProvider();
  bool loadingUpdate = false;
  bool loadingInvite = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.household.name;
  }

  void updateHousehold() async {
    if (formKey1.currentState!.validate()) {
      setState(() {
        loadingUpdate = true;
        errorMessage = null;
      });

      try {
        await apiProvider.updateHousehold(context,
            widget.household.id, nameController.text.trim());
        if (!mounted) return;
        Navigator.pop(context, true); // Return true to indicate success
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      } finally {
        setState(() {
          loadingUpdate = false;
        });
      }
    }
  }

  void inviteUser() async {
    final trans = AppLocalizations.of(context)!;

    if (formKey2.currentState!.validate()) {
      setState(() {
        loadingInvite = true;
        errorMessage = null;
      });

      try {
        await apiProvider.inviteUserToHousehold(context,
            widget.household.id, inviteController.text.trim());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(trans.household_invite_success)));
        inviteController.clear();
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(trans.error_invite_user)));
      } finally {
        setState(() {
          loadingInvite = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.household_edit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: formKey1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: trans.household_name),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return trans.household_empty;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: updateHousehold,
                    child: loadingUpdate
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(trans.household_update),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            Form(
              key: formKey2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                      controller: inviteController,
                      decoration:
                          InputDecoration(labelText: trans.household_invite_by_code),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return trans.household_invite_invalid_code;
                        }
                        return null;
                      }),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: inviteUser,
                    child: loadingInvite
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(trans.household_invite),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(height: 24.0),
                  Text(trans.household_members, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                  widget.household.members == null || widget.household.members!.isEmpty
                  ? Text('${trans.household_no_members} ${trans.household_invite_tap_to_create}')
                      : ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.household.members!.length,
                    itemBuilder: (context, index) {
                      final member = widget.household.members![index];
                      return ListTile(
                        title: Text(member.name),
                        subtitle: Text(member.code),
                        trailing: member.id == widget.household.ownerId
                            ? Text(trans.household_owner)
                            : null,
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
