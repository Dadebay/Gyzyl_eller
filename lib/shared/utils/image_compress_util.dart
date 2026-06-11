import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Resimi sıkıştırıp WebP formatına dönüştürür.
/// [quality] 0-100 arası (default: 80)
Future<File> compressToWebP(File file, {int quality = 80}) async {
  final dir = await getTemporaryDirectory();
  final baseName = p.basenameWithoutExtension(file.path);
  final targetPath = p.join(dir.path, '${baseName}_compressed.webp');

  final XFile? result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    format: CompressFormat.webp,
    quality: quality,
  );

  if (result == null) return file;
  return File(result.path);
}
