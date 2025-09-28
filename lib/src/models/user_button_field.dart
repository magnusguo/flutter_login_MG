import 'package:flutter/material.dart';
import 'package:flutter_login_MG/src/models/user_field_base.dart';

/// Represents a customizable button field used in forms.
///
/// This class allows you to define button-style fields with left icon,
/// title text, right content text, and right arrow. Each field is uniquely
/// identified by a [keyName] and includes customization for styling and behavior.
class UserButtonField extends UserFieldBase {
  /// Creates a [UserButtonField].
  ///
  /// The [keyName] must be unique across all button fields. If [title] is
  /// not provided, it defaults to [keyName].
  ///
  /// Optional customization includes [icon], [rightText], [rightTextStyle],
  /// [onTap], and [enabled].
  const UserButtonField({
    required String keyName,
    String? title,
    this.icon,
    this.rightText = '',
    this.rightTextStyle,
    this.rightTextColor,
    this.rightTextSize,
    this.onTap,
    this.onValueUpdate,
    bool enabled = true,
    InlineSpan? tooltip,
  }) : title = title ?? keyName,
       super(keyName: keyName, enabled: enabled, tooltip: tooltip);

  @override
  UserFieldType get fieldType => UserFieldType.button;

  /// The title text displayed on the left side after the icon.
  ///
  /// If not provided, it defaults to [keyName].
  final String title;

  /// An optional icon shown at the start of the button.
  ///
  /// If not provided, a default icon will be used.
  final Icon? icon;

  /// The text content displayed on the right side before the arrow.
  ///
  /// Defaults to an empty string.
  final String rightText;

  /// Custom text style for the right text content.
  ///
  /// If provided, this overrides [rightTextColor] and [rightTextSize].
  final TextStyle? rightTextStyle;

  /// Color for the right text content.
  ///
  /// This is ignored if [rightTextStyle] is provided.
  final Color? rightTextColor;

  /// Font size for the right text content.
  ///
  /// This is ignored if [rightTextStyle] is provided.
  final double? rightTextSize;

  /// Callback function called when the button is tapped.
  ///
  /// Receives the [keyName] as parameter for identification.
  /// Can return a Future<String?> to update the button's displayed value.
  /// If null is returned, the value remains unchanged.
  final Future<String?> Function(String keyName)? onTap;

  /// Callback function for updating the button field value.
  ///
  /// This is used internally by the form to allow the onTap callback
  /// to update the displayed value. Should not be set directly by users.
  final void Function(String keyName, String newValue)? onValueUpdate;


  /// Creates a copy of this button field with the given fields replaced.
  UserButtonField copyWith({
    String? keyName,
    String? title,
    Icon? icon,
    String? rightText,
    TextStyle? rightTextStyle,
    Color? rightTextColor,
    double? rightTextSize,
    Future<String?> Function(String keyName)? onTap,
    void Function(String keyName, String newValue)? onValueUpdate,
    bool? enabled,
    InlineSpan? tooltip,
  }) {
    return UserButtonField(
      keyName: keyName ?? this.keyName,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      rightText: rightText ?? this.rightText,
      rightTextStyle: rightTextStyle ?? this.rightTextStyle,
      rightTextColor: rightTextColor ?? this.rightTextColor,
      rightTextSize: rightTextSize ?? this.rightTextSize,
      onTap: onTap ?? this.onTap,
      onValueUpdate: onValueUpdate ?? this.onValueUpdate,
      enabled: enabled ?? this.enabled,
      tooltip: tooltip ?? this.tooltip,
    );
  }
}
