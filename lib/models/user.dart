import 'package:vana_sky_stash/models/household.dart';
import 'package:vana_sky_stash/models/invitation.dart';
import 'package:vana_sky_stash/models/item.dart';
import 'package:vana_sky_stash/models/request.dart';

class User {
  final int id;
  final String name;
  final String code;
  final List<Household>? households;
  final List<Request>? joinRequests;
  final List<Invitation>? receivedInvitations;
  final List<Invitation>? sentInvitations;
  final List<Item>? items;

  User({
    required this.id,
    required this.name,
    required this.code,
    this.households,
    this.joinRequests,
    this.receivedInvitations,
    this.sentInvitations,
    this.items,
  });

  // Factory constructor to create User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      households: json['households'] != null
          ? List<Household>.from(
              json['households'].map((household) => Household.fromJson(household)))
          : null,
      joinRequests: json['joinRequests'] != null
          ? List<Request>.from(
              json['joinRequests'].map((request) => Request.fromJson(request)))
          : null,
      receivedInvitations: json['receivedInvitations'] != null
          ? List<Invitation>.from(json['receivedInvitations']
              .map((invitation) => Invitation.fromJson(invitation)))
          : null,
      sentInvitations: json['sentInvitations'] != null
          ? List<Invitation>.from(
              json['sentInvitations'].map((invitation) => Invitation.fromJson(invitation)))
          : null,
      items: json['items'] != null
          ? List<Item>.from(json['items'].map((item) => Item.fromJson(item)))
          : null,
    );
  }

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'households': households?.map((household) => household.toJson()).toList(),
      'joinRequests': joinRequests?.map((request) => request.toJson()).toList(),
      'receivedInvitations': receivedInvitations?.map((invitation) => invitation.toJson()).toList(),
      'sentInvitations': sentInvitations?.map((invitation) => invitation.toJson()).toList(),
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}
