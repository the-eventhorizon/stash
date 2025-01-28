import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vana_sky_stash/models/household.dart';
import 'package:vana_sky_stash/providers/api_provider.dart';
import 'package:vana_sky_stash/providers/auth_provider.dart';
import 'package:vana_sky_stash/screens/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ApiProvider apiProvider = ApiProvider();
  List<Household> ownedHouseholds = [];
  List<Household> joinedHouseholds = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadHouseholds();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadHouseholds() async {
    if (!mounted) return;
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final currentUserId = await AuthProvider().getCurrentUserId();
      if (!mounted) return;
      final households = await apiProvider.getHouseholds(context);
      if (!mounted) return;
      setState(() {
        ownedHouseholds = households
            .where((household) => household.isOwner(currentUserId!))
            .toList();
        joinedHouseholds = households
            .where((household) => !household.isOwner(currentUserId!))
            .toList();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  void createHousehold() async {
    final result = await Navigator.pushNamed(context, '/create-household');
    if (result == true) {
      loadHouseholds();
    }
  }

  void editHousehold(Household household) {
    Navigator.pushNamed(context, '/edit-household', arguments: household)
        .then((_) => loadHouseholds());
  }

  void deleteHousehold(Household household) async {
    final trans = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trans.household_delete),
        content: Text('${trans.household_delete_confirm} ${household.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(trans.ui_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            child: Text(trans.ui_delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        if (!mounted) return;
        await apiProvider.deleteHousehold(context, household.id);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(trans.error_delete_household),
          ),
        );
      } finally {
        loadHouseholds();
      }
    }
  }

  void leaveHousehold(Household household) async {
    final trans = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trans.household_leave),
        content: Text('${trans.household_leave_confirm} ${household.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(trans.ui_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            child: Text(trans.ui_leave),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        if (!mounted) return;
        await apiProvider.leaveHousehold(context, household.id);
        loadHouseholds();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(trans.error_leave_household),
          ),
        );
      }
    }
  }

  void navigateToHouseholdDetails(Household household) {
    Navigator.pushNamed(
      context,
      '/household-details',
      arguments: household,
    );
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(trans.households),
        actions: [
          if (kDebugMode)
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomeScreen())),
            icon: Icon(Icons.code)
          ),

          IconButton(
            onPressed: () => loadHouseholds(),
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/user'),
            icon: Icon(Icons.person),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Text(errorMessage!),
                )
              : RefreshIndicator(
                  onRefresh: loadHouseholds,
                  child: ownedHouseholds.isEmpty && joinedHouseholds.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                '${trans.household_empty} ${trans.household_tap_to_create}'),
                          ),
                        )
                      : ListView(
                          children: [
                            if (ownedHouseholds.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  trans.household_owned,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...ownedHouseholds.map(
                                (household) => ListTile(
                                  title: Text(household.name),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            editHousehold(household),
                                        icon: Icon(Icons.edit),
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            deleteHousehold(household),
                                        icon: Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                  onTap: () =>
                                      navigateToHouseholdDetails(household),
                                ),
                              ),
                            ],
                            if (joinedHouseholds.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  trans.household_joined,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ...joinedHouseholds.map(
                                (household) => ListTile(
                                  title: Text(household.name),
                                  trailing: IconButton(
                                    onPressed: () => leaveHousehold(household),
                                    icon: Icon(Icons.exit_to_app),
                                  ),
                                  onTap: () =>
                                      navigateToHouseholdDetails(household),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),

      floatingActionButton: FloatingActionButton(
        onPressed: createHousehold,
        tooltip: 'Create Household',
        child: Icon(Icons.add),
      ),
    );
  }
}
