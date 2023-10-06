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
///                                                     AI & the Church Hackathon
///
///
/// @license The judging committee of the 2023 AI & the Church Hackathon, organized by Gloo LLC,
/// has the permission to use, review, assess, test, and otherwise analyze this file in connection
/// with said Hackathon.
///
/// This file includes all the code for a prayer request dialog popup that can be used for editing
/// or adding a new prayer request based on the passed prayerRequest in the widget's constructor.
///
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blesseveryhome/hackathon/models/prayer_request_model.dart';
import 'package:blesseveryhome/hackathon/prayer_requests/prayer_requests_provider.dart';
import 'package:blesseveryhome/localization/bcw_localizations.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:blesseveryhome/utils/snackbar.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

/// A widget that displays a form for editing or adding a prayer request in a dialog popup.
class PrayerRequestEntryFormPopup extends StatefulWidget {
  /// Creates a [PrayerRequestEntryFormPopup] widget.
  ///
  /// The [prayerRequest] parameter is optional and represents the initial
  /// prayer request to edit. If provided, the widget will be in editing mode;
  /// otherwise, it will be in new request mode.

  const PrayerRequestEntryFormPopup({super.key, this.prayerRequest});

  /// The prayer request model to edit or null when adding a new prayer request.
  final PrayerRequestModel? prayerRequest;

  @override
  State<PrayerRequestEntryFormPopup> createState() => _PrayerRequestEntryFormPopupState();
}

class _PrayerRequestEntryFormPopupState extends State<PrayerRequestEntryFormPopup> {
  /// Key for the form widget which can be used to validate the input.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the prayer request text input. Can be initialized with
  /// an initial text. If an existing prayer request is passed into this widget's
  /// constructor, then the widget will be in an editing mode, else it will
  /// behave to add a new prayer request.
  late final _prayerRequestController = TextEditingController(
    text: widget.prayerRequest?.text,
  );

  /// Edits an existing prayer request.
  ///
  /// This function validates the edited text against the original prayer request
  /// text and sends the edited text to the server to update the prayer request.
  /// If the edited text is the same as the original text, it cancels the edit
  /// operation. If the update is successful, it closes the prayer request editing
  /// dialog and shows a success message; otherwise, it displays an error message.
  Future<void> _editPrayerRequest() async {
    if (_prayerRequestController.text.trim() == widget.prayerRequest!.text) {
      context.pop();
      return;
    }
    try {
      final apiResponse = await widget.prayerRequest!.changeText(
        _prayerRequestController.text.trim(),
        context.read<PrayerListProvider>().currentRole!,
      );
      if (apiResponse.success) {
        if (mounted) context.pop();
        showGeneralFeedbackSnackBar(body: "Changes saved.");
      } else {
        showGeneralFeedbackSnackBar(body: "Could not save your changes.");
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  /// Adds a new prayer request.
  ///
  /// This function sends a new prayer request to the server via the provided
  /// [LightsPrayerRequestsProvider]. It awaits the server's response and handles
  /// the success or failure of adding the prayer request accordingly. If the
  /// request is successful, it closes the prayer request dialog and displays a
  /// success message. If the request fails, it shows an error message.
  Future<void> _addPrayerRequest() async {
    final provider = context.read<LightsPrayerRequestsProvider>();
    try {
      final apiResponse = await provider.addPrayerRequest(
        _prayerRequestController.text.trim(),
      );
      if (apiResponse.success) {
        if (mounted) context.pop();
        showGeneralFeedbackSnackBar(body: "Prayer request added.");
      } else {
        showGeneralFeedbackSnackBar(body: "Could not add prayer request.");
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  /// Handles the "Save" button press in the prayer request editing dialog.
  ///
  /// This function is called when the user presses the "Save" button in the
  /// prayer request editing dialog. It first validates the form input, ensuring
  /// that the input meets the specified criteria. If the validation fails, the
  /// function returns early, and no action is taken. If the validation passes,
  /// it determines whether the user is adding a new prayer request or editing an
  /// existing one based on the presence of [widget.prayerRequest].
  ///
  /// If the user is adding a new prayer request, it calls [_addPrayerRequest] to
  /// add the request. If the user is editing an existing request, it calls
  /// [_editPrayerRequest] to save the changes.
  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.prayerRequest == null) {
      await _addPrayerRequest();
    } else {
      await _editPrayerRequest();
    }
  }

  @override
  void dispose() {
    _prayerRequestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = BCWLocalizations.of(context);
    return AlertDialog(
      title: widget.prayerRequest != null
          ? const Text("Edit prayer request")
          : const Text("Add new prayer request"),
      content: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 125),
        child: Form(
          key: _formKey,
          child: TextFormField(
            autofocus: true,
            controller: _prayerRequestController,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(filled: false),
            minLines: 1,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
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
          child: const Text("CANCEL"),
        ),
        TextButton(
          onPressed: _onSavePressed,
          child: widget.prayerRequest != null ? const Text("SAVE CHANGES") : const Text("ADD"),
        ),
      ],
    );
  }
}
