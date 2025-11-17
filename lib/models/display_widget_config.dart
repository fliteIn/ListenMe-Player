class DisplayWidgetConfig {
  final String id;
  final String label;

  /// Если это группа, здесь список ID подчинённых виджетов.
  final List<String>? widgetIds;

  DisplayWidgetConfig({
    required this.id,
    required this.label,
    this.widgetIds,
  });
}

