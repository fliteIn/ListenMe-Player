import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../../l10n/app_localizations.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final String? hintText;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppModel>().themeColors;
    final themedText = theme.currentValueText;
    final themedScrollThumb = theme.controlElements;
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundStart,
        border: Border.all(
          color: Colors.black.withOpacity(0.2),
        ),
        boxShadow: [],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(Icons.search, color: themedScrollThumb.color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (v) => onChanged(v.trim()),
              style: TextStyle(
                color: themedText.color,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.07,
                shadows: themedText.shadowEnabled
                    ? [
                  Shadow(
                    color: themedText.shadowColor,
                    blurRadius: themedText.shadowBlur,
                    offset: const Offset(0, 2),
                  ),
                ]
                    : null,
              ),
              cursorColor: themedScrollThumb.color,
              decoration: InputDecoration(
                hintText: hintText ?? loc.searchBarHintText,
                hintStyle: TextStyle(
                  color: themedText.color.withOpacity(0.42),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.07,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
              ),
            ),
          ),
          if (query.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8, left: 2),
                child: Icon(
                  Icons.clear,
                  size: 16,
                  color: themedScrollThumb.color.withOpacity(0.63),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
