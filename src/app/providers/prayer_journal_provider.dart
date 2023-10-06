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
/// This file includes all the code for managing the prayer journal.
///

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/models/household_journal_entry_model.dart';
import 'package:blesseveryhome/hackathon/providers/data_state.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:blesseveryhome/services/api/api_request.dart';
import 'package:blesseveryhome/services/api/api_response.dart';
import 'package:blesseveryhome/services/api/http_client.dart';

/// A provider class responsible for managing prayer journal entries.
class PrayerJournalProvider extends ChangeNotifier {
  /// Constructs a [PrayerJournalProvider] instance.
  ///
  /// - [prayerListItemId]: The identifier of the prayer list item associated with this provider.
  /// - [prayerListProvider]: The provider responsible for managing the prayer list.
  PrayerJournalProvider(
    this.prayerListItemId,
    this.prayerListProvider,
  ) {
    loadPrayerJournals();
  }

  /// The current status of data loading in the provider.
  DataState status = DataState.loading;

  /// A list to store the prayer journal entries.
  final List<HouseholdJournalEntryModel> _notes = [];

  /// The identifier of the prayer list item associated with this provider.
  final int prayerListItemId;

  /// The provider responsible for managing the prayer list.
  final PrayerListProvider prayerListProvider;

  UnmodifiableListView<HouseholdJournalEntryModel> get notes => UnmodifiableListView(_notes);

  /// Loads prayer journal entries from API and updates the provider's state.
  Future<void> loadPrayerJournals() async {
    try {
      status = DataState.loading;
      notifyListeners();
      final apiResponse = await HttpClient.post(
        apiRequest: ApiRequest(
          task: "hackathon_getHouseholdJournalEntries",
          payload: {
            "prayerListItemId": prayerListItemId,
          },
          role: prayerListProvider.currentRole!,
        ),
      );
      _notes.clear();
      final entries = List<HouseholdJournalEntryModel>.from(
        apiResponse.payload?.map((e) => HouseholdJournalEntryModel.fromJson(e)),
      );
      entries.sort((a, b) => b.added.compareTo(a.added));
      _notes.addAll(entries);
      status = DataState.success;
    } catch (e) {
      status = DataState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Adds a new journal entry with the provided text content and sends it to the API for storage.
  ///
  /// - [noteText]: The text content of the new journal entry.
  ///
  /// Returns an [ApiResponse] representing the result of adding the journal entry.
  Future<ApiResponse> addJournalEntry(String noteText) async {
    noteText = noteText.trim();
    final apiResponse = await HttpClient.post(
      apiRequest: ApiRequest(
        task: "hackathon_addHouseholdJournalEntry",
        payload: {
          "prayerListItemId": prayerListItemId,
          "newEntry": noteText,
        },
        role: prayerListProvider.currentRole!,
      ),
    );

    if (apiResponse.success) {
      _notes.insert(
        0,
        HouseholdJournalEntryModel(
          id: apiResponse.payload["id"],
          added: DateTime.now().toUtc(),
          text: noteText,
        ),
      );
      notifyListeners();
    }
    return apiResponse;
  }

  /// Deletes a journal entry and sends the deletion request to the API.
  ///
  /// - [journalEntry]: The journal entry to be deleted.
  ///
  /// Returns an [ApiResponse] representing the result of the deletion request.
  Future<ApiResponse> deleteNote(HouseholdJournalEntryModel journalEntry) async {
    final apiResponse = await HttpClient.post(
      apiRequest: ApiRequest(
        task: "hackathon_deleteHouseholdJournalEntry",
        payload: {"id": journalEntry.id},
        role: prayerListProvider.currentRole!,
      ),
    );
    if (apiResponse.success) {
      _notes.remove(journalEntry);
      notifyListeners();
    }
    return apiResponse;
  }
}
