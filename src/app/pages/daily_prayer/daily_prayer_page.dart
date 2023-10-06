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
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/widgets/prayer_prompt.dart';

class DailyPrayerPage extends StatelessWidget {
  const DailyPrayerPage({super.key});

  static const route = "/daily_prayer";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        // ... Removed codes that existed before and are not required for the Hackathon.

      ),
      body: StreamBuilder(
        stream: // ... Removed codes that existed before and are not required for the Hackathon.,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                
                // ... Removed codes that existed before and are not required for the Hackathon.

              } else {
                                
                // ... Removed codes that existed before and are not required for the Hackathon.

                return ListenableBuilder(
                  listenable: // ... Removed codes that existed before and are not required for the Hackathon.
                  builder: (context, child) {

                    // ... Removed codes that existed before and are not required for the Hackathon.

                    return Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                                        
                              // ... Removed codes that existed before and are not required for the Hackathon.

                              const PrayerPrompt(),

                              // ... Removed codes that existed before and are not required for the Hackathon.

                            ],
                          ),
                        ),
                                                
                        // ... Removed codes that existed before and are not required for the Hackathon.

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
