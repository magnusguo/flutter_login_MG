import 'package:flutter_login_MG/flutter_login.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startNextResendCooldown uses 30s then 60s', () {
    final auth = Auth(
      initialResendCooldownSeconds: 30,
      subsequentResendCooldownSeconds: 60,
    );

    expect(auth.canResendCode, isTrue);
    expect(auth.resendCountdownSeconds, 0);

    auth.startNextResendCooldown();
    expect(auth.canResendCode, isFalse);
    expect(auth.resendCountdownSeconds, inInclusiveRange(29, 30));

    auth.setResendCodeTime(
      DateTime.now().subtract(const Duration(seconds: 30)),
      cooldownSeconds: 30,
    );
    expect(auth.canResendCode, isTrue);
    expect(auth.resendCountdownSeconds, 0);

    auth.startNextResendCooldown();
    expect(auth.canResendCode, isFalse);
    expect(auth.resendCountdownSeconds, inInclusiveRange(59, 60));
  });

  test('countdown boundary is inclusive at the configured second', () {
    final auth = Auth(
      initialResendCooldownSeconds: 30,
      subsequentResendCooldownSeconds: 60,
    );

    auth.setResendCodeTime(
      DateTime.now().subtract(const Duration(seconds: 29)),
      cooldownSeconds: 30,
    );
    expect(auth.canResendCode, isFalse);
    expect(auth.resendCountdownSeconds, 1);

    auth.setResendCodeTime(
      DateTime.now().subtract(const Duration(seconds: 30)),
      cooldownSeconds: 30,
    );
    expect(auth.canResendCode, isTrue);
    expect(auth.resendCountdownSeconds, 0);
  });

  test('cooldown labels replace the seconds placeholder', () {
    final messages = LoginMessages();
    expect(
      messages.recoverPasswordCountdownLabel(9),
      'RECOVER (09s)',
    );
    expect(
      messages.resendCooldownMessage(9),
      'Please wait 9s before requesting a new code',
    );
  });
}