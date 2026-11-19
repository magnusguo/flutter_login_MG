import 'package:flutter/material.dart';
import 'package:flutter_login_MG/src/widgets/animated_text_form_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  testWidgets('FaIcon prefix sits in the center of the prefix slot', (
    tester,
  ) async {
    const iconKey = Key('prefix-lock');

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AnimatedTextFormField(
            width: 320,
            initialIsoCode: 'CN',
            labelText: '密码',
            prefixIcon: FaIcon(
              FontAwesomeIcons.lock,
              key: iconKey,
              size: 20,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final icon = find.byKey(iconKey);
    final slot = find.ancestor(
      of: icon,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is ConstrainedBox &&
            widget.constraints.minWidth >= 48 &&
            widget.constraints.minHeight >= 48,
      ),
    );

    expect(slot, findsOneWidget);

    final iconCenter = tester.getRect(icon).center;
    final slotCenter = tester.getRect(slot).center;
    expect(iconCenter.dx, closeTo(slotCenter.dx, 0.5));
    expect(iconCenter.dy, closeTo(slotCenter.dy, 0.5));
  });
}
