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
/// This file includes all the code for loading the prayer prompt widget.
/// Some of its code existed before the Hackathon, but now it is based on the user's role.
///

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/models/prayer_prompt_model.dart';
import 'package:blesseveryhome/model/role_model.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:blesseveryhome/services/api/api_request.dart';
import 'package:blesseveryhome/services/api/http_client.dart';
import 'package:logger/logger.dart';

/// A class that provides prayer prompts based on the current user's role.
class PrayerPromptProvider extends ChangeNotifier with WidgetsBindingObserver {
  /// Constructs a [PrayerPromptProvider] instance.
  ///
  /// The [_prayerListProvider] parameter is required and provides access to the
  /// current user's role information.
  PrayerPromptProvider(this._prayerListProvider) {
    WidgetsBinding.instance.addObserver(this);
    _roleSubscription = _prayerListProvider.roleStream.listen(_getPrayerPrompt);
  }

  final PrayerListProvider _prayerListProvider;

  /// A subscription to the role stream for listening to role changes.
  late final StreamSubscription<RoleModel> _roleSubscription;

  /// The timestamp when the prayer prompt was last updated.
  DateTime? _lastUpdatedAt;

  /// The current status of the prayer prompt provider.
  Status status = Status.loading;

  /// The prayer prompt model to be provided to the user.
  PrayerPromptModel? prayerPrompt;

  /// Retrieves a prayer prompt based on the given [role].
  ///
  /// This method sets the [status] to loading, fetches the prayer prompt
  /// from the API, and updates the [prayerPrompt] and [status] accordingly.
  Future<void> _getPrayerPrompt(RoleModel role) async {
    try {
      status = Status.loading;
      notifyListeners();
      final apiResponse = await HttpClient.post(
        apiRequest: ApiRequest(
          task: "hackathon_getPrayerPrompt",
          role: role,
        ),
      );
      if (apiResponse.success) {
        prayerPrompt = PrayerPromptModel.fromJson(apiResponse.payload);
        status = Status.success;
        _lastUpdatedAt = DateTime.now().toUtc();
      } else {
        status = Status.error;
      }
      notifyListeners();
    } catch (e) {
      Logger().e(e);
      if (prayerPrompt == null) {
        status = Status.error;
        notifyListeners();
      }
    }
  }

  /// Refreshes the prayer prompt if it's required based on the last update time.
  ///
  /// If [_lastUpdatedAt] is not set or if the current date is different from the
  /// last update date, this method fetches a new prayer prompt for the current role.
  Future<void> refreshIfRequired() async {
    if (_lastUpdatedAt == null) return;
    final now = DateTime.now().toUtc();
    if (!DateUtils.isSameDay(now, _lastUpdatedAt)) {
      _getPrayerPrompt(_prayerListProvider.currentRole!);
    }
  }

  /// When the app is resuming from the background, try to refresh if needed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshIfRequired();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _roleSubscription.cancel();
    super.dispose();
  }
}
