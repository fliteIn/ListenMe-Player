import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/icon_with_shadow.dart';
import '../../widgets/gradient_divider.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/numbered_description.dart';
import '../../l10n/app_localizations.dart';

class HelpManualPlaylistScreen extends StatefulWidget {
  const HelpManualPlaylistScreen({super.key});

  @override
  State<HelpManualPlaylistScreen> createState() => _HelpManualPlaylistScreenState();
}

class _HelpManualPlaylistScreenState extends State<HelpManualPlaylistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppModel>();
      app.lastVisitedHelpScreenRoute = '/help/playlist';
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final loc = AppLocalizations.of(context)!;
    final demoTracks = [
      ('audiobook_01.mp3', '02:13', 'mp3'),
      ('chapter_3_final_cut.aac', '03:24', 'aac'),
      ('interview_segment.ogg', '01:55', 'ogg'),
      ('mystery_audio.wav', '05:17', 'wav'),
      ('bonus_track.flac', '04:05', 'flac'),
      ('moove_your_body.mp3', '02:17', 'mp3'),
    ];
    const int selectedIndex = 1;

    List<String> labels = [
      loc.helpManualPlaylistOpen,
      loc.helpManualPlaylistClear,
      loc.helpManualPlaylistSearch,
      loc.helpManualPlaylistDrag,
      loc.helpManualPlaylistFilename,
      loc.helpManualPlaylistNumber,
      loc.helpManualPlaylistDelete,
    ];

    final playlistController = ScrollController();
    const double playlistBoxHeight = 329;

    // --- Адаптивный боковой паддинг (как в помощи виджетов)
    final double sidePadding = app.isTablet ? 64.0 : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePadding),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // --- Весь основной блок внутри паддинга ---
            Column(
              children: [
                // Заголовок
                Center(
                  child: buildShadowedText(
                    context,
                    loc.helpManualPlaylistTitle,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),

                // Кнопки открыть/удалить с кружками по бокам
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    buildThemedCircle('1', theme),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconWithShadow(
                        icon: Icons.folder_open,
                        size: 28,
                        color: theme.controlElements.color,
                        shadowColor: theme.controlElements.shadowColor,
                        shadowBlur: theme.controlElements.shadowBlur,
                        shadowEnabled: theme.controlElements.shadowEnabled,
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconWithShadow(
                        icon: Icons.delete_forever,
                        size: 28,
                        color: theme.playlistDeleteButton.color,
                        shadowColor: theme.playlistDeleteButton.shadowColor,
                        shadowBlur: theme.playlistDeleteButton.shadowBlur,
                        shadowEnabled: theme.playlistDeleteButton.shadowEnabled,
                      ),
                    ),
                    const SizedBox(width: 6),
                    buildThemedCircle('2', theme),
                  ],
                ),

                // Поиск с кружком 3
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // УБИРАЕМ Container с рамкой!
                      CustomSearchBar(
                        controller: TextEditingController(),
                        query: '',
                        onChanged: (_) {},
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: buildThemedCircle('3', theme),
                        ),
                      ),
                    ],
                  ),
                )
,

                // Сам плейлист
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  child: Container(
                    height: playlistBoxHeight,
                    decoration: BoxDecoration(
                      color: theme.backgroundStart,
                      border: Border.all(
                        color: Colors.black.withOpacity(0.2),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(0), // если нужен скругленный угол — измени тут
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        scrollbarTheme: ScrollbarThemeData(
                          thumbColor: MaterialStateProperty.all(theme.controlElements.color),
                          thickness: MaterialStateProperty.all(8),
                          radius: const Radius.circular(4),
                          thumbVisibility: MaterialStateProperty.all(true),
                        ),
                      ),
                      child: Scrollbar(
                        controller: playlistController,
                        thickness: 8,
                        radius: const Radius.circular(4),
                        thumbVisibility: true,
                        interactive: false,
                        child: ListView.separated(
                          controller: playlistController,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: demoTracks.length,
                          separatorBuilder: (context, index) => Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            color: theme.controlElements.color.withOpacity(0.4),
                          ),
                          itemBuilder: (context, index) {
                            final (name, duration, ext) = demoTracks[index];
                            final bool isSelected = index == selectedIndex;
                            return Container(
                              height: 65,
                              color: isSelected
                                  ? theme.controlElements.color
                                  : theme.backgroundStart,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Drag handle
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4, right: 10),
                                      child: Icon(
                                        Icons.drag_handle,
                                        size: 20,
                                        color: isSelected
                                            ? theme.buttonIconText.color
                                            : theme.widgetIconText.color.withOpacity(0.7),
                                      ),
                                    ),
                                    // Название трека
                                    Expanded(
                                      child: Text(
                                        name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected
                                              ? theme.buttonIconText.color
                                              : theme.widgetIconText.color,
                                          shadows: isSelected && theme.buttonIconText.shadowEnabled
                                              ? [
                                            Shadow(
                                              color: theme.buttonIconText.shadowColor,
                                              blurRadius: theme.buttonIconText.shadowBlur,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                              : null,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Номер, длительность, расширение
                                    SizedBox(
                                      width: 56,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? theme.buttonIconText.color
                                                  : theme.controlElements.color,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isSelected
                                                    ? theme.controlElements.color
                                                    : theme.buttonIconText.color,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(
                                              duration,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: isSelected
                                                    ? theme.buttonIconText.color
                                                    : theme.widgetIconText.color,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(
                                              ext,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic,
                                                color: isSelected
                                                    ? theme.buttonIconText.color.withOpacity(0.7)
                                                    : theme.widgetIconText.color.withOpacity(0.7),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Кнопка удаления
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: IconWithShadow(
                                        icon: Icons.delete,
                                        size: 24,
                                        color: theme.playlistDeleteButton.color,
                                        shadowColor: theme.playlistDeleteButton.shadowColor,
                                        shadowBlur: theme.playlistDeleteButton.shadowBlur,
                                        shadowEnabled: theme.playlistDeleteButton.shadowEnabled,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                )
,
                // Кружки 4-7 под всем плейлистом
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 4, right: 8, bottom: 0),
                  child: Row(
                    children: [
                      // 4 — под drag
                      Padding(
                        padding: const EdgeInsets.only(left: 13),
                        child: buildThemedCircle('4', theme),
                      ),
                      // 5 — под названием
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: buildThemedCircle('5', theme),
                        ),
                      ),
                      // 6 — под номером/временем/расширением
                      SizedBox(
                        width: 26,
                        child: Center(child: buildThemedCircle('6', theme)),
                      ),
                      // 7 — под ведром
                      SizedBox(
                        width: 46, // 12+24+8 (паддинг)
                        child: Align(
                          alignment: Alignment.center,
                          child: buildThemedCircle('7', theme),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const GradientDivider(),
            const SizedBox(height: 16),
            ...List.generate(labels.length, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: numberedDescription(context, '${i + 1}', labels[i], theme),
              );
            }),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: buildShadowedText(
                context,
                loc.helpManualPlaylistDescription,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 56),
          ],
        ),
      ),
    );
  }
}

// --- Кружок, как во всех help-блоках ---
Widget buildThemedCircle(String text, AppThemeColors theme) {
  return Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: theme.controlElements.color,
      shape: BoxShape.circle,
      boxShadow: theme.controlElements.shadowEnabled
          ? [
        BoxShadow(
          color: theme.controlElements.shadowColor.withOpacity(0.7),
          blurRadius: theme.controlElements.shadowBlur,
        )
      ]
          : [],
    ),
    alignment: Alignment.center,
    child: Text(
      text,
      style: TextStyle(
        color: theme.buttonIconText.color,
        fontWeight: FontWeight.w400,
        fontSize: 12,
      ),
    ),
  );
}
