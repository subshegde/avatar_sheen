import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Takes turns between the [ShadeSweep]s on screen: one at a time, top to
/// bottom, then back to the first. Only sweeps actually visible take part, so
/// as a list scrolls the turns follow what the person can see.
///
/// The state is the token of the sweep whose turn it is (null between turns).
class ShadeSequenceCubit extends Cubit<Object?> {
  ShadeSequenceCubit._() : super(null);

  /// The app-wide sequence all sweeps join by default.
  static final ShadeSequenceCubit instance = ShadeSequenceCubit._();

  /// How long each turn lasts: exactly one pass of the band, so the next sweep
  /// starts as the last one leaves.
  static const Duration turn = Duration(milliseconds: 1000);

  final Map<Object, BuildContext> _entries = {};
  Timer? _timer;
  Object? _last;

  /// Joins the rotation; [context] is where the sweep sits on screen.
  void register(Object token, BuildContext context) {
    _entries[token] = context;
    _timer ??= Timer.periodic(turn, (_) => _next());
    // The first one in does not wait a whole turn to begin.
    if (_entries.length == 1) _next();
  }

  /// Leaves the rotation.
  void unregister(Object token) {
    _entries.remove(token);
    if (_last == token) _last = null;
    if (_entries.isEmpty) {
      _timer?.cancel();
      _timer = null;
      emit(null);
    }
  }

  /// Visible sweeps in reading order: top to bottom, then left to right.
  List<Object> _visibleInOrder() {
    final placed = <(Object, Offset)>[];
    _entries.forEach((token, context) {
      if (!context.mounted) return;
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) return;
      final origin = box.localToGlobal(Offset.zero);
      final screen = MediaQuery.maybeSizeOf(context);
      if (screen != null &&
          (origin.dy + box.size.height <= 0 ||
              origin.dy >= screen.height ||
              origin.dx + box.size.width <= 0 ||
              origin.dx >= screen.width)) {
        return;
      }
      placed.add((token, origin));
    });
    placed.sort((a, b) {
      final byTop = a.$2.dy.compareTo(b.$2.dy);
      return byTop != 0 ? byTop : a.$2.dx.compareTo(b.$2.dx);
    });
    return [for (final (token, _) in placed) token];
  }

  void _next() {
    final visible = _visibleInOrder();
    if (visible.isEmpty) {
      _last = null;
      emit(null);
      return;
    }
    final at = _last == null ? -1 : visible.indexOf(_last!);
    final chosen = visible[(at + 1) % visible.length];
    _last = chosen;
    // Bloc ignores an emit equal to the current state, so a lone sweep chosen
    // twice in a row is reset first to replay every turn.
    if (identical(state, chosen)) emit(null);
    emit(chosen);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
