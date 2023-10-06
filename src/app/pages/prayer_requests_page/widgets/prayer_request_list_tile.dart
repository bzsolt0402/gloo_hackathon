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
/// This file includes code for a single prayer request list tile widget.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/models/prayer_request_model.dart';
import 'package:blesseveryhome/theme/custom_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A widget representing a prayer request list tile.
class PrayerRequestListTile extends StatelessWidget {
  /// Creates a [PrayerRequestListTile] widget.
  ///
  /// The [onTap] and [onTapDown] parameters are required and specify the callback
  /// functions to execute when the list tile is tapped or a tap down event occurs.
  const PrayerRequestListTile({
    super.key,
    required this.onTap,
    required this.onTapDown,
  });

  /// A date format used for displaying the date when the prayer request was added.
  static final prayerRequestDateFormat = DateFormat("MMM. d, y");

  /// A callback function executed when the list tile is tapped.
  final VoidCallback? onTap;

  /// A callback function executed when a tap down event occurs on the list tile.
  final Function(TapDownDetails details)? onTapDown;

  @override
  Widget build(BuildContext context) {
    // Retrieve the current prayer request and theme from the widget's context.
    final prayerRequest = context.watch<PrayerRequestModel>();
    final theme = Theme.of(context);
    final behColors = theme.extension<BEHColors>()!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onTapDown: onTapDown,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prayerRequest.text,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 4.0),
              AnimatedSize(
                duration: const Duration(milliseconds: 125),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // Format and display the date when the prayer request was added.
                      prayerRequestDateFormat.format(prayerRequest.added),
                    ),
                    if (prayerRequest.isAnswered)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: behColors.success,
                          ),
                          padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                          child: const Text(
                            // Display "Answered" in a container when the request is answered.
                            "Answered",
                            style: TextStyle(color: Color(0xDEFFFFFF)),
                          ),
                        ),
                      ),
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
