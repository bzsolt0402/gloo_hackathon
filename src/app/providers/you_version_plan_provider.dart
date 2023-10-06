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
/// This file includes controller code for the YouVersion widget.
///

import 'dart:async';

import 'package:blesseveryhome/hackathon/models/you_version_plan_model.dart';
import 'package:blesseveryhome/model/role_model.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:blesseveryhome/services/api/api_request.dart';
import 'package:blesseveryhome/services/api/http_client.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

/// A provider class responsible for managing YouVersion Bible reading plans.
class YouVersionPlanProvider {
  /// Constructs a [YouVersionPlanProvider] instance.
  ///
  /// - [_prayerListProvider]: The provider responsible for managing the prayer list.
  YouVersionPlanProvider(this._prayerListProvider) {
    _roleSubscription = _prayerListProvider.roleStream.listen(_loadYouVersionPlan);
  }

  /// The provider responsible for managing the prayer list.
  final PrayerListProvider _prayerListProvider;

  /// A subscription to the role stream for receiving role updates.
  late final StreamSubscription<RoleModel> _roleSubscription;

  /// A stream controller for the YouVersion Bible reading plan data.
  final _youVersionPlanController = BehaviorSubject<YouVersionPlanModel?>();

  /// A stream of YouVersion Bible reading plan data.
  Stream<YouVersionPlanModel?> get youVersionPlanStream => _youVersionPlanController.stream;

  /// Refreshes the YouVersion Bible reading plan data.
  ///
  /// This method fetches the YouVersion plan when the current role is available.
  Future<void> refresh() async {
    if (_prayerListProvider.currentRole != null) {
      await _loadYouVersionPlan(_prayerListProvider.currentRole!);
    }
  }

  /// Loads the YouVersion Bible reading plan data based on the provided role.
  ///
  /// - [role]: The role associated with the YouVersion Bible reading plan.
  Future<void> _loadYouVersionPlan(RoleModel role) async {
    try {
      final apiResponse = await HttpClient.post(
        apiRequest: ApiRequest(
          task: "hackathon_getYouVersionPlan",
          role: role,
        ),
      );
      if (apiResponse.success) {
        _youVersionPlanController.add(
          YouVersionPlanModel.fromJson(apiResponse.payload),
        );
      } else {
        _youVersionPlanController.add(null);
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  /// Disposes of the provider by canceling the role subscription.
  void dispose() {
    _roleSubscription.cancel();
  }
}
