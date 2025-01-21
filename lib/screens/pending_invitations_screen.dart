import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vana_sky_stash/providers/api_provider.dart';
import 'package:vana_sky_stash/models/invitation.dart';

class PendingInvitationsScreen extends StatefulWidget {
  const PendingInvitationsScreen({super.key});

  @override
  State<PendingInvitationsScreen> createState() =>
      PendingInvitationsScreenState();
}

class PendingInvitationsScreenState extends State<PendingInvitationsScreen> {
  final ApiProvider apiProvider = ApiProvider();
  List<Invitation> invitations = [];
  bool loading = false;
  String? errorMessage;
  Set<int> processingInvitations = {};

  @override
  void initState() {
    super.initState();
    loadInvitations();
  }

  Future<void> loadInvitations() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final results = await apiProvider.getInvitations(context);
      setState(() {
        invitations = results;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> respondToInvitation(int id, String response) async {
    final trans = AppLocalizations.of(context)!;
    setState(() {
      processingInvitations.add(id);
      errorMessage = null;
    });

    try {
      await apiProvider.respondToInvitation(context, id, response);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(trans.user_invitation_responded),
        ),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        processingInvitations.remove(id);
      });
    }
  }

  List<IconButton> getIconButtons(Invitation invitation) {
    final trans = AppLocalizations.of(context)!;
    return [
      IconButton(
        icon: processingInvitations.contains(invitation.id)
            ? SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Icon(Icons.check),
        onPressed: processingInvitations.contains(invitation.id)
            ? null
            : () => respondToInvitation(invitation.id, 'accept'),
        tooltip: trans.user_invitation_accept,
      ),
      IconButton(
        icon: processingInvitations.contains(invitation.id)
            ? SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Icon(Icons.close),
        onPressed: processingInvitations.contains(invitation.id)
            ? null
            : () => respondToInvitation(invitation.id, 'decline'),
        tooltip: trans.user_invitation_decline,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.user_pending_invitations),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!),
                )
              : RefreshIndicator(
                  onRefresh: loadInvitations,
                  child: invitations.isEmpty
                      ? Center(
                          child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(trans.user_pending_invitations_empty),
                        ))
                      : ListView.builder(
                          itemCount: invitations.length,
                          itemBuilder: (context, index) {
                            final invitation = invitations[index];
                            return ListTile(
                              title: Text(invitation.household.name),
                              subtitle: Text(invitation.inviterUser.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: getIconButtons(invitation),
                              ),
                            );
                          }),
                ),
    );
  }
}
