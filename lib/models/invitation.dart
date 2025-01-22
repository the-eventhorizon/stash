import 'package:vana_sky_stash/models/household.dart';
import 'package:vana_sky_stash/models/user.dart';

class Invitation {
  final int id;
  final Household household;
  final User invitedUser;
  final User inviterUser;
  final String status;

  Invitation({
    required this.id,
    required this.household,
    required this.invitedUser,
    required this.inviterUser,
    required this.status,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'],
      household: Household.fromJson(json['household']),
      invitedUser: User.fromJson(json['invited_user']),
      inviterUser: User.fromJson(json['inviter_user']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'household': household.toJson(),
      'invited_user': invitedUser.toJson(),
      'inviter_user': inviterUser.toJson(),
      'status': status,
    };
  }
}
