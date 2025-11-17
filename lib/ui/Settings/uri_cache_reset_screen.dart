import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/app_model.dart';
import '../../widgets/themed_buttons.dart';
import '../../widgets/themed_text.dart';
import '../../l10n/app_localizations.dart';

import '../../utils/shadow_utils.dart';

import 'dart:async';

class UriCacheResetScreen extends StatefulWidget {
  const UriCacheResetScreen({super.key});

  @override
  State<UriCacheResetScreen> createState() => _UriCacheResetScreenState();
}

class _UriCacheResetScreenState extends State<UriCacheResetScreen> {
  bool _isResetting = false;

  Future<void> _onResetPressed(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.uriCacheResetConfirmTitle),
        content: Text(loc.uriCacheResetConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.uriCacheResetButton),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _resetUriCache(context);
    }
  }

  Future<void> _resetUriCache(BuildContext context) async {
    setState(() => _isResetting = true);
    // Очищаем Hive box с кэшем папок
    try {
      var box = await Hive.openBox('folderCache');
      await box.clear();
      await box.close();
    } catch (_) {}

    // SharedPreferences: удаляем только папочные ключи
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_folder_playlist_root');
    await prefs.remove('last_folder_playlist_current');
    await prefs.remove('last_folder_playlist_stack');
    // Добавь сюда другие ключи, если что-то ещё используешь для навигации по папкам

    setState(() => _isResetting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.uriCacheResetSuccess)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final theme = app.themeColors;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildShadowedText(
                context,
                loc.uriCacheResetTitle,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              buildShadowedText(
                context,
                loc.uriCacheResetDesc,
                fontSize: 15,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.normal,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 300,
                child: ThemedButton(
                  child: buildShadowedTextSimple(
                    loc.uriCacheResetButton,
                    theme.buttonIconText,
                    fontSize: 16,
                  ),
                  background: theme.controlElements,
                  foreground: theme.buttonIconText,
                  onTap: _isResetting
                      ? () {}  // ничего не делает, не null!
                      : () { _onResetPressed(context); },

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
