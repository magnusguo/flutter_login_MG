part of 'auth_card_builder.dart';

/// Keeps a one-second UI ticker in sync with [Auth]'s shared send cooldown.
///
/// The listener covers both cases: this card starts the cooldown, or another
/// card starts it while this [State] is still alive inside the page view.
mixin _ResendCountdownMixin<T extends StatefulWidget> on State<T> {
  Timer? _resendTimer;
  Auth? _countdownAuth;

  void attachCountdownListener() {
    _countdownAuth = Provider.of<Auth>(context, listen: false);
    _countdownAuth!.addListener(_ensureTicker);
    _ensureTicker();
  }

  void detachCountdownListener() {
    _countdownAuth?.removeListener(_ensureTicker);
    _resendTimer?.cancel();
    _resendTimer = null;
    _countdownAuth = null;
  }

  /// Starts the ticker if a cooldown is active and none is running.
  void startCountdownTicker() {
    _ensureTicker();
  }

  void _ensureTicker() {
    final auth = _countdownAuth;
    if (auth == null || !mounted) {
      return;
    }
    if (auth.canResendCode) {
      if (_resendTimer != null) {
        _resendTimer!.cancel();
        _resendTimer = null;
        setState(() {});
      }
      return;
    }
    if (_resendTimer != null) {
      return;
    }
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        _resendTimer = null;
        return;
      }
      setState(() {});
      if (auth.canResendCode) {
        timer.cancel();
        _resendTimer = null;
      }
    });
  }
}
