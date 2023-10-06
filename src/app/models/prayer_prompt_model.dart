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
/// This file includes all the code required to represent a Prayer Prompt.
/// Some of its code existed before the Hackathon, but it has become much simpler.
///

/// A model class representing a prayer prompt.
class PrayerPromptModel {
  /// Constructs a [PrayerPromptModel] instance with the given text.
  ///
  /// - [text]: The text of the prayer prompt.
  const PrayerPromptModel(
    this.text,
  );

  /// The text of the prayer prompt.
  final String text;

  /// Factory method to create a [PrayerPromptModel] from a JSON map.
  ///
  /// - [json]: A map containing the JSON data for a prayer prompt.
  ///
  /// Returns a [PrayerPromptModel] instance created from the JSON data.
  factory PrayerPromptModel.fromJson(Map<String, dynamic> json) =>
      PrayerPromptModel(
        json["prayerPrompt"],
      );

  /// Converts this [PrayerPromptModel] to a JSON map.
  ///
  /// Returns a JSON map representing the prayer prompt.
  Map<String, dynamic> toJson() => {
        "prayerPrompt": text,
      };
}
