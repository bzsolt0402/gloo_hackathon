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
/// This file includes code for a custom widget that wraps a text to provide
/// expanding and collapsing functionality. It is created to be used with the
/// prayer prompt widget.
///

import 'package:flutter/material.dart';

/// A widget that displays text content with an option to expand or
/// collapse it when the text exceeds a specified number of lines.
class ExpandableText extends StatefulWidget {
  /// Creates an [ExpandableText] widget.
  ///
  /// The [text] parameter is the text to be displayed.
  ///
  /// The [textStyle] parameter allows you to customize the style of the text.
  ///
  /// The [maxLines] parameter sets the maximum number of lines to display
  /// before the text becomes expandable. If the text exceeds this limit, it
  /// will be truncated with an ellipsis (three dots (...)).
  const ExpandableText({
    Key? key,
    required this.text,
    this.textStyle,
    this.maxLines = 10,
  }) : super(key: key);

  /// The text content to be displayed.
  final String text;

  /// The maximum number of lines to display before becoming expandable.
  final int maxLines;

  /// The style to apply to the text. If not provided, the default text style
  /// will be used.
  final TextStyle? textStyle;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  /// Contains data about the text in the current context.
  late TextPainter _textPainter;

  /// The state of the widget if it's expanded or not.
  bool _isExpanded = false;

  /// Returns the text content from the widget.
  String get text => widget.text;

  TextStyle? get textStyle => widget.textStyle;

  /// Toggles the expanded state of the text.
  void toggleExpanded() => setState(() => _isExpanded = !_isExpanded);

  @override
  void initState() {
    _updateTextPainter();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ExpandableText oldWidget) {
    if (widget.text != oldWidget.text) {
      setState(() {
        _updateTextPainter();
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  /// Initializes the [_textPainter] to measure the text size.
  void _updateTextPainter() {
    if (text.isEmpty) return;
    final span = TextSpan(text: text, style: textStyle);
    _textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      _textPainter.layout(maxWidth: constraints.maxWidth);
      final textLines = _textPainter.computeLineMetrics().length;
      if (textLines > widget.maxLines) {
        return GestureDetector(
          onTap: toggleExpanded,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    AnimatedCrossFade(
                      firstChild: Text(
                        text,
                        maxLines: widget.maxLines,
                        overflow: TextOverflow.ellipsis,
                        style: textStyle,
                      ),
                      secondChild: Text(
                        text,
                        style: textStyle,
                      ),
                      crossFadeState:
                          _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),
                    if (!_isExpanded)
                      Positioned(
                        bottom: 0,
                        width: constraints.maxWidth,
                        child: Container(
                          height: 24.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                theme.cardTheme.color!,
                                theme.cardTheme.color!.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(height: 4.0),
                AnimatedRotation(
                  turns: !_isExpanded ? 0 : 0.5,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(Icons.expand_more),
                ),
              ],
            ),
          ),
        );
      }
      return Text(
        text,
        style: textStyle,
      );
    });
  }
}
