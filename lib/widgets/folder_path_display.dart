import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';

class FolderPathDisplay extends StatelessWidget {
  final String path;

  const FolderPathDisplay({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final themedText = context.watch<AppModel>().themeColors.currentValueText;

    return SizedBox(
      height: 42,
      child: Center(
        child: Text(
          path,
          style: TextStyle(
            color: themedText.color,
            fontSize: 14,
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
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        ),
      ),
    );
  }
}
