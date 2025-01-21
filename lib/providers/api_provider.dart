import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vana_sky_stash/models/household.dart';
import 'package:vana_sky_stash/models/invitation.dart';
import 'package:vana_sky_stash/models/item.dart';
import 'package:vana_sky_stash/models/request.dart';
import 'package:vana_sky_stash/models/shopping_list.dart';
import 'package:vana_sky_stash/providers/auth_provider.dart';

class ApiProvider {
  final Dio dio = Dio();
  String baseUrl = 'https://list.vanasky.com/api';

  ApiProvider() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await AuthProvider().getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          String errorMessage;
          final trans = AppLocalizations.of(e.requestOptions.extra['context'])!;
          if (e.response != null) {
            switch (e.response?.statusCode) {
              case 400:
                errorMessage = trans.error_400;
                break;
              case 401:
                errorMessage = trans.error_401;
                break;
              case 403:
                errorMessage = trans.error_403;
                break;
              case 404:
                errorMessage = trans.error_404;
                break;
              case 500:
                errorMessage = trans.error_500;
                break;
              default:
                errorMessage = trans.error_unknown;
            }
          } else {
            errorMessage = trans.error_network;
          }
          handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: errorMessage,
            ),
          );
        },
      ),
    );
  }

  // ----------------- API CALLS -----------------

  // ----------------- Authentication -----------------

  Future<void> register(BuildContext context, String name, String password,
      String confirmedPassword) async {
    try {
      await dio.post('$baseUrl/register', data: {
        'name': name,
        'password': password,
        'password_confirmation': confirmedPassword,
      });
      // Set the registration flag
      await AuthProvider().register();
    } catch (e) {
      if (!context.mounted) return;
      throw Exception('${AppLocalizations.of(context)!.error_register} $e');
   }
  }

  Future<void> login(BuildContext context, String name, String password) async {
    try {
      final response = await dio.post('$baseUrl/login', data: {
        'name': name,
        'password': password,
      });
      final token = response.data['token'];
      final user = response.data['user'];
      await AuthProvider()
          .storeUserDetails(token, user['id'].toString(), user['name']);
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_login);
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await dio.post('$baseUrl/logout');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.error_logout)));
    } finally {
      await AuthProvider().clearUserDetails();
    }
  }

  Future<void> deleteAccount(BuildContext context, userId) async {
    try {
      await dio.delete('$baseUrl/user/$userId');
      await AuthProvider().clearUserDetails();
      await AuthProvider().deregister();
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_delete_account);
    }
  }

  // ----------------- Households -----------------

  Future<List<Household>> getHouseholds(BuildContext context) async {
    try {
      final response = await dio.get('$baseUrl/households');
      final households = (response.data as List)
          .map((householdJson) => Household.fromJson(householdJson))
          .toList();
      return households;
    } catch (e) {
      if (!context.mounted) return [];
      throw Exception(
          '${AppLocalizations.of(context)!.error_get_households} $e');
    }
  }

  Future<void> createHousehold(BuildContext context, String name) async {
    try {
      await dio.post('$baseUrl/households', data: {
        'name': name,
      });
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(
          '${AppLocalizations.of(context)!.error_create_household} $e');
    }
  }

  Future<void> inviteUserToHousehold(
      BuildContext context, int householdId, String userEmail) async {
    try {
      await dio.post('$baseUrl/households/$householdId/invite', data: {
        'email': userEmail,
      });
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_invite_user);
    }
  }

  Future<void> leaveHousehold(BuildContext context, int householdId) async {
    try {
      await dio.patch('$baseUrl/households/$householdId/leave');
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_leave_household);
    }
  }

  Future<void> removeUserFromHousehold(
      BuildContext context, int householdId, int userId) async {
    try {
      await dio.patch('$baseUrl/households/$householdId/remove/user/$userId');
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_remove_user);
    }
  }

  Future<void> updateHousehold(
      BuildContext context, int householdId, String name) async {
    try {
      await dio.patch('$baseUrl/households/$householdId', data: {
        'name': name,
      });
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_update_household);
    }
  }

  Future<void> deleteHousehold(BuildContext context, int householdId) async {
    try {
      await dio.delete('$baseUrl/households/$householdId');
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_delete_household);
    }
  }

  // ----------------- Shopping Lists -----------------

  Future<List<ShoppingList>> getLists(
      BuildContext context, int householdId) async {
    try {
      final response =
          await dio.get('$baseUrl/households/$householdId/shoppinglists');
      return (response.data as List)
          .map((listJson) => ShoppingList.fromJson(listJson))
          .toList();
    } catch (e) {
      if (!context.mounted) return [];
      throw Exception('${AppLocalizations.of(context)!.error_get_lists} $e');
    }
  }

  Future<ShoppingList> getList(
      BuildContext context, int householdId, int listId) async {
    try {
      final response = await dio
          .get('$baseUrl/households/$householdId/shoppinglists/$listId');
      return ShoppingList.fromJson(response.data);
    } catch (e) {
      if (!context.mounted) {
        return ShoppingList(
            id: 0,
            name: '',
            household:
                Household(id: 0, name: '', ownerId: 0, isPrivate: false));
      }
      throw Exception(AppLocalizations.of(context)!.error_get_list);
    }
  }

  Future<void> createList(
      BuildContext context, int householdId, String listName) async {
    try {
      await dio.post('$baseUrl/households/$householdId/shoppinglists', data: {
        'name': listName,
      });
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_create_list);
    }
  }

  Future<void> updateList(
      BuildContext context, int householdId, int listId, String newName) async {
    try {
      await dio.patch('$baseUrl/households/$householdId/shoppinglists/$listId',
          data: {
            'name': newName,
          });
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_update_list);
    }
  }

  Future<void> deleteList(
      BuildContext context, int householdId, int listId) async {
    try {
      await dio
          .delete('$baseUrl/households/$householdId/shoppinglists/$listId');
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_delete_list);
    }
  }

  // ----------------- Items -----------------

  Future<void> addItem(BuildContext context, int householdId, int listId,
      String itemName) async {
    try {
      await dio.post(
          '$baseUrl/households/$householdId/shoppinglists/$listId/items',
          data: {
            'name': itemName,
          });
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_add_item);
    }
  }

  Future<List<Item>> getItems(
      BuildContext context, int householdId, int listId) async {
    try {
      final response = await dio
          .get('$baseUrl/households/$householdId/shoppinglists/$listId/items');
      return (response.data as List)
          .map((itemJson) => Item.fromJson(itemJson))
          .toList();
    } catch (e) {
      if (!context.mounted) return [];
      throw Exception(AppLocalizations.of(context)!.error_get_items);
    }
  }

  Future<void> toggleItemChecked(BuildContext context, int householdId,
      int listId, int itemId, bool checked) async {
    try {
      final response = await dio.patch(
          '$baseUrl/households/$householdId/shoppinglists/$listId/items/$itemId/check',
          data: {
            'checked': checked,
          });
      if (response.statusCode == 200) {
      } else {
        if (!context.mounted) return;
        throw Exception(AppLocalizations.of(context)!.error_update_item);
      }
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_update_item);
    }
  }

  Future<void> updateItem(BuildContext context, int householdId, int listId,
      int itemId, String newName) async {
    try {
      await dio.patch(
          '$baseUrl/households/$householdId/shoppinglists/$listId/items/$itemId',
          data: {
            'name': newName,
          });
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_update_item);
    }
  }

  Future<void> deleteItem(
      BuildContext context, int householdId, int listId, int itemId) async {
    try {
      await dio.delete(
          '$baseUrl/households/$householdId/shoppinglists/$listId/items/$itemId');
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_delete_item);
    }
  }

  // ----------------- Invitations -----------------

  Future<List<Invitation>> getInvitations(BuildContext context) async {
    try {
      final response = await dio.get('$baseUrl/user/invitations');

      return (response.data as List)
          .map((invitationJson) => Invitation.fromJson(invitationJson))
          .toList();
    } catch (e) {
      if (!context.mounted) return [];
      throw Exception(AppLocalizations.of(context)!.error_get_invitations);
    }
  }

  Future<void> respondToInvitation(BuildContext context, int invitationId, String status) async {
    try {
      await dio.post('$baseUrl/user/invitations/$invitationId',
        data: {
          'status': status,
        }
      );
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_respond_to_invitation);
    }
  }

  // ----------------- Requests -----------------

  Future<List<Request>> getRequests(BuildContext context) async {
    try {
      final response = await dio.get('$baseUrl/user/requests');
      return (response.data as List)
          .map((requestJson) => Request.fromJson(requestJson))
          .toList();
    } catch (e) {
      if (!context.mounted) return [];
      throw Exception(AppLocalizations.of(context)!.error_get_requests);
    }
  }

  Future<void> respondToRequest(BuildContext context, int requestId, String status) async {
    try {
      await dio.post('$baseUrl/user/requests/$requestId',
        data: {
          'status': status,
        }
      );
    } catch (e) {
      if (!context.mounted) return;
      throw Exception(AppLocalizations.of(context)!.error_respond_to_request);
    }
  }
}
