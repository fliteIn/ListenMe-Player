import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_model.dart';
import '../../models/app_theme_colors.dart';
import '../../widgets/top_menu_bar.dart';
import '../../widgets/themed_text.dart';
import '../../utils/shadow_utils.dart';

class LicenseDetailScreen extends StatelessWidget {
  final String package;
  final List<dynamic> paragraphs;

  const LicenseDetailScreen({
    super.key,
    required this.package,
    required this.paragraphs,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<AppModel>().themeColors;

    final theme = context.watch<AppModel>().themeColors;
    final app = context.watch<AppModel>();
    app.updateSystemUi(theme);

    // ==== ЛОГИ для диагностики ====
    final modalRouteName = ModalRoute.of(context)?.settings.name;
    debugPrint('[LicenseDetailScreen] build: ModalRoute name: $modalRouteName');
    debugPrint('[LicenseDetailScreen] package: $package, paragraphs: ${paragraphs.length}');

    // Если нужно отловить, когда уже построился первый кадр:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[LicenseDetailScreen] (post frame) ModalRoute name: ${ModalRoute.of(context)?.settings.name}');
    });

    return Scaffold(
      backgroundColor: Colors.transparent, // 👈 важно
      body: Column(
        children: [
          //TopMenuBar(), // Глобальный, не нужен здесь!
          Padding(
            padding: const EdgeInsets.all(16),
            child: buildShadowedText(context, package, fontSize: 20),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: paragraphs.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    p.text,
                    style: TextStyle(
                      color: colors.widgetIconText.color.withOpacity(0.95),
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
