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
/// This file includes code for the household journal entry edit popup widget.
///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blesseveryhome/hackathon/models/household_journal_entry_model.dart';
import 'package:blesseveryhome/localization/bcw_localizations.dart';
import 'package:blesseveryhome/provider/auth_provider.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

/// A Flutter widget representing a popup for editing a household journal entry.
class HouseholdJournalEditEntryPopup extends StatefulWidget {
  /// Creates a [HouseholdJournalEditEntryPopup] widget.
  const HouseholdJournalEditEntryPopup({super.key});

  @override
  State<HouseholdJournalEditEntryPopup> createState() => _HouseholdJournalEditEntryPopupState();
}

class _HouseholdJournalEditEntryPopupState extends State<HouseholdJournalEditEntryPopup> {
  /// Key for the form widget which can be used to validate the input.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the journal entry text input.
  late final _journalEntryController = TextEditingController(
    text: context.read<HouseholdJournalEntryModel>().text,
  );

  /// Handles the logic when the "Save" button is pressed.
  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<HouseholdJournalEntryModel>().changeNote(
            _journalEntryController.text,
            context.read<PrayerListProvider>().currentRole!,
          );
      if (mounted) context.pop();
    } catch (e) {
      Logger().e(e);
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
    return AlertDialog(
      title: Text(localizations.editNote),
      content: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 125),
        child: Form(
          key: _formKey,
          child: TextFormField(
            autofocus: true,
            controller: _journalEntryController,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(filled: false),
            minLines: 1,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            enabled: context.read<AuthProvider>().person!.emailConfirmed,
            inputFormatters: [LengthLimitingTextInputFormatter(8096)],
            validator: (value) {
              if (value == null || value.length < 2) {
                return localizations.atLeastXCharacters({"x": "2"});
              } else {
                return null;
              }
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: Text(localizations.cancel.toUpperCase()),
        ),
        TextButton(
          onPressed: _onSavePressed,
          child: Text(localizations.saveChanges.toUpperCase()),
        ),
      ],
    );
  }
}
