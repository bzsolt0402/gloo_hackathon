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
/// This file includes code for the prayer prompt widget.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/expandable_text.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:blesseveryhome/provider/prayer_prompt_provider.dart';
import 'package:provider/provider.dart';

/// A widget that displays a prayer prompt provided by the [PrayerPromptProvider].
/// The prayer prompt's text is also wrapped in a custom [ExpandableText] widget,
/// which allows expanding and collapsing the prayer prompt.
class PrayerPrompt extends StatelessWidget {
  const PrayerPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerPromptProvider>(
      builder: (context, provider, child) {
        return AnimatedSize(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 125),
          child: Builder(
            builder: (context) {
              switch (provider.status) {
                case Status.loading:
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24.0),
                      ),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                case Status.error:
                  return const SizedBox.shrink();
                case Status.success:
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24.0),
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: ExpandableText(
                      text: provider.prayerPrompt!.text,
                    ),
                  );
              }
            },
          ),
        );
      },
    );
  }
}
