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
/// This file includes code for the YouVersion Plan widget.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/snackbar.dart';
import 'package:blesseveryhome/hackathon/providers/you_version_plan_provider.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// A widget for displaying YouVersion Bible reading plans.
///
/// This widget displays YouVersion Bible reading plans and allows users to open them.
class YouVersionPlanWidget extends StatelessWidget {
  const YouVersionPlanWidget({super.key});

  /// Opens a YouVersion Bible reading plan using the provided URL.
  ///
  /// - [url]: The URL of the YouVersion Bible reading plan to open.
  ///
  /// This method attempts to parse the URL and launch it using the external application.
  /// If an error occurs during the process, it logs the error using the logger and displays an error message.
  Future<void> _openPlan(String url) async {
    try {
      final uri = Uri.parse(url);
      launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Logger().e(e);
      displayErrorMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<YouVersionPlanProvider>();
    return StreamBuilder(
      stream: provider.youVersionPlanStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return const SizedBox.shrink();
          default:
            if (snapshot.hasError || !snapshot.hasData) {
              return const SizedBox.shrink();
            } else {
              final readingPlan = snapshot.requireData!;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _openPlan(readingPlan.url),
                  child: AnimatedSize(
                    alignment: Alignment.topCenter,
                    duration: const Duration(milliseconds: 125),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24.0),
                          child: Image.network(readingPlan.imgUrl),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "${readingPlan.title.trim()} - ",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: readingPlan.intro,
                                      ),
                                    ],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                  onPressed: () => _openPlan(readingPlan.url),
                                  child: const Text("Start reading plan"),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
        }
      },
    );
  }
}
