import 'package:flutter/material.dart';
import 'package:flutter_login_MG/src/widgets/animated_text_form_field.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  testWidgets('FaIcon prefix stays in the left slot and is vertically centered', (
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
    final field = find.byType(TextFormField);
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

    final iconRect = tester.getRect(icon);
    final slotRect = tester.getRect(slot);
    final fieldRect = tester.getRect(field);

    expect(slotRect.width, lessThanOrEqualTo(56));
    expect(iconRect.left - fieldRect.left, lessThanOrEqualTo(56));
    expect(iconRect.center.dx, closeTo(slotRect.center.dx, 0.5));
    expect(iconRect.center.dy, closeTo(slotRect.center.dy, 0.5));
    expect(iconRect.center.dy, closeTo(fieldRect.center.dy, 1));
  });
}
