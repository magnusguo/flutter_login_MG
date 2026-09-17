import '../providers/auth.dart';

/// Preset resend-button cooldown lengths in seconds.
class ResendCooldown {
  ResendCooldown._();

  static const int s5 = 5;
  static const int s10 = 10;
  static const int s15 = 15;
  static const int s20 = 20;
  static const int s30 = 30;
  static const int s60 = 60;
}

/// Lets the host app clear the confirm-page resend cooldown
/// (for example when the first background SMS send fails).
class ResendCooldownController {
  Auth? _auth;

  void attach(Auth auth) {
    _auth = auth;
  }

  void detach() {
    _auth = null;
  }

  /// Makes the resend button clickable immediately.
  void clear() {
    _auth?.clearResendCooldown();
  }
}
