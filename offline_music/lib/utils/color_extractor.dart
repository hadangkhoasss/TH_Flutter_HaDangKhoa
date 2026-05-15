import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ImageColorService {
  /// Lấy màu nổi bật nhất từ ảnh
  Future<Color> extractMainColor(
    ImageProvider source, {
    Color fallback = Colors.black,
  }) async {
    final generator = await PaletteGenerator.fromImageProvider(
      source,
      size: const Size(200, 200),
      maximumColorCount: 16,
    );

    return generator.vibrantColor?.color ??
        generator.dominantColor?.color ??
        fallback;
  }
}
