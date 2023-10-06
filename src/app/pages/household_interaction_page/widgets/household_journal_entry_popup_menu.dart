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
/// This file includes code for the household journal entry popup menu widget.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/models/household_journal_entry_model.dart';
import 'package:blesseveryhome/hackathon/providers/prayer_journal_provider.dart';
import 'package:blesseveryhome/hackathon/snackbar.dart';
import 'package:blesseveryhome/hackathon/widgets/household_journal/household_journal_edit_entry_popup.dart';
import 'package:blesseveryhome/localization/bcw_localizations.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:blesseveryhome/theme/custom_colors.dart';
import 'package:blesseveryhome/utils/custom_dialogs.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

/// This widget provides a set of actions that can be performed on a journal entry within a household.
class HouseholdJournalEntryPopupMenu extends StatefulWidget {
  const HouseholdJournalEntryPopupMenu({super.key});

  @override
  State<HouseholdJournalEntryPopupMenu> createState() =>
      _HouseholdJournalEntryPopupMenuState();
}

class _HouseholdJournalEntryPopupMenuState
    extends State<HouseholdJournalEntryPopupMenu> {
  /// Handles the "Delete Entry" action.
  ///
  /// - [prayerJournalProvider]: The provider for managing prayer journal entries.
  /// - [note]: The journal entry to delete.
  Future<void> _onDeleteEntrySelected(
    PrayerJournalProvider prayerJournalProvider,
    HouseholdJournalEntryModel note,
  ) async {
    context.pop();
    final localizations = BCWLocalizations.of(context);
    // Show a confirmation dialog before proceeding with the deletion.
    final isDeleteApproved = await showApprovalDialog(
      context,
      Text(localizations.deleteNoteQuestion),
      Text(localizations.cancel.toUpperCase()),
      Text(localizations.delete.toUpperCase()),
    );
    if (!isDeleteApproved) return;
    try {
      final apiResponse = await prayerJournalProvider.deleteNote(note);
      if (apiResponse.success) {
        displaySuccessMessage();
      } else {
        displayErrorMessage();
      }
    } catch (e) {
      Logger().e(e);
      displayErrorMessage();
    }
  }

  /// Handles the "Edit Entry" action.
  ///
  /// - [note]: The journal entry to edit.
  Future<void> _onEditEntrySelected(HouseholdJournalEntryModel note) async {
    showDialog(
      context: context,
      builder: (context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: note),
            ChangeNotifierProvider.value(
              value: this.context.read<PrayerListProvider>(),
            ),
          ],
          child: const HouseholdJournalEditEntryPopup(),
        );
      },
    );
  }

  /// Handles the "Change Answered State" action.
  ///
  /// - [journalEntry]: The journal entry for which the answered state is changed.
  Future<void> _onChangeAnsweredStateSelected(
    HouseholdJournalEntryModel journalEntry,
  ) async {
    context.pop();
    try {
      final apiResponse = await journalEntry.toggleIsAnsweredState(
          context.read<PrayerListProvider>().currentRole!);
      if (mounted && apiResponse.success) {
        displaySuccessMessage(
            text:
                "Marked as ${journalEntry.isAnswered ? "answered" : "unanswered"}.");
      } else {
        displayErrorMessage();
      }
    } catch (e) {
      Logger().e(e);
      displayErrorMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalEntry = context.watch<HouseholdJournalEntryModel>();
    final prayerJournalProvider = context.watch<PrayerJournalProvider>();
    final behColors = Theme.of(context).extension<BEHColors>()!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: journalEntry.isAnswered
              ? "Mark as unanswered"
              : "Mark as answered",
          onPressed: () => _onChangeAnsweredStateSelected(journalEntry),
          icon: journalEntry.isAnswered
              ? Icon(
                  Icons.check_circle,
                  color: behColors.success,
                )
              : const Icon(Icons.check_circle_outline),
        ),
        IconButton(
          onPressed: () => _onEditEntrySelected(journalEntry),
          icon: const Icon(Icons.edit),
        ),
        IconButton(
          onPressed: () =>
              _onDeleteEntrySelected(prayerJournalProvider, journalEntry),
          icon: const Icon(Icons.delete_forever_outlined),
        ),
      ],
    );
  }
}
