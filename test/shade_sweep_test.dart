import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shade_sweep/shade_sweep.dart';

void main() {
  test('initialsOf', () {
    expect(ShadeInitialsAvatar.initialsOf('Asha Rao'), 'AR');
    expect(ShadeInitialsAvatar.initialsOf('asha'), 'A');
    expect(ShadeInitialsAvatar.initialsOf('  '), '');
  });

  testWidgets('renders child and animates without errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Column(children: [
        ShadeInitialsAvatar(name: 'Asha Rao'),
        ShadeInitialsAvatar(name: 'Ravi K', shape: ShadeAvatarShape.circle),
      ]),
    ));
    expect(find.text('AR'), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
    // Unmount so the periodic timer is cancelled.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reduced motion shows the child still', (tester) async {
    await tester.pumpWidget(const MediaQuery(
      data: MediaQueryData(disableAnimations: true),
      child: MaterialApp(home: ShadeSweep(child: Text('x'))),
    ));
    expect(find.text('x'), findsOneWidget);
  });

  testWidgets('a lone sweep replays every turn', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Center(child: ShadeSweep(child: SizedBox(width: 50, height: 50))),
    ));
    final turns = <Object?>[];
    final sub = ShadeSequenceCubit.instance.stream.listen(turns.add);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3100));
    sub.cancel();
    expect(turns.whereType<Object>().length, greaterThanOrEqualTo(3));
    await tester.pumpWidget(const SizedBox());
  });
}
