import 'package:shopping_list/models/user.dart';

class Household {
  final int id;
  final String name;
  final int ownerId;
  final bool isPrivate;
  final List<User>? members;

  Household({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.isPrivate,
    this.members,
  });

  factory Household.fromJson(Map<String, dynamic> json) {
    return Household(
      id: json['id'],
      name: json['name'],
      ownerId: json['owner_id'],
      isPrivate: json['is_private'] == 1 ? true : false,
      members: json['members'] != null
          ? List<User>.from(json['members'].map((member) => User.fromJson(member)))
          : null,
    );
  }

  bool isOwner(String currentUserId) {
    return ownerId.toString() == currentUserId;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'is_private': isPrivate ? 1 : 0,
      'members': members?.map((member) => member.toJson()).toList(),
    };
  }
}