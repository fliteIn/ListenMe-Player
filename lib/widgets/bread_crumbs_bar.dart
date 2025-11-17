import 'package:flutter/material.dart';

/// Описывает один сегмент SAF-пути
class SafPathEntry {
  final String uri;
  final String name;
  SafPathEntry(this.uri, this.name);
}

/// Получить имя папки из SAF-URI (можно доработать для edge-case)
String getSafFolderName(String uri) {
  final decoded = Uri.decodeComponent(uri);
  final cut = decoded
      .replaceAll(RegExp(r'.*primary:'), '')
      .replaceAll(RegExp(r'.*[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}:'), '')
      .replaceAll(RegExp(r'.*document/'), '');
  final segments = cut.split('/').where((s) => s.isNotEmpty);
  return segments.isNotEmpty ? segments.last : 'storage';
}

/// Универсальный виджет хлебных крошек для SAF-путей
class BreadCrumbsBar extends StatelessWidget {
  /// Список сегментов (от root до текущей папки)
  final List<SafPathEntry> safPathStack;
  /// URI текущей папки (текущий путь)
  final String? currentPath;
  /// Имя текущей папки (или null, если брать по uri)
  final String? currentFolderName;
  /// Цвет текста
  final Color textColor;
  /// Тень
  final bool shadowEnabled;
  final Color shadowColor;
  final double shadowBlur;

  /// Callback при тапе по сегменту (index, uri)
  final void Function(int index, String path) onSegmentTap;

  const BreadCrumbsBar({
    super.key,
    required this.safPathStack,
    required this.currentPath,
    required this.currentFolderName,
    required this.textColor,
    required this.shadowEnabled,
    required this.shadowColor,
    required this.shadowBlur,
    required this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    // Собираем все сегменты, включая текущий (если его нет в стеке)
    final allCrumbs = [
      ...safPathStack,
      if (currentPath != null &&
          currentPath!.isNotEmpty &&
          (safPathStack.isEmpty || safPathStack.last.uri != currentPath))
        SafPathEntry(
          currentPath!,
          currentFolderName ?? getSafFolderName(currentPath!),
        ),
    ];

    // .. — всегда первый сегмент
    final names = ['..', ...allCrumbs.map((e) => e.name)];
    final uris = ['..', ...allCrumbs.map((e) => e.uri)];

    final List<InlineSpan> children = [];
    for (int i = 0; i < names.length; i++) {
      final isCurrent = i == names.length - 1;
      if (i > 0) {
        children.add(
          TextSpan(
            text: ' / ',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 16,
              shadows: shadowEnabled
                  ? [
                Shadow(
                  color: shadowColor,
                  blurRadius: shadowBlur,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
          ),
        );
      }

      children.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: isCurrent
                ? null
                : () {
              onSegmentTap(i, uris[i]);
            },
            child: Text(
              names[i],
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                shadows: shadowEnabled
                    ? [
                  Shadow(
                    color: shadowColor,
                    blurRadius: shadowBlur,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: RichText(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            text: TextSpan(children: children),
          ),
        ),
      ),
    );
  }
}
