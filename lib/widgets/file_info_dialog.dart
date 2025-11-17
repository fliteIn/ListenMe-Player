import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_model.dart';
import 'icon_with_shadow.dart';
import 'text_with_shadow.dart';
import '../l10n/app_localizations.dart';

// SAF: вся работа с метаданными идёт через платформенный канал, который возвращает Map<String, dynamic>
// Передавай сюда uri (String) и info (Map), и, по возможности, имя файла отдельно (entry.name)
void showFileInfoDialog(BuildContext context, String uri, Map<String, dynamic> info, {String? fileName}) async {
  final app = context.read<AppModel>();
  final theme = app.themeColors;
  final loc = AppLocalizations.of(context)!;



  final displayPath = uri; // Можно парсить для красоты, но обычно SAF uri выглядит как content://...

  final format = info['format'] ?? {};
  final tags = format['tags'] ?? {};
  final streams = info['streams'] ?? [];
  final audioStream = streams.isNotEmpty ? streams[0] : {};

  const allowedTags = [
    'title', 'artist', 'album', 'album_artist', 'genre', 'track', 'composer', 'year', 'date'
  ];

  final tagNames = <String, String>{
    'title':        loc.fileTagTitle,
    'artist':       loc.fileTagArtist,
    'album':        loc.fileTagAlbum,
    'album_artist': loc.fileTagAlbumArtist,
    'genre':        loc.fileTagGenre,
    'track':        loc.fileTagTrack,
    'composer':     loc.fileTagComposer,
    'year':         loc.fileTagYear,
    'date':         loc.fileTagDate,
  };

  final mainTagLines = tags.entries
      .where((e) => allowedTags.contains(e.key.toLowerCase()))
      .map((e) => '${tagNames[e.key.toLowerCase()] ?? e.key}: ${e.value}')
      .toList();

  String fileSizeMB(dynamic size) {
    if (size == null) return '-';
    final bytes = int.tryParse(size.toString());
    if (bytes == null) return '-';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} ${loc.mb}';
  }

  String formatDuration(dynamic seconds) {
    if (seconds == null) return '-';
    final totalSeconds = double.tryParse(seconds.toString())?.round() ?? 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final secs = totalSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }

  String bitrateKbps(dynamic bitRate) {
    if (bitRate == null) return '-';
    final bps = int.tryParse(bitRate.toString());
    if (bps == null) return '-';
    return '${(bps / 1000).round()} ${loc.kbps}';
  }

  String sampleRateKhz(dynamic sampleRate) {
    if (sampleRate == null) return '-';
    final hz = int.tryParse(sampleRate.toString());
    if (hz == null) return '-';
    return '${(hz / 1000).toStringAsFixed(1)} ${loc.khz}';
  }

  String channelInfo(dynamic channels) {
    if (channels == null) return '-';
    final ch = int.tryParse(channels.toString());
    if (ch == 1) return loc.mono;
    if (ch == 2) return loc.stereo;
    if (ch != null) return '$ch';
    return '-';
  }

  String extractFileNameFromSafUri(String uri) {
    // Декодируем все %XX
    final decoded = Uri.decodeFull(uri);

    // Если это tree-URI — убираем префикс до последнего document/
    final documentIndex = decoded.lastIndexOf("/document/");
    final base = documentIndex != -1 ? decoded.substring(documentIndex + 10) : decoded;

    // После этого остаётся что-то вроде:
    // "0000-0000:Music/На новый год/linda-otpusti-menya_(luxmp3.net).mp3"
    // Оставляем только последнее после '/'
    final clean = base.contains("/") ? base.split("/").last : base;

    return clean;
  }


  final displayName = fileName ?? extractFileNameFromSafUri(uri);

  final codec = audioStream['codec_name'] ?? '-';
  final sampleFmt = audioStream['sample_fmt'] ?? '-';
  final bitsPerSample = audioStream['bits_per_sample'];
  final startTime = audioStream['start_time'];
  String vbrCbr() {
    final vbrTag = tags['vbr'] ?? tags['VBR'] ?? '';
    if (vbrTag.toString().isNotEmpty) {
      return vbrTag.toString().toLowerCase() == 'true' ? loc.vbr : loc.cbr;
    }
    if (audioStream.containsKey('bit_rate')) {
      return loc.cbr;
    }
    return '-';
  }

  final lines = <String>[
    '${loc.fileName}: $displayName',
    //'${loc.filePath}: $displayPath',
    '${loc.fileSize}: ${fileSizeMB(format['size'])}',
    '${loc.fileFormat}: ${format['format_name'] ?? '-'}',
    '${loc.fileCodec}: $codec',
    //'${loc.fileSampleFormat}: $sampleFmt',
    //'${loc.fileBitDepth}: ${bitsPerSample != null && bitsPerSample != 0 ? bitsPerSample : '-'}',
    '${loc.fileDuration}: ${formatDuration(format['duration'])}',
    '${loc.fileBitrate}: ${bitrateKbps(format['bit_rate'] ?? audioStream['bit_rate'])}',
    '${loc.fileChannels}: ${channelInfo(audioStream['channels'])}',
    '${loc.fileSampleRate}: ${sampleRateKhz(audioStream['sample_rate'])}',
    '${loc.fileBitrateType}: ${vbrCbr()}',
    //'${loc.fileStartOffset}: ${startTime ?? '-'}',
    loc.fileTagsSection,
    if (mainTagLines.isNotEmpty)
      ...mainTagLines
    else
      loc.fileNoTags,
  ];

  Widget buildInfoLine(String line) {
    final sepIdx = line.indexOf(':');
    if (sepIdx > 0) {
      final key = line.substring(0, sepIdx + 1);
      final value = line.substring(sepIdx + 1).trim();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            TextWithShadow(
              text: key + ' ',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.currentValueText.color,
              shadowColor: theme.currentValueText.shadowColor,
              shadowBlur: theme.currentValueText.shadowBlur,
              shadowEnabled: theme.currentValueText.shadowEnabled,
            ),
            Expanded(
              child: TextWithShadow(
                text: value,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: theme.currentValueText.color,
                shadowColor: theme.currentValueText.shadowColor,
                shadowBlur: theme.currentValueText.shadowBlur,
                shadowEnabled: theme.currentValueText.shadowEnabled,
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.6),
        child: TextWithShadow(
          text: line,
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: theme.currentValueText.color,
          shadowColor: theme.currentValueText.shadowColor,
          shadowBlur: theme.currentValueText.shadowBlur,
          shadowEnabled: theme.currentValueText.shadowEnabled,
        ),
      );
    }
  }

  final mq = MediaQuery.of(context);

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: loc.close,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (context, anim1, anim2) {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              width: mq.size.width > 600 ? 540 : mq.size.width,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.backgroundStart.withOpacity(0.95),
                    theme.backgroundEnd.withOpacity(0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.controlElements.color,
                  width: 1.0,
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 6),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconWithShadow(
                            icon: Icons.info_outline,
                            size: 21,
                            color: theme.displayIconActive.color,
                            shadowColor: theme.displayIconActive.shadowColor,
                            shadowBlur: theme.displayIconActive.shadowBlur,
                            shadowEnabled: theme.displayIconActive.shadowEnabled,
                          ),
                          const SizedBox(width: 10),
                          TextWithShadow(
                            text: loc.fileInfo,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.currentValueText.color,
                            shadowColor: theme.currentValueText.shadowColor,
                            shadowBlur: theme.currentValueText.shadowBlur,
                            shadowEnabled: theme.currentValueText.shadowEnabled,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: ScrollbarTheme(
                      data: ScrollbarThemeData(
                        thumbColor: MaterialStateProperty.all(theme.controlElements.color),
                        thickness: MaterialStateProperty.all(8),
                        radius: const Radius.circular(4),
                        thumbVisibility: MaterialStateProperty.all(true),
                      ),
                      child: Scrollbar(
                        thumbVisibility: true,
                        interactive: true,
                        thickness: 8,
                        radius: const Radius.circular(4),
                        scrollbarOrientation: ScrollbarOrientation.right,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: lines.map(buildInfoLine).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 13, 18, 15),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.buttonIconText.color,
                          backgroundColor: theme.controlElements.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        child: Text(loc.ok),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
