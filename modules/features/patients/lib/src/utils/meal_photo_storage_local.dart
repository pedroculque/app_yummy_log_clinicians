import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String _mealPhotosDir = 'meal_photos';

String? _cachedDocsDir;

Future<String> getDocsDir() async {
  if (_cachedDocsDir != null) return _cachedDocsDir!;
  final dir = await getApplicationDocumentsDirectory();
  _cachedDocsDir = dir.path;
  return _cachedDocsDir!;
}

String? get cachedDocsDir => _cachedDocsDir;

Future<String> resolvePhotoPath(String photoPath) async {
  if (p.isAbsolute(photoPath)) {
    if (File(photoPath).existsSync()) return photoPath;
    final fileName = p.basename(photoPath);
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _mealPhotosDir, fileName);
  }
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, photoPath);
}

String resolvePhotoPathSync(String photoPath, String docsDir) {
  if (p.isAbsolute(photoPath)) {
    if (File(photoPath).existsSync()) return photoPath;
    return p.join(docsDir, _mealPhotosDir, p.basename(photoPath));
  }
  return p.join(docsDir, photoPath);
}
