import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_model.dart';
import '../models/app_theme_colors.dart';
import '../l10n/app_localizations.dart';

class TrackTitle extends StatelessWidget {
  final double? fontSize;
  final double? height;

  const TrackTitle({
    Key? key,
    this.fontSize,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final themed = app.themeColors.currentValueText;
    final loc = AppLocalizations.of(context)!;

    final currentIndex = app.currentIndex;
    String trackNumber = '';
    String displayedTitle = loc.noTrack;

    if (currentIndex != null &&
        currentIndex >= 0 &&
        currentIndex < app.currentPlaylist.length) {
      trackNumber = '${currentIndex + 1}. ';
      displayedTitle =
          app.extractTitleFromPath(app.currentPlaylist[currentIndex]);
    }

    return SizedBox(
      height: height ?? 50,
      child: Center(
        child: Text(
          '$trackNumber$displayedTitle',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: FontWeight.w600,
            color: themed.color,
            shadows: themed.shadowEnabled
                ? [
              Shadow(
                color: themed.shadowColor,
                blurRadius: themed.shadowBlur,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
        ),
      ),
    );
  }
}
