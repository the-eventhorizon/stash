import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vana_sky_stash/models/household.dart';
import 'package:vana_sky_stash/models/shopping_list.dart';
import 'package:vana_sky_stash/providers/api_provider.dart';

class HouseholdDetailsScreen extends StatefulWidget {
  final Household household;

  const HouseholdDetailsScreen({super.key, required this.household});

  @override
  State<HouseholdDetailsScreen> createState() => HouseholdDetailsScreenState();
}

class HouseholdDetailsScreenState extends State<HouseholdDetailsScreen> {
  final ApiProvider apiProvider = ApiProvider();
  List<ShoppingList> shoppingLists = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadShoppingLists();
  }

  Future<void> loadShoppingLists() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final lists = await apiProvider.getLists(context, widget.household.id);
      setState(() {
        shoppingLists = lists;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  void createShoppingList() async {
    final result = await Navigator.pushNamed(
      context,
      '/create-shopping-list',
      arguments: widget.household,
    );
    if (result == true) {
      loadShoppingLists();
    }
  }

  void editShoppingList(ShoppingList list) async {
    final result = await Navigator.pushNamed(
      context,
      '/edit-shopping-list',
      arguments: {'household': widget.household, 'list': list},
    );
    if (result == true) {
      loadShoppingLists();
    }
  }

  void deleteShoppingList(ShoppingList list) async {
    final trans = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(trans.list_delete),
              content: Text(trans.list_delete_confirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(trans.ui_cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(Colors.red),
                  ),
                  child: Text(trans.ui_delete),
                ),
              ],
            ));
    if (confirmed == true) {
      try {
        if (!mounted) return;
        await apiProvider.deleteList(context, widget.household.id, list.id);
        loadShoppingLists();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(trans.error_delete_list),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${trans.household}: ${widget.household.name}'),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: loadShoppingLists,
                  child: shoppingLists.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child:
                                Text('${trans.list_empty} ${trans.list_tap_to_create}'),
                          ),
                        )
                      : ListView.builder(
                          itemCount: shoppingLists.length,
                          itemBuilder: (context, index) {
                            final list = shoppingLists[index];
                            return ListTile(
                              title: Text(list.name),
                              trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => editShoppingList(list),
                                      icon: Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () => deleteShoppingList(list),
                                      icon: Icon(Icons.delete),
                                    ),
                                  ]),
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/shopping-list-details',
                                arguments: {
                                  'household': widget.household,
                                  'list': list
                                },
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: createShoppingList,
        tooltip: trans.list_create,
        child: Icon(Icons.add),
      ),
    );
  }
}
