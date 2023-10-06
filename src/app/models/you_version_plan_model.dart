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
/// This file includes all the code required to represent a YouVersion Bible reading plan.
///

/// Represents a model for a YouVersion Bible reading plan.
class YouVersionPlanModel {
  /// Constructs a [YouVersionPlanModel] instance.
  ///
  /// - [imgUrl]: The URL to the plan's image.
  /// - [url]: The URL to the plan.
  /// - [title]: The title of the plan.
  /// - [intro]: The introduction or description of the plan.
  const YouVersionPlanModel({
    required this.imgUrl,
    required this.url,
    required this.title,
    required this.intro,
  });

  /// The URL to the plan's image.
  final String imgUrl;

  /// The URL to the plan.
  final String url;

  /// The title of the plan.
  final String title;

  /// The introduction or description of the plan.
  final String intro;

  /// Factory method to create a [YouVersionPlanModel] from a JSON map.
  ///
  /// - [json]: A map containing the JSON data for a YouVersion Bible reading plan.
  ///
  /// Returns a [YouVersionPlanModel] instance created from the JSON data.
  factory YouVersionPlanModel.fromJson(Map<String, dynamic> json) {
    return YouVersionPlanModel(
      imgUrl: json["image"],
      url: json["url"],
      title: json["title"],
      intro: json["intro"],
    );
  }

  /// Converts this [YouVersionPlanModel] to a JSON map.
  ///
  /// Returns a JSON map representing the YouVersion Bible reading plan.
  Map<String, dynamic> toJson() => {
        "img": imgUrl,
        "url": url,
        "title": title,
        "intro": intro,
      };
}
