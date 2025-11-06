import 'package:flutter/material.dart';
import 'package:shopping_list/l10n/app_localizations.dart';
import 'package:shopping_list/providers/api_provider.dart';
import 'package:shopping_list/models/request.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => PendingRequestsScreenState();
}

class PendingRequestsScreenState extends State<PendingRequestsScreen> {
  final ApiProvider apiProvider = ApiProvider();
  List<Request> requests = [];
  bool loading = false;
  String? errorMessage;
  Set<int> processingRequests = {};

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });
    try {
      final results = await apiProvider.getRequests(context);
      setState(() {
        requests = results;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> respondToRequest(int id, String response) async {
    final trans = AppLocalizations.of(context)!;
    setState(() {
      processingRequests.add(id);
      errorMessage = null;
    });

    try {
      await apiProvider.respondToRequest(context, id, response);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(trans.user_request_responded),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      setState(() {
        processingRequests.remove(id);
        loadRequests();
      });
    }
  }

  List<IconButton> getIconButtons(Request request) {
    final trans = AppLocalizations.of(context)!;
    return [
      IconButton(
        icon: processingRequests.contains(request.id)
            ? SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              )
            : Icon(Icons.check),
        onPressed: processingRequests.contains(request.id)
            ? null
            : () => respondToRequest(request.id, "accepted"),
        tooltip: trans.user_request_accept,
      ),
      IconButton(
        icon: processingRequests.contains(request.id)
            ? SizedBox(
                height: 24.0,
                width: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Icon(Icons.close),
        onPressed: processingRequests.contains(request.id)
            ? null
            : () => respondToRequest(request.id, "rejected"),
        tooltip: trans.user_request_decline,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.user_pending_requests),
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
                  onRefresh: loadRequests,
                  child: requests.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(trans.user_pending_requests_empty),
                          ),
                        )
                      : ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            return ListTile(
                              title: Text(request.requestingUser.name),
                              subtitle: Text(request.household.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: getIconButtons(request),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
