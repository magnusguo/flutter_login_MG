import 'package:flutter/material.dart';
import 'package:flutter_login_MG/src/models/term_of_service.dart';
import 'package:quiver/core.dart';

/// A data model representing signup form input or provider-based registration.
///
/// This class is used to encapsulate all the data collected during the
/// signup process, including optional terms of service and custom fields.
@immutable
class SignupData {
  /// Creates a [SignupData] instance for traditional signup forms.
  ///
  /// Includes [name], [password], optional [additionalSignupData], and
  /// agreed-to [termsOfService]. Optional phone number components can be
  /// provided when using international phone number signup.
  const SignupData.fromSignupForm({
    required this.name,
    required this.password,
    this.additionalSignupData,
    this.termsOfService = const [],
    this.isoCode,
    this.dialCode,
    this.purePhoneNumber,
  });

  /// Creates a [SignupData] instance for third-party provider signups.
  ///
  /// Skips [name] and [password], which are expected to be handled by the provider.
  /// Includes [additionalSignupData] and [termsOfService]. Optional phone number
  /// components can be provided when using international phone number signup.
  const SignupData.fromProvider({
    required this.additionalSignupData,
    this.termsOfService = const [],
    this.isoCode,
    this.dialCode,
    this.purePhoneNumber,
  })  : name = null,
        password = null;

  /// The user's identifier (e.g. email, username).
  /// For international phone signup, this contains the full phone number (e.g., "+12022626879").
  ///
  /// `null` when using a third-party provider.
  final String? name;

  /// The user's password.
  ///
  /// `null` when using a third-party provider.
  final String? password;

  /// List of terms of service and their acceptance status.
  final List<TermOfServiceResult> termsOfService;

  /// Additional fields collected during signup (e.g. first name, phone).
  final Map<String, String>? additionalSignupData;

  /// The ISO country code (e.g., "US", "CA", "CN").
  /// Only populated when using international phone number signup.
  final String? isoCode;

  /// The country dial code with + prefix (e.g., "+1", "+86").
  /// Only populated when using international phone number signup.
  final String? dialCode;

  /// The pure phone number without the country dial code (e.g., "2022626879").
  /// Only populated when using international phone number signup.
  final String? purePhoneNumber;

  @override
  bool operator ==(Object other) {
    if (other is SignupData) {
      return name == other.name &&
          password == other.password &&
          additionalSignupData == other.additionalSignupData &&
          isoCode == other.isoCode &&
          dialCode == other.dialCode &&
          purePhoneNumber == other.purePhoneNumber;
    }
    return false;
  }

  @override
  int get hashCode => hashObjects([name, password, additionalSignupData, isoCode, dialCode, purePhoneNumber]);
}
