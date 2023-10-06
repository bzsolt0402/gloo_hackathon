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
/// This file includes code for the household journal's list tile widget.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/models/household_journal_entry_model.dart';
import 'package:blesseveryhome/theme/custom_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// A widget that represents a list tile for displaying a journal entry.
class HouseholdJournalEntryListTile extends StatelessWidget {
  /// Creates a [HouseholdJournalEntryListTile] widget.
  ///
  /// The [onTap] callback is triggered when the tile is tapped.
  ///
  /// The [onTapDown] callback is triggered when a tap gesture is detected.
  const HouseholdJournalEntryListTile({
    super.key,
    this.onTap,
    this.onTapDown,
  });

  /// A date formatter for displaying journal entry dates in a specific format.
  static final noteDateFormat = DateFormat("MMM. d, y");

  /// A callback function to handle the tap gesture on the tile.
  final VoidCallback? onTap;

  /// A callback function to handle tap-down gestures on the tile.
  final Function(TapDownDetails details)? onTapDown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final behColors = theme.extension<BEHColors>()!;
    final journalEntry = context.watch<HouseholdJournalEntryModel>();
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
                journalEntry.text,
                style: const TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 4.0),
              AnimatedSize(
                duration: const Duration(milliseconds: 125),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(noteDateFormat.format(journalEntry.added)),
                    if (journalEntry.isAnswered)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: behColors.success,
                          ),
                          padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
                          child: const Text(
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
