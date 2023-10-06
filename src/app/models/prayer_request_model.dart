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
/// This file includes all the code required to represent a Prayer Request.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/model/role_model.dart';
import 'package:blesseveryhome/services/api/api_request.dart';
import 'package:blesseveryhome/services/api/api_response.dart';
import 'package:blesseveryhome/services/api/http_client.dart';

/// Represents a model for a prayer request.
///
/// This class extends [ChangeNotifier] to allow for notifications when the internal state changes.
class PrayerRequestModel extends ChangeNotifier {
  /// Constructs a [PrayerRequestModel] instance.
  ///
  /// - [id]: The unique identifier for the prayer request.
  /// - [text]: The text of the prayer request.
  /// - [_isAnswered]: The private boolean flag indicating whether the prayer request is answered.
  /// - [added]: The date and time when the prayer request was added.
  PrayerRequestModel(
    this.id,
    this.text,
    this._isAnswered,
    this.added,
  );

  /// The unique identifier for the prayer request.
  final int id;

  /// The [DateTime] when the prayer request was added.
  final DateTime added;

  /// The text of the prayer request.
  String text;

  /// The private boolean flag indicating whether the prayer request is answered.
  bool _isAnswered;

  /// Returns `true` if the prayer request is marked as answered; otherwise, returns `false`.
  bool get isAnswered => _isAnswered;

  /// Toggles the answered state of the prayer request and notifies listeners.
  ///
  /// - [role]: The role model used for making API requests.
  /// Returns an [ApiResponse] representing the result of the operation.
  Future<ApiResponse> toggleIsAnsweredState(RoleModel role) async {
    final apiResponse = await HttpClient.post(
      apiRequest: ApiRequest(
        task: "hackathon_setIfLightPrayerRequestIsAnswered",
        payload: {"id": id, "answeredState": !_isAnswered},
        role: role,
      ),
    );
    if (apiResponse.success) {
      _isAnswered = !_isAnswered;
      notifyListeners();
    }
    return apiResponse;
  }

  /// Changes the text of the prayer request and notifies listeners.
  ///
  /// - [trimmedNewText]: The new text for the prayer request.
  /// - [role]: The role model used for making API requests.
  /// Returns an [ApiResponse] representing the result of the operation.
  Future<ApiResponse> changeText(String trimmedNewText, RoleModel role) async {
    final apiResponse = await HttpClient.post(
      apiRequest: ApiRequest(
        task: "hackathon_editLightPrayerRequest",
        payload: {"id": id, "newPrayerRequest": trimmedNewText},
        role: role,
      ),
    );
    if (apiResponse.success) {
      text = trimmedNewText;
      notifyListeners();
    }
    return apiResponse;
  }

  /// Converts this [PrayerRequestModel] to a JSON map.
  ///
  /// Returns a JSON map representing the [PrayerRequestModel].
  Map<String, dynamic> toJson() => {
        "id": id,
        "prayer_request": text,
        "answered": _isAnswered ? 1 : 0,
        "added": added.millisecondsSinceEpoch ~/ 1000,
      };

  /// Factory method to create a [PrayerRequestModel] from a JSON map.
  ///
  /// - [json]: A map containing the JSON data for a [PrayerRequestModel].
  /// Returns a [PrayerRequestModel] instance created from the JSON data.
  factory PrayerRequestModel.fromJson(Map<String, dynamic> json) {
    return PrayerRequestModel(
      json["id"],
      json["prayer_request"],
      json["answered"] == 1,
      DateTime.fromMillisecondsSinceEpoch(json["added"] * 1000),
    );
  }
}
