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
/// This file includes code for the prayer journal text field widget.
///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blesseveryhome/hackathon/providers/prayer_journal_provider.dart';
import 'package:blesseveryhome/hackathon/snackbar.dart';
import 'package:blesseveryhome/localization/bcw_localizations.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

/// This widget includes features such as validation, character limits,
/// and the ability to submit journal entries to a provider.
class HouseholdJournalEntryTextField extends StatefulWidget {
  const HouseholdJournalEntryTextField({
    super.key,
    this.initialValue,
  });

  /// The initial text value of the text input field, if provided.
  final String? initialValue;

  @override
  State<HouseholdJournalEntryTextField> createState() => _HouseholdJournalEntryTextFieldState();
}

class _HouseholdJournalEntryTextFieldState extends State<HouseholdJournalEntryTextField> {
  /// Key for the form widget which can be used to validate the input.
  final _formKey = GlobalKey<FormState>();

  /// Controller for managing the text input field.
  late final _journalEntryController = TextEditingController(
    text: widget.initialValue,
  );

  /// Callback function invoked when the text input is submitted.
  ///
  /// - [journalEntryText]: The text content of the submitted journal entry.
  Future<void> _onEntrySubmitted(String journalEntryText) async {
    if (!_formKey.currentState!.validate()) return;
    final prayerJournalProvider = context.read<PrayerJournalProvider>();
    try {
      _journalEntryController.clear();
      final apiResponse =
      await prayerJournalProvider.addJournalEntry(journalEntryText);
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

  @override
  void dispose() {
    _journalEntryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = BCWLocalizations.of(context);
    final prayerJournalProvider = context.watch<PrayerJournalProvider>();
    return AnimatedSize(
      alignment: Alignment.topCenter,
      duration: const Duration(milliseconds: 125),
      child: Form(
        key: _formKey,
        child: TextFormField(
          controller: _journalEntryController,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: _onEntrySubmitted,
          // enabled: context.read<AuthProvider>().person!.emailConfirmed,
          inputFormatters: [LengthLimitingTextInputFormatter(8096)],
          decoration: InputDecoration(
            filled: false,
            labelText: prayerJournalProvider.notes.isEmpty
                ? localizations.addPrayerJournalNotesHereLabel
                : localizations.addAnotherNoteLabel,
          ),
          validator: (value) {
            if (value == null || value.length < 2) {
              return localizations.atLeastXCharacters({"x": "2"});
            } else {
              return null;
            }
          },
        ),
      ),
    );
  }
}