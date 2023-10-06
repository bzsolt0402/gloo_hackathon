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
/// This file includes code for the daily prayer page where the prayer prompt is being displayed.
/// The three dots (...) in the code indicates that some code has been removed, that
/// existed before the Hackathon, to demonstrate where the code for Hackathon has been embedded.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/widgets/prayer_prompt.dart';

class DailyPrayerPage extends StatelessWidget {
  const DailyPrayerPage({super.key});

  static const route = "/daily_prayer";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(...),
      body: StreamBuilder(
        stream: ...,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                ...
              } else {
                ...
                return ListenableBuilder(
                  listenable: ...,
                  builder: (context, child) {
                    ...
                    return Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...
                              const PrayerPrompt(),
                              ...
                            ],
                          ),
                        ),
                        ...
                      ],
                    );
                  },
                );
              }
          }
        },
      ),
    );
  }
}
