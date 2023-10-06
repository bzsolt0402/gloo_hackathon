///
/// Code written for:
///
///
///                              ████
///                              ████
///                              ████
///                              ████
///                              ████
///             ███████  ████    ████         ████████              ████████
///           ███████████████    ████      ██████████████        ██████████████
///         ████        █████    ████     ████        ████      ████        ████
///        ████          ████    ████    ████          ████    ████          ████
///         ████        █████    ████     ████        ████      ████        ████
///          ████████████████    ████      ██████████████        ██████████████
///             ███████  ████    ████         ████████              ████████
///                      ████
///                    █████
///                 ██████
///
///                                                    AI & the Church Hackathon
///
///
/// @license The judging committee of the 2023 AI & the Church Hackathon, organized by Gloo LLC,
/// has the permission to use, review, assess, test, and otherwise analyze this file in connection
/// with said Hackathon.
///
/// This file includes code the router of the app. It is used to navigate in the app between
/// routes and provides controllers for the different routes.
///

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/prayer_requests/prayer_requests_page.dart';
import 'package:blesseveryhome/hackathon/prayer_requests/prayer_requests_provider.dart';
import 'package:blesseveryhome/model/prayer_list_item_model.dart';
import 'package:blesseveryhome/pages/daily_prayer_page/daily_prayer_page.dart';
import 'package:blesseveryhome/pages/dashboard_page/dashboard_page.dart';
import 'package:blesseveryhome/pages/home_page/home_page.dart';
import 'package:blesseveryhome/pages/household_interaction_page/household_interaction_page.dart';
import 'package:blesseveryhome/provider/auth_provider.dart';
import 'package:blesseveryhome/provider/dashboard_provider.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [

    // ... Removed codes that existed before and are not required for the Hackathon.

    ShellRoute(
      routes: [
             
        // ... Removed codes that existed before and are not required for the Hackathon.

        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              HomePage(
                navigationShell: navigationShell,
              ),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                name: "Dashboard",
                path: DashboardPage.route,
                builder: (context, state) => const DashboardPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                name: "Daily prayer",
                path: DailyPrayerPage.route,
                builder: (context, state) => const DailyPrayerPage(),
              ),
            ]),
            
            // ... Removed codes that existed before and are not required for the Hackathon.
            
          ],
        ),
      ],
      builder: (context, state, child) =>
          ChangeNotifierProvider(
            create: (context) =>
                PrayerListProvider(
                  context.read<AuthProvider>(),
                ),
            child: child,
          ),
    ),
        
    // ... Removed codes that existed before and are not required for the Hackathon.

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: HouseholdInteractionPage.route,
      builder: (context, state) {
        final arguments = state.extra as Map<String, dynamic>;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: arguments["prayerListItem"] as PrayerListItemModel,
            ),
            ChangeNotifierProvider.value(
              value: arguments["prayerListProvider"] as PrayerListProvider,
            ),
            Provider.value(
              value: arguments["dashboardProvider"] as DashboardProvider,
            ),
          ],
          child: const HouseholdInteractionPage(),
        );
      },
    ),

    // ... Removed codes that existed before and are not required for the Hackathon.

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: LightsPrayerRequestsPage.route,
      builder: (context, state) {
        final arguments = state.extra as Map<String, dynamic>;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) =>
                  LightsPrayerRequestsProvider(
                    arguments["prayerListProvider"] as PrayerListProvider,
                  ),
            ),
            ChangeNotifierProvider.value(
              value: arguments["prayerListProvider"] as PrayerListProvider,
            ),
          ],
          child: const LightsPrayerRequestsPage(),
        );
      },
    ),
  ],
    
  // ... Removed codes that existed before and are not required for the Hackathon.

);
