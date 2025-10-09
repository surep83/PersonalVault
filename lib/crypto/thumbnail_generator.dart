import 'dart:typed_data';
import 'package:pdf_render/pdf_render.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/item.dart';

class ThumbnailGenerator {
  static Future<Uint8List?> generateThumbnail(VaultItem item) async {
    if(item.fields['file_path'] == null) return null;
    final path = item.fields['file_path'];

    if(path.endsWith('.pdf')) {
      final doc = await PdfDocument.openFile(path);
      final page = await doc.getPage(1);
      final img = await page.render(width: 100, height: 100);
      final pngBytes = img.bytes;
      page.dispose();
      doc.dispose();
      final compressed = await FlutterImageCompress.compressWithList(pngBytes, minWidth: 100, minHeight: 100, quality: 80);
      return Uint8List.fromList(compressed);
    } else if(path.endsWith('.jpg') || path.endsWith('.png')) {
      final data = await FlutterImageCompress.compressWithFile(path, minWidth: 100, minHeight: 100, quality: 80);
      return data != null ? Uint8List.fromList(data) : null;
    }
    return null;
  }
}
