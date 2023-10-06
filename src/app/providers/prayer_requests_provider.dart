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
/// This file includes controller code for the Light's prayer request page.
///

import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/models/prayer_request_model.dart';
import 'package:blesseveryhome/model/role_model.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:blesseveryhome/services/api/api_request.dart';
import 'package:blesseveryhome/services/api/api_response.dart';
import 'package:blesseveryhome/services/api/http_client.dart';
import 'package:logger/logger.dart';

/// A Provider class responsible for managing and providing access to prayer requests data.
///
/// This class extends [ChangeNotifier] to allow other widgets to listen to changes in the
/// data and rebuild when necessary. It loads, adds, and removes prayer requests while
/// maintaining the current status of the data loading process.
class LightsPrayerRequestsProvider extends ChangeNotifier {
  /// Constructor for the MyPrayerRequestsProvider class.
  ///
  /// This constructor automatically triggers the loading of prayer requests
  /// when an instance of this class is created.
  LightsPrayerRequestsProvider(this._prayerListProvider) {
    _roleSubscription =
        _prayerListProvider.roleStream.listen(_loadMyPrayerRequests);
  }

  /// The current status of the data loading process.
  Status _status = Status.loading;

  /// Getter method to retrieve the current status of the data.
  ///
  /// The `status` getter returns the current status of the data loading process.
  /// It provides read-only access to the `_status` property, allowing other
  /// classes or widgets to query the status without directly modifying it.
  Status get status => _status;

  late final StreamSubscription<RoleModel> _roleSubscription;

  final PrayerListProvider _prayerListProvider;

  /// A list of prayer requests stored as instances of [PrayerRequestModel].
  final List<PrayerRequestModel> _myPrayerRequests = [];

  /// Provides an unmodifiable view of the prayer requests list.
  ///
  /// This getter returns an [UnmodifiableListView] of the prayer requests list,
  /// preventing external modifications to the list.
  UnmodifiableListView<PrayerRequestModel> get myPrayerRequests =>
      UnmodifiableListView(_myPrayerRequests);

  Future<void> refresh() async {
    if (_prayerListProvider.currentRole != null) {
      await _loadMyPrayerRequests(_prayerListProvider.currentRole!);
    }
  }

  /// Loads prayer requests data from API.
  ///
  /// This method makes an API request to fetch prayer requests data and populates
  /// the [_myPrayerRequests] list with the received data. It updates the [status]
  /// accordingly and notifies listeners of any changes in the data.
  Future<void> _loadMyPrayerRequests(RoleModel role) async {
    try {
      final apiResponse = await HttpClient.post(
        apiRequest: ApiRequest(
          task: "hackathon_getLightPrayerRequests",
          role: role,
        ),
      );
      if (apiResponse.success) {
        _myPrayerRequests.clear();
        final prayerRequests = List<PrayerRequestModel>.from(
          apiResponse.payload.map((e) => PrayerRequestModel.fromJson(e)),
        );
        prayerRequests.sort((a, b) => b.added.compareTo(a.added));
        _myPrayerRequests.addAll(prayerRequests);
        _status = Status.success;
        notifyListeners();
      } else {
        _status = Status.error;
        notifyListeners();
      }
    } catch (e) {
      Logger().e(e);
      _status = Status.error;
      notifyListeners();
    }
  }

  /// Adds a new prayer request to the list.
  ///
  /// This method sends a request to the API to add a new prayer request with the
  /// specified [trimmedText]. If the request is successful, it adds the new prayer
  /// request to the [_myPrayerRequests] list and notifies listeners of the change.
  ///
  /// Returns an [ApiResponse] object containing the result of the API request.
  Future<ApiResponse> addPrayerRequest(String trimmedText) async {
    final apiResponse = await HttpClient.post(
      apiRequest: ApiRequest(
        task: "hackathon_addLightPrayerRequest",
        payload: {"prayerRequest": trimmedText},
        role: _prayerListProvider.currentRole!,
      ),
    );
    if (apiResponse.success) {
      _myPrayerRequests.insert(
        0,
        PrayerRequestModel(
          apiResponse.payload["id"],
          trimmedText,
          false,
          DateTime.now(),
        ),
      );
      notifyListeners();
    }
    return apiResponse;
  }

  /// Removes a prayer request from the list.
  ///
  /// This method sends a request to the API to remove the specified [prayerRequestModel]
  /// from the list of prayer requests. If the request is successful, it removes the
  /// prayer request from the [_myPrayerRequests] list and notifies listeners of the change.
  ///
  /// Returns an [ApiResponse] object containing the result of the API request.
  Future<ApiResponse> removePrayerRequest(
    PrayerRequestModel prayerRequestModel,
  ) async {
    final apiResponse = await HttpClient.post(
      apiRequest: ApiRequest(
        task: "hackathon_deleteLightPrayerRequest",
        payload: {"id": prayerRequestModel.id},
        role: _prayerListProvider.currentRole!,
      ),
    );
    if (apiResponse.success) {
      _myPrayerRequests.remove(prayerRequestModel);
      notifyListeners();
    }
    return apiResponse;
  }

  @override
  void dispose() {
    _roleSubscription.cancel();
    super.dispose();
  }
}
