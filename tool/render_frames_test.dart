// Renders demo frames to PNGs for the README GIF.
// Run: flutter test tool/render_frames_test.dart --dart-define=OUT=/path/to/frames
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shade_sweep/shade_sweep.dart';

void main() {
  testWidgets('frames', (tester) async {
    const out = String.fromEnvironment('OUT');
    final font = FontLoader('Demo')
      ..addFont(Future.value(ByteData.view(
          File('/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf')
              .readAsBytesSync()
              .buffer)));
    await font.load();
    tester.view.physicalSize = const Size(900, 300);
    tester.view.devicePixelRatio = 1;
    final key = GlobalKey();
    const names = ['Asha Rao', 'Ravi Kumar', 'Meera Nair', 'John Doe'];
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Demo'),
      home: RepaintBoundary(
        key: key,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < names.length; i++) ...[
                if (i > 0) const SizedBox(width: 28),
                ShadeInitialsAvatar(
                  name: names[i],
                  size: 120,
                  shape: i.isOdd
                      ? ShadeAvatarShape.circle
                      : ShadeAvatarShape.roundedSquare,
                ),
              ],
            ]),
          ),
        ),
      ),
    ));
    await tester.pump();
    // 4 avatars x 1s turns = 4s loop, 20 fps.
    for (var f = 0; f < 80; f++) {
      await tester.pump(const Duration(milliseconds: 50));
      final bytes = await tester.runAsync(() async {
        final b = key.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
        final img = await b.toImage(pixelRatio: 1);
        return (await img.toByteData(format: ui.ImageByteFormat.png))!;
      });
      File('$out/f${f.toString().padLeft(3, '0')}.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    }
    await tester.pumpWidget(const SizedBox());
  });
}
