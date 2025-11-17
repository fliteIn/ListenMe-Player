import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/top_menu_bar.dart';
import '../../widgets/themed_text.dart';
import '../../utils/shadow_utils.dart';
import '../../l10n/app_localizations.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    // Запоминаем этот экран как последнее help-подменю
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final app = context.read<AppModel>();
      app.lastVisitedHelpScreenRoute = '/help/about';
    });

    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      // показываем версию в привычном формате
      _appVersion = info.version;
    });
  }


  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    app.updateSystemUi(theme);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: buildShadowedText(
                context,
                _appVersion.isEmpty
                    ? 'ListenMe Player' // пока грузится
                    : 'ListenMe Player. Version $_appVersion',
                fontSize: 16,
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: buildShadowedText(
                context,
                '© 2025 fliteIn. All rights reserved.',
                fontSize: 12,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
