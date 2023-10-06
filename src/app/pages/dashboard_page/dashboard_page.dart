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
/// The three dots (...) in the code indicates that some code has been removed, that
/// existed before the Hackathon, to demonstrate where the code for Hackathon has been embedded.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/you_version_module/you_version_plan_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const route = "/dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(...),
      body: RefreshIndicator(
        ...,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...,
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: YouVersionPlanWidget(),
              ),
              ...,
            ],
          ),
        ),
      ),
    );
  }
}
