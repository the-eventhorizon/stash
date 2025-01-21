import 'package:vana_sky_stash/models/household.dart';
import 'package:vana_sky_stash/models/user.dart';

class Request {
  final int id;
  final Household household;
  final User requestingUser;
  final String status;

  Request({
    required this.id,
    required this.household,
    required this.requestingUser,
    required this.status,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      household: Household.fromJson(json['household']),
      requestingUser: User.fromJson(json['requesting_user']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household.toJson(),
      'requesting_user': requestingUser.toJson(),
      'status': status,
    };
  }
}