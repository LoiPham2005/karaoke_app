// ════════════════════════════════════════════════════════════════
// 📁 lib/extensions/list_extensions.dart (SIMPLIFIED)
// ════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';

extension ListExtensions<T> on List<T> {
  // ═══════════════════════════════════════════════════════════════
  // GIỮ LẠI - nb_utils KHÔNG CÓ
  // ═══════════════════════════════════════════════════════════════

  /// Distinct by property
  List<T> distinctBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    return where((item) => seen.add(keySelector(item))).toList();
  }

  /// Group by property
  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keySelector(item);
      (map[key] ??= []).add(item);
    }
    return map;
  }

  /// Sum by selector
  num sum(num Function(T) selector) {
    return fold<num>(0, (prev, item) => prev + selector(item));
  }

  /// Average by selector
  double average(num Function(T) selector) {
    if (isEmpty) return 0;
    return sum(selector) / length;
  }

  /// Max by selector
  T? maxBy<R extends Comparable>(R Function(T) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) > 0 ? a : b);
  }

  /// Min by selector
  T? minBy<R extends Comparable>(R Function(T) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) < 0 ? a : b);
  }

  /// Chunk list into smaller lists
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

extension WidgetListExtensions on List<Widget> {
  // ═══════════════════════════════════════════════════════════════
  // WIDGET-SPECIFIC EXTENSIONS
  // ═══════════════════════════════════════════════════════════════

  /// Add vertical spacing between widgets
  /// Usage: [Widget1(), Widget2()].withSpacing(12)
  List<Widget> withSpacing(double spacing) {
    if (isEmpty) return this;
    return [
      for (int i = 0; i < length; i++) ...[
        this[i],
        if (i < length - 1) SizedBox(height: spacing),
      ],
    ];
  }

  /// Add horizontal spacing between widgets
  /// Usage: [Widget1(), Widget2()].withHorizontalSpacing(12)
  List<Widget> withHorizontalSpacing(double spacing) {
    if (isEmpty) return this;
    return [
      for (int i = 0; i < length; i++) ...[
        this[i],
        if (i < length - 1) SizedBox(width: spacing),
      ],
    ];
  }

  /// Add dividers between widgets
  /// Usage: [Widget1(), Widget2()].withDividers()
  List<Widget> withDividers({
    double height = 1,
    Color? color,
    double indent = 0,
    double endIndent = 0,
  }) {
    if (isEmpty) return this;
    return [
      for (int i = 0; i < length; i++) ...[
        this[i],
        if (i < length - 1)
          Divider(
            height: height,
            color: color,
            indent: indent,
            endIndent: endIndent,
          ),
      ],
    ];
  }

  /// Wrap in Column
  Column toColumn({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: this,
    );
  }

  /// Wrap in Row
  Row toRow({
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: this,
    );
  }

  /// Wrap in Wrap widget
  Wrap toWrap({
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.start,
    double spacing = 0.0,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
  }) {
    return Wrap(
      direction: direction,
      alignment: alignment,
      spacing: spacing,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      crossAxisAlignment: crossAxisAlignment,
      children: this,
    );
  }
}
