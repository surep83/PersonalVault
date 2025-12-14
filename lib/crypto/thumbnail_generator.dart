import 'dart:typed_data';
import 'dart:ui' as ui show ImageByteFormat;
import 'package:pdf_render/pdf_render.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../models/item.dart';

class ThumbnailGenerator {
  static Future<Uint8List?> generateThumbnail(VaultItem item) async {
    if(item.fields['file_path'] == null) return null;
    final path = item.fields['file_path'];

    if (path.endsWith('.pdf')) {
      final dynamic doc = await PdfDocument.openFile(path);
      final dynamic page = await doc.getPage(1);

      // Use dynamic to be tolerant of different pdf_render versions/signatures
      final dynamic img = await page.render(width: 100, height: 100);

      Uint8List? pngBytes;
      final dynamic dyn = img;
      if (dyn == null) {
        try {
          await page.close();
        } catch (_) {}
        try {
          await doc.dispose();
        } catch (_) {}
        return null;
      }

      try {
        if (dyn is Uint8List) {
          pngBytes = dyn;
        } else if (dyn.bytes != null) {
          pngBytes = Uint8List.fromList(List<int>.from(dyn.bytes));
        } else if (dyn.image != null) {
          final bd = await (dyn.image as dynamic).toByteData(format: ui.ImageByteFormat.png);
          pngBytes = bd?.buffer.asUint8List();
        }
      } catch (_) {
        try {
          final bd = await (dyn.image as dynamic).toByteData(format: ui.ImageByteFormat.png);
          pngBytes = bd?.buffer.asUint8List();
        } catch (_) {
          pngBytes = null;
        }
      }

      try {
        await page.close();
      } catch (_) {}
      try {
        await doc.dispose();
      } catch (_) {}

      if (pngBytes == null) return null;
      final compressed = await FlutterImageCompress.compressWithList(pngBytes, minWidth: 100, minHeight: 100, quality: 80);
      return Uint8List.fromList(compressed);
    } else if(path.endsWith('.jpg') || path.endsWith('.png')) {
      final data = await FlutterImageCompress.compressWithFile(path, minWidth: 100, minHeight: 100, quality: 80);
      return data != null ? Uint8List.fromList(data) : null;
    }
    return null;
  }
}
