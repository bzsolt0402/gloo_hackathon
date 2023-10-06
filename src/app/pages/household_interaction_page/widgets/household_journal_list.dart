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
/// This file includes the code for the Household Journal list widget.
///

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blesseveryhome/hackathon/models/household_journal_entry_model.dart';
import 'package:blesseveryhome/hackathon/providers/prayer_journal_provider.dart';
import 'package:blesseveryhome/hackathon/widgets/household_journal/household_journal_entry_popup_menu.dart';
import 'package:blesseveryhome/hackathon/widgets/prayer_journal_widget.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:provider/provider.dart';

/// This widget presents a list of journal entries and allows users to trigger a menu
/// to perform actions on each entry, such as editing or deleting.
class HouseholdJournalList extends StatefulWidget {
  const HouseholdJournalList({super.key});

  @override
  State<HouseholdJournalList> createState() => _HouseholdJournalListState();
}

class _HouseholdJournalListState extends State<HouseholdJournalList> {
  /// The render box used for positioning the context menu.
  late final RenderBox _renderBox;

  /// The position where a tap event occurred to trigger the context menu.
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    // Get the render box associated with the current overlay context.
    _renderBox = Overlay.of(context).context.findRenderObject() as RenderBox;
  }

  /// Stores the tap position when a tap-down event occurs.
  ///
  /// - [details]: The details of the tap-down event.
  void _storeTapPosition(TapDownDetails details) {
    _tapPosition = Offset(
      details.globalPosition.dx,
      details.globalPosition.dy - 96,
    );
  }

  /// Displays a context menu for a specific journal entry.
  ///
  /// - [noteModel]: The journal entry for which the context menu is shown.
  void _showMenu(HouseholdJournalEntryModel noteModel) {
    if (_tapPosition == null) return;
    FocusScope.of(context).unfocus();
    final position = RelativeRect.fromRect(
      _tapPosition! & const Size(40, 40),
      Offset.zero & _renderBox.size,
    );
    showMenu(
      context: context,
      position: position,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: noteModel),
              ChangeNotifierProvider.value(
                value: context.read<PrayerJournalProvider>(),
              ),
              ChangeNotifierProvider.value(
                value: context.read<PrayerListProvider>(),
              ),
            ],
            child: const HouseholdJournalEntryPopupMenu(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<PrayerJournalProvider>().notes;
    return SliverList.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return ChangeNotifierProvider.value(
          value: notes[index],
          child: JournalEntryTile(
            onTap: () => _showMenu(notes[index]),
            onTapDown: _storeTapPosition,
          ).animate().fade(),
        );
      },
    );
  }
}
