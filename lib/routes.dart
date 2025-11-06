import 'package:flutter/material.dart';
import 'package:shopping_list/models/household.dart';
import 'package:shopping_list/screens/household_details_screen.dart';
import 'package:shopping_list/screens/register_screen.dart';
import 'package:shopping_list/screens/login_screen.dart';
import 'package:shopping_list/screens/home_screen.dart';
import 'package:shopping_list/screens/create_household_screen.dart';
import 'package:shopping_list/screens/edit_household_screen.dart';
import 'package:shopping_list/screens/create_shopping_list_screen.dart';
import 'package:shopping_list/screens/setting_screen.dart';
import 'package:shopping_list/screens/shopping_list_details_screen.dart';
import 'package:shopping_list/screens/user_screen.dart';
import 'package:shopping_list/screens/pending_invitations_screen.dart';
import 'package:shopping_list/screens/pending_requests_screen.dart';

Map<String, WidgetBuilder> getRoutes() {
  return {
    '/home': (context) => HomeScreen(),
    '/register': (context) => RegisterScreen(),
    '/login': (context) => LoginScreen(),
    '/create-household': (context) => CreateHouseholdScreen(),
    '/settings': (context) => SettingScreen(),
    '/user' : (context) => UserScreen(),
    '/pending_invitations' : (context) => PendingInvitationsScreen(),
    '/pending-requests' : (context) => PendingRequestsScreen(),
    '/edit-household': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Household;
      return EditHouseholdScreen(household: args);
    },
    '/household-details': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Household;
      return HouseholdDetailsScreen(household: args);
    },
    '/create-shopping-list': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Household;
      return CreateShoppingListScreen(household: args);
    },
    '/shopping-list-details': (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
      return ShoppingListDetailsScreen(
        household: args['household'],
        shoppingList: args['list'],
      );
    }
  };
}