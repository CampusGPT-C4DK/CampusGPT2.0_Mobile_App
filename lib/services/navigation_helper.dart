import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Safe navigation helper to prevent app crashes during navigation
class NavigationHelper {
  /// Safely navigate to a route
  static Future<void> navigateTo(BuildContext context, String route) async {
    try {
      if (!context.mounted) {
        print('❌ Navigation failed: Context not mounted');
        return;
      }

      print('🔀 Navigating to: $route');

      // Use Future.microtask to ensure navigation happens after current frame
      await Future.microtask(() {
        if (context.mounted) {
          context.go(route);
        }
      });
    } catch (e) {
      print('❌ Navigation error to $route: $e');
    }
  }

  /// Safely replace the current route (doesn't keep history)
  static Future<void> replaceTo(BuildContext context, String route) async {
    try {
      if (!context.mounted) {
        print('❌ Navigation failed: Context not mounted');
        return;
      }

      print('🔀 Replacing route with: $route');

      await Future.microtask(() {
        if (context.mounted) {
          context.go(route);
        }
      });
    } catch (e) {
      print('❌ Replace navigation error to $route: $e');
    }
  }

  /// Safely pop the current route
  static void popRoute(BuildContext context) {
    try {
      if (!context.mounted) {
        print('❌ Pop failed: Context not mounted');
        return;
      }

      if (context.canPop()) {
        print('🔙 Popping route');
        context.pop();
      } else {
        print('⚠️ Cannot pop - at root of navigation stack');
      }
    } catch (e) {
      print('❌ Pop navigation error: $e');
    }
  }
}
