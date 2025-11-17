import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';

class ThemedListContainer extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final ScrollController? scrollController;

  const ThemedListContainer({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppModel>().themeColors;

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundStart,
        border: Border.all(
          color: Colors.black.withOpacity(0.2),
        ),
        boxShadow: [],
      ),
      child: separatorBuilder != null
          ? ListView.separated(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
        itemCount: itemCount,
        separatorBuilder: separatorBuilder!,
        itemBuilder: itemBuilder,
        controller: scrollController,
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        controller: scrollController,
      ),
    );
  }
}
