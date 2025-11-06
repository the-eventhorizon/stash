import 'package:shopping_list/models/household.dart';
import 'package:shopping_list/models/item.dart';

class ShoppingList {
  final int id;
  final String name;
  final Household household;
  final List<Item>? items;

  ShoppingList({
    required this.id,
    required this.name,
    required this.household,
    this.items,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) {
    return ShoppingList(
      id: json['id'],
      name: json['name'],
      household: json['household'] != null
          ? Household.fromJson(json['household'])
          : Household(id: 0, name: '', ownerId: 0, isPrivate: false),
      items: json['items'] != null
          ? List<Item>.from(json['items'].map((item) => Item.fromJson(item)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'household': household,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}