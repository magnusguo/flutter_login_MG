import 'package:flutter/material.dart';

/// Base class for all user field types in the login form.
/// 
/// This abstract class provides common properties that all field types share,
/// allowing for polymorphic handling of different field types.
abstract class UserFieldBase {
  /// Creates a [UserFieldBase].
  const UserFieldBase({
    required this.keyName,
    this.enabled = true,
    this.tooltip,
  });

  /// A unique key used to identify this field.
  /// Must be unique across all fields.
  final String keyName;

  /// Whether the field is enabled for user interaction.
  final bool enabled;

  /// An optional tooltip that may be shown alongside the field.
  final InlineSpan? tooltip;

  /// Returns the type of field (form or button).
  UserFieldType get fieldType;
}

/// Enum to distinguish between different field types.
enum UserFieldType {
  /// Standard form input field
  form,
  /// Button-style field
  button,
}
