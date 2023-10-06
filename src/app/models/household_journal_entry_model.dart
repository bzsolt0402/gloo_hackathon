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
/// This file includes all the code required to represent a Household Journal Entry.
/// Some of its code existed before the Hackathon.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/model/role_model.dart';
import 'package:blesseveryhome/services/api/api_request.dart';
import 'package:blesseveryhome/services/api/api_response.dart';
import 'package:blesseveryhome/services/api/http_client.dart';

/// A model class representing a household journal entry.
///
/// This class extends [ChangeNotifier] to allow for notifications when the internal state changes.
class HouseholdJournalEntryModel extends ChangeNotifier {
  /// Constructs a [HouseholdJournalEntryModel] instance with the given parameters.
  ///
  /// - [id]: The unique identifier for this journal entry.
  /// - [added]: The date and time when the prayer request was added.
  /// - [text]: The content of the journal entry.
  /// - [isAnswered]: A boolean flag indicating whether the entry is answered (default is false).
  HouseholdJournalEntryModel({
    required this.id,
    required this.added,
    required this.text,
    this.isAnswered = false,
  });

  /// The unique identifier for this journal entry.
  final int id;

  /// The [DateTime] when this entry was added.
  final DateTime added;

  /// The content of the journal entry.
  String text;

  /// A boolean flag indicating whether the entry is answered.
  bool isAnswered;

  /// Toggles the [isAnswered] state of the journal entry and sends an API request to update it.
  ///
  /// - [role]: The role associated with the API request.
  ///
  /// Returns an [ApiResponse] representing the result of the API request.
  Future<ApiResponse> toggleIsAnsweredState(RoleModel role) async {
    final apiResponse = await HttpClient.post(
      apiRequest: ApiRequest(
        task: "hackathon_setIfHouseholdJournalEntryIsAnswered",
        payload: {"id": id, "answeredState": !isAnswered},
        role: role,
      ),
    );
    if (apiResponse.success) {
      isAnswered = !isAnswered;
      notifyListeners();
    }
    return apiResponse;
  }

  /// Changes the [text] of the journal entry and sends an API request to update it.
  ///
  /// - [newText]: The new content for the journal entry.
  /// - [role]: The role associated with the API request.
  ///
  /// Note: The [newText] parameter is trimmed before updating the entry.
  Future<void> changeNote(String newText, RoleModel role) async {
    newText = newText.trim();
    final apiResponse = await HttpClient.post(
      apiRequest: ApiRequest(
        task: "hackathon_editHouseholdJournalEntry",
        payload: {"id": id, "newEntry": newText},
        role: role,
      ),
    );
    if (!apiResponse.success) return;
    text = newText;
    notifyListeners();
  }

  /// Factory method to create a [HouseholdJournalEntryModel] from a JSON map.
  ///
  /// - [json]: A map containing the JSON data for a journal entry.
  ///
  /// Returns a [HouseholdJournalEntryModel] instance created from the JSON data.
  factory HouseholdJournalEntryModel.fromJson(Map<String, dynamic> json) {
    return HouseholdJournalEntryModel(
      id: json["id"],
      added: DateTime.fromMillisecondsSinceEpoch(json["added"] * 1000),
      text: json["note"],
      isAnswered: json["answered"] == 1,
    );
  }

  /// Converts this [HouseholdJournalEntryModel] to a JSON map.
  ///
  /// Returns a JSON map representing the properties of this journal entry.
  Map<String, dynamic> toJson() => {
        "id": id,
        "added": added.millisecondsSinceEpoch ~/ 1000,
        "note": text,
        "answered": isAnswered ? 1 : 0,
      };
}
