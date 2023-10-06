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
/// This file includes code for the dashboard page.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/you_version_module/you_version_plan_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const route = "/dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        // ... Removed codes that existed before and are not required for the Hackathon.

      ),
      body: RefreshIndicator(
        // ... Removed codes that existed before and are not required for the Hackathon.,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // ... Removed codes that existed before and are not required for the Hackathon.
              
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: YouVersionPlanWidget(),
              ),

              // ... Removed codes that existed before and are not required for the Hackathon.

            ],
          ),
        ),
      ),
    );
  }
}
