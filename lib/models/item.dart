import 'package:vana_sky_stash/models/user.dart';

class Item {
  final int id;
  final String name;
  bool checked;
  final User? addedBy;

  Item({
    required this.id,
    required this.name,
    required this.checked,
    this.addedBy
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      checked: json['checked'] == 1 ? true : false,
      addedBy: json['addedBy'] != null
          ? User.fromJson(json['addedBy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'checked': checked,
      'addedBy': addedBy?.toJson(),
    };
  }
}