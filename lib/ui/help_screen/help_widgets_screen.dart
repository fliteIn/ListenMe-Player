import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/themed_text.dart';
import 'top_menu_bar_help_block.dart';
import 'general_controls_help_block.dart';
import 'progress_slider_help_block.dart';
import 'playback_standard_help_block.dart';
import 'playback_extended_help_block.dart';
import 'playback_precise_help_block.dart';
import 'jog_help_block.dart';
import 'speed_slider_help_block.dart';
import 'silence_control_help_block.dart';

class HelpWidgetsScreen extends StatefulWidget {
  const HelpWidgetsScreen({super.key});

  @override
  State<HelpWidgetsScreen> createState() => _HelpWidgetsScreenState();
}

class _HelpWidgetsScreenState extends State<HelpWidgetsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offset = context.read<AppModel>().helpWidgetsScrollOffset ?? 0.0;
      if (offset > 0.0 && _scrollController.hasClients) {
        _scrollController.jumpTo(offset);
      }
      context.read<AppModel>().lastVisitedHelpScreenRoute = '/help/widgets';
    });

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        context.read<AppModel>().helpWidgetsScrollOffset = _scrollController.offset;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    app.updateSystemUi(theme);

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final double sidePadding = app.isTablet ? 64.0 : 0.0;

    // Адаптивная максимальная высота — немного меньше экрана (например, 92% от полной высоты)
    final double maxContentHeight = MediaQuery.of(context).size.height * 0.92 - bottomPadding;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Только maxHeight!
                  maxHeight: maxContentHeight,
                ),
                child: Stack(
                  children: [
                    ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor: MaterialStateProperty.all(theme.controlElements.color),
                        thickness: MaterialStateProperty.all(8),
                        radius: const Radius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 0),
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          interactive: true,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                sidePadding,
                                16,
                                sidePadding,
                                80 + bottomPadding,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: buildShadowedText(
                                      context,
                                      loc.widgets,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const TopMenuBarHelpBlock(),
                                  const GeneralControlsHelpBlock(),
                                  const ProgressSliderHelpBlock(),
                                  const PlaybackStandardHelpBlock(),
                                  const PlaybackExtendedHelpBlock(),
                                  const PlaybackPreciseHelpBlock(),
                                  const JogHelpBlock(),
                                  const SpeedSliderHelpBlock(),
                                  const SilenceControlHelpBlock(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Кнопки вверх/вниз
                    Positioned(
                      bottom: 16 + bottomPadding,
                      right: 18,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.controlElements.color,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: theme.controlElements.shadowEnabled
                                    ? [
                                  BoxShadow(
                                    color: theme.controlElements.shadowColor,
                                    blurRadius: theme.controlElements.shadowBlur,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                    : [],
                              ),
                              child: Icon(Icons.arrow_upward, color: theme.buttonIconText.color, size: 20),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              for (int i = 0; i < 4; i++) {
                                if (!_scrollController.hasClients) break;
                                await _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                                await Future.delayed(const Duration(milliseconds: 70));
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.controlElements.color,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: theme.controlElements.shadowEnabled
                                    ? [
                                  BoxShadow(
                                    color: theme.controlElements.shadowColor,
                                    blurRadius: theme.controlElements.shadowBlur,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                    : [],
                              ),
                              child: Icon(Icons.arrow_downward, color: theme.buttonIconText.color, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
