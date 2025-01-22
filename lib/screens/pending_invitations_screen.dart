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
  List<Invitation> pendingInvitations = [];
  List<Invitation> acceptedInvitations = [];
  List<Invitation> declinedInvitations = [];
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
      final pending =
          results.where((element) => element.status == 'pending').toList();
      final accepted =
          results.where((element) => element.status == 'accepted').toList();
      final declined =
          results.where((element) => element.status == 'declined').toList();
      setState(() {
        pendingInvitations = pending;
        acceptedInvitations = accepted;
        declinedInvitations = declined;
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
        ),
      );
    } finally {
      setState(() {
        processingInvitations.remove(id);
        loadInvitations();
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
            : () => respondToInvitation(invitation.id, 'accepted'),
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
            : () => respondToInvitation(invitation.id, 'declined'),
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
          : RefreshIndicator(
              onRefresh: loadInvitations,
              child: pendingInvitations.isEmpty &&
                      acceptedInvitations.isEmpty &&
                      declinedInvitations.isEmpty
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(trans.user_invitations_empty),
                    ))
                  : ListView(
                      children: [
                        if (pendingInvitations.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              trans.user_pending_invitations,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...pendingInvitations.map(
                            (invitation) => ListTile(
                              title: Text(invitation.household.name),
                              subtitle: Text(invitation.inviterUser.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: getIconButtons(invitation),
                              ),
                            ),
                          ),
                        ],
                        if (acceptedInvitations.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              trans.user_accepted_invitations,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...acceptedInvitations.map(
                            (invitation) => ListTile(
                              title: Text(invitation.household.name),
                              subtitle: Text(invitation.inviterUser.name),
                            ),
                          ),
                        ],
                        if (declinedInvitations.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              trans.user_declined_invitations,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...declinedInvitations.map(
                            (invitation) => ListTile(
                              title: Text(invitation.household.name),
                              subtitle: Text(invitation.inviterUser.name),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
    );
  }
}
