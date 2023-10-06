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
/// This file includes code for the prayer requests page.
///

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:blesseveryhome/hackathon/models/prayer_request_model.dart';
import 'package:blesseveryhome/hackathon/prayer_requests/prayer_requests_provider.dart';
import 'package:blesseveryhome/hackathon/prayer_requests/widgets/my_prayer_request_popup.dart';
import 'package:blesseveryhome/hackathon/prayer_requests/widgets/prayer_request_list_tile.dart';
import 'package:blesseveryhome/hackathon/snackbar.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:blesseveryhome/theme/custom_colors.dart';
import 'package:blesseveryhome/widgets/help_button.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class LightsPrayerRequestsPage extends StatefulWidget {
  const LightsPrayerRequestsPage({super.key});

  static const route = "/prayer_requests";

  @override
  State<LightsPrayerRequestsPage> createState() => _LightsPrayerRequestsPageState();
}

class _LightsPrayerRequestsPageState extends State<LightsPrayerRequestsPage> {
  /// Store the rendering box reference.
  late final RenderBox _renderBox;

  /// Store the tap position when a user interacts with a prayer request.
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    // Retrieve the rendering box associated with the widget's overlay context.
    _renderBox = Overlay.of(context).context.findRenderObject() as RenderBox;
  }

  /// Store the tap position based on user interaction.
  void _storeTapPosition(TapDownDetails details) {
    _tapPosition = Offset(
      details.globalPosition.dx,
      details.globalPosition.dy - 96,
    );
  }

  /// Show a context menu for a given prayer request.
  void _showMenu(PrayerRequestModel prayerRequest) {
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        _tapPosition! & const Size(40, 40),
        Offset.zero & _renderBox.size,
      ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      items: [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: prayerRequest.isAnswered ? "Mark as unanswered" : "Mark as answered",
                onPressed: () => _onChangeAnsweredStateSelected(prayerRequest),
                icon: prayerRequest.isAnswered
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : const Icon(Icons.check_circle_outline),
              ),
              IconButton(
                tooltip: "Edit",
                onPressed: () => _onEditEntrySelected(prayerRequest),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: "Remove from list",
                onPressed: () => _onDeleteSelected(prayerRequest),
                icon: const Icon(Icons.delete_forever_outlined),
              )
            ],
          ),
        ),
      ],
    );
  }

  /// Handles the selection of "Change Answered State" for a prayer request.
  ///
  /// This method toggles the answered state of the given [prayerRequest].
  /// It closes the context menu, triggers the state change, and displays
  /// a success message if the operation is successful. If an error occurs,
  /// it displays an error message.
  Future<void> _onChangeAnsweredStateSelected(
    PrayerRequestModel prayerRequest,
  ) async {
    context.pop();
    try {
      final apiResponse = await prayerRequest.toggleIsAnsweredState(
        context.read<PrayerListProvider>().currentRole!,
      );
      if (mounted && apiResponse.success) {
        displaySuccessMessage(
            text: "Marked as ${prayerRequest.isAnswered ? "answered" : "unanswered"}.");
      } else {
        displayErrorMessage();
      }
    } catch (e) {
      Logger().e(e);
      displayErrorMessage();
    }
  }

  /// Handles the selection of "Remove" for a prayer request.
  ///
  /// This method removes the given [prayerRequest] from the list of prayer requests,
  /// closes the context menu, and displays a success message if the removal is
  /// successful. If an error occurs during removal, it displays an error message.
  ///
  Future<void> _onDeleteSelected(
    PrayerRequestModel prayerRequest,
  ) async {
    context.pop();
    final provider = context.read<LightsPrayerRequestsProvider>();
    try {
      final apiResponse = await provider.removePrayerRequest(prayerRequest);
      if (mounted && apiResponse.success) {
        displaySuccessMessage();
      } else {
        displayErrorMessage();
      }
    } catch (e) {
      Logger().e(e);
      displayErrorMessage();
    }
  }

  /// Handle the action when a user selects the "Edit" option for a prayer request.
  Future<void> _onEditEntrySelected(PrayerRequestModel prayerRequest) async {
    // Closes context menu.
    final prayerListProvider = context.read<PrayerListProvider>();
    context.pop();
    showDialog(
      context: context,
      builder: (context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: prayerListProvider),
          ],
          child: PrayerRequestEntryFormPopup(prayerRequest: prayerRequest),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final behColors = Theme.of(context).extension<BEHColors>()!;
    return Consumer<LightsPrayerRequestsProvider>(
      builder: (context, provider, child) {
        Widget? floatingActionButton;
        Widget? body;
        switch (provider.status) {
          case Status.loading:
            body = const Center(child: CircularProgressIndicator());
            break;
          case Status.error:
            body = Center(
              child: TextButton(
                onPressed: provider.refresh,
                child: const Text("RETRY"),
              ),
            );
            break;
          case Status.success:
            final lightPrayerRequestsProvider = context.watch<LightsPrayerRequestsProvider>();
            floatingActionButton = FloatingActionButton(
              heroTag: UniqueKey(),
              onPressed: () {
                final prayerListProvider = context.read<PrayerListProvider>();
                showDialog(
                  context: context,
                  builder: (context) {
                    return MultiProvider(
                      providers: [
                        ChangeNotifierProvider.value(
                          value: lightPrayerRequestsProvider,
                        ),
                        ChangeNotifierProvider.value(
                          value: prayerListProvider,
                        ),
                      ],
                      child: const PrayerRequestEntryFormPopup(),
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
            );
            body = RefreshIndicator(
              color: behColors.mainColor,
              onRefresh: lightPrayerRequestsProvider.refresh,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: CustomScrollView(
                  slivers: [
                    SliverList.builder(
                      itemCount: lightPrayerRequestsProvider.myPrayerRequests.length,
                      itemBuilder: (context, index) {
                        return ChangeNotifierProvider.value(
                          value: lightPrayerRequestsProvider.myPrayerRequests[index],
                          child: PrayerRequestListTile(
                            onTap: () =>
                                _showMenu(lightPrayerRequestsProvider.myPrayerRequests[index]),
                            onTapDown: _storeTapPosition,
                          ).animate().fade(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
        }
        return Scaffold(
          appBar: AppBar(
            actions: const [
              AppBarHelpButton(
                body: [
                  Text(
                      "Note that your prayer requests will be visible for other Lights in your neighborhood."),
                ],
              )
            ],
            title: const Text("My Prayer Requests"),
          ),
          floatingActionButton: floatingActionButton,
          body: body,
        );
      },
    );
  }
}
