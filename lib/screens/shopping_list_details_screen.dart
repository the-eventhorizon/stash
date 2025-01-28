import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vana_sky_stash/models/household.dart';
import 'package:vana_sky_stash/models/item.dart';
import 'package:vana_sky_stash/models/shopping_list.dart';
import 'package:vana_sky_stash/providers/api_provider.dart';

class ShoppingListDetailsScreen extends StatefulWidget {
  const ShoppingListDetailsScreen(
      {super.key, required this.household, required this.shoppingList});

  final Household household;
  final ShoppingList shoppingList;

  @override
  State<ShoppingListDetailsScreen> createState() =>
      ShoppingListDetailsScreenState();
}

class ShoppingListDetailsScreenState extends State<ShoppingListDetailsScreen> {
  final ApiProvider apiProvider = ApiProvider();
  final formKey = GlobalKey<FormState>();
  final itemNameController = TextEditingController();
  final editController = TextEditingController();
  List<Item> listItems = [];
  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  @override
  void dispose() {
    itemNameController.dispose();
    editController.dispose();
    super.dispose();
  }

  Future<void> loadItems() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final items = await apiProvider.getItems(
          context, widget.household.id, widget.shoppingList.id);
      setState(() {
        listItems = items;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  void sendItem() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      try {
        await apiProvider.addItem(context, widget.household.id,
            widget.shoppingList.id, itemNameController.text.trim());
        if (!mounted) return;
        Navigator.pop(context, true);
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });
      } finally {
        setState(() {
          loading = false;
        });
        itemNameController.clear();
      }
    }
  }

  void updateItem(Item item) async {
    if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      try {
        await apiProvider.updateItem(context, widget.household.id,
            widget.shoppingList.id, item.id, editController.text.trim());
        if (!mounted) return;
        Navigator.pop(context, true);
        loadItems();
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

  void editItem(Item item) {
    setState(() {
      editController.text = item.name;
    });
    final trans = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trans.item_update,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                        controller: editController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(labelText: trans.item_name),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return trans.item_field_empty;
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => updateItem(item)),
                    SizedBox(height: 16.0),
                    if (loading)
                      CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      )
                    else
                      ElevatedButton(
                        onPressed: () => updateItem(item),
                        child: Text(trans.item_update),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteItem(Item item) async {
    final trans = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(trans.item_delete),
        content: Text(trans.item_delete_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(trans.ui_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(trans.ui_delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      try {
        if (!mounted) return;
        await apiProvider.deleteItem(
            context, widget.household.id, widget.shoppingList.id, item.id);
        if (!mounted) return;
        loadItems();
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

  void openDialog() async {
    final trans = AppLocalizations.of(context)!;
    final result = await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trans.item_create,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: itemNameController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(labelText: trans.item_name),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return trans.item_field_empty;
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => sendItem(),
                    ),
                    SizedBox(height: 16.0),
                    if (loading)
                      CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      )
                    else
                      ElevatedButton(
                        onPressed: () => sendItem(),
                        child: Text(trans.item_create),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == true) {
      loadItems();
    }
  }

  void optimisticToggle(Item item) async {
    final previousState = item.checked;

    try {
      await apiProvider.toggleItemChecked(context, widget.household.id,
          widget.shoppingList.id, item.id, !previousState);
      setState(() {
        item.checked = !item.checked;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.error_update_item),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trans = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shoppingList.name),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ))
              : RefreshIndicator(
                  onRefresh: loadItems,
                  child: listItems.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                '${trans.item_empty} ${trans.item_tap_to_create}'),
                          ),
                        )
                      : ListView.builder(
                          itemCount: listItems.length,
                          itemBuilder: (context, index) {
                            final item = listItems[index];
                            return Semantics(
                              container: true,
                              label: item.name,
                              hint: item.checked
                                  ? trans.item_checked_hint
                                  : trans.item_unchecked_hint,
                              child: InkWell(
                                onTap: () => optimisticToggle(item),
                                child: Container(
                                  color: item.checked
                                      ? Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                      : Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Checkbox
                                      SizedBox(
                                        width: 50.0,
                                        child: Checkbox(
                                          value: item.checked,
                                          onChanged: (value) =>
                                              optimisticToggle(item),
                                        ),
                                      ),
                                      // Item name
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            decoration: item.checked
                                                ? TextDecoration.lineThrough
                                                : null,
                                            color: item.checked
                                                ? Colors.grey
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                          ),
                                        ),
                                      ),
                                      // User name
                                      Expanded(
                                        child: Text(
                                          item.addedBy?.name ?? '',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: item.checked
                                                ? Colors.grey
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                          ),
                                        ),
                                      ),
                                      // Edit and delete buttons
                                      Row(
                                        children: [
                                          IconButton(
                                            onPressed: () => editItem(item),
                                            icon: Icon(Icons.edit),
                                          ),
                                          IconButton(
                                            onPressed: () => deleteItem(item),
                                            icon: Icon(Icons.delete),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: openDialog,
        tooltip: trans.item_create,
        child: Icon(Icons.add),
      ),
    );
  }
}
