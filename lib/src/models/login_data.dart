import 'package:flutter/material.dart';
import 'package:quiver/core.dart';

/// A simple data model representing login credentials.
///
/// Used to pass the username (or email/identifier) and password
/// into login callback functions.
@immutable
class LoginData {
  /// Creates a [LoginData] instance with the given [name] and [password].
  ///
  /// Both parameters are required. Optional phone number components can be
  /// provided when using international phone number login.
  const LoginData({
    required this.name,
    required this.password,
    this.isoCode,
    this.dialCode,
    this.purePhoneNumber,
  });

  /// The username, email, or login identifier entered by the user.
  /// For international phone login, this contains the full phone number (e.g., "+12022626879").
  final String name;

  /// The password entered by the user.
  final String password;

  /// The ISO country code (e.g., "US", "CA", "CN").
  /// Only populated when using international phone number login.
  final String? isoCode;

  /// The country dial code with + prefix (e.g., "+1", "+86").
  /// Only populated when using international phone number login.
  final String? dialCode;

  /// The pure phone number without the country dial code (e.g., "2022626879").
  /// Only populated when using international phone number login.
  final String? purePhoneNumber;

  @override
  String toString() {
    return 'LoginData($name, $password, isoCode: $isoCode, dialCode: $dialCode, purePhoneNumber: $purePhoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    if (other is LoginData) {
      return name == other.name &&
          password == other.password &&
          isoCode == other.isoCode &&
          dialCode == other.dialCode &&
          purePhoneNumber == other.purePhoneNumber;
    }
    return false;
  }

  @override
  int get hashCode => hashObjects([name, password, isoCode, dialCode, purePhoneNumber]);
}
