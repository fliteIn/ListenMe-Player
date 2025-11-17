import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/playlist_model.dart';
import '../models/app_model.dart';
import '../widgets/icon_with_shadow.dart';

class OpenFilesButton extends StatelessWidget {
  final PlaylistModel audioState;
  final void Function(int index) onTrackSelected;
  final bool autoPlay;

  const OpenFilesButton({
    super.key,
    required this.audioState,
    required this.onTrackSelected,
    this.autoPlay = false,
  });

  Future<void> _pickFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
    );

    if (result == null || result.files.isEmpty) return;

    final validPaths = result.files
        .map((file) => file.path)
        .whereType<String>()
        .where((path) => File(path).existsSync())
        .toList();

    if (validPaths.isEmpty) {
      debugPrint("❌ Все файлы некорректны или отсутствуют.");
      return;
    }

    final app = context.read<AppModel>();
    final currentLength = app.manualPlaylist.length;
    final wasEmpty = currentLength == 0;
    final startIndex = currentLength;

    await audioState.addFiles(validPaths);

    if (autoPlay && validPaths.isNotEmpty) {
      final indexToPlay = wasEmpty ? 0 : startIndex;

      if (indexToPlay >= 0 && indexToPlay < app.manualPlaylist.length) {
        onTrackSelected(indexToPlay);
      } else {
        debugPrint('❌ Невозможно воспроизвести: индекс $indexToPlay вне допустимого диапазона');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppModel>();
    final themed = app.themeColors.controlElements;

    const double buttonSize = 36;
    const double iconSize = 30;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: IconButton(
        icon: IconWithShadow(
          icon: Icons.folder_open,
          size: iconSize,
          color: themed.color,
          shadowColor: themed.shadowColor,
          shadowBlur: themed.shadowBlur,
          shadowEnabled: themed.shadowEnabled,
        ),
        tooltip: 'Открыть файл',
        onPressed: () => _pickFiles(context),
        splashRadius: buttonSize / 2,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
