// utils/pcm_parser.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

class PcmArgs {
  final String wavPath;
  final int blockSize;
  const PcmArgs(this.wavPath, this.blockSize);
}

// ❗ Должна быть топ-level или static — это требование compute()
Future<List<double>> parsePcmLevelsIsolate(PcmArgs args) async {
  final file = File(args.wavPath);
  final bytes = await file.readAsBytes();          // читаем файл в изоляте
  if (bytes.length < 44) {
    throw Exception('Invalid WAV file');
  }
  final pcmData = Uint8List.view(bytes.buffer, 44); // skip заголовок
  final levels = <double>[];

  final stepBytes = args.blockSize * 2; // 16-bit PCM -> 2 байта на сэмпл
  for (int i = 0; i < pcmData.length; i += stepBytes) {
    int peak = 0;
    final end = (i + stepBytes <= pcmData.length) ? i + stepBytes : pcmData.length;
    for (int j = i; j + 1 < end; j += 2) {
      final lo = pcmData[j];
      final hi = pcmData[j + 1];
      final sample = lo | (hi << 8);
      final signed = sample >= 0x8000 ? sample - 0x10000 : sample;
      final absValue = signed.abs();
      if (absValue > peak) peak = absValue;
    }
    levels.add(peak / 32768.0);
  }

  // ← ВОТ СЮДА!
  print('MAX PCM LEVEL: ${levels.reduce(max)}');

  return levels;
}

