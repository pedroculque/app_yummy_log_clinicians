import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String _mealPhotosDir = 'meal_photos';

/// Resolve [photoPath] (relativo ou absoluto) para path absoluto no disco.
Future<String> resolveMealPhotoPath(String photoPath) async {
  if (p.isAbsolute(photoPath)) {
    if (File(photoPath).existsSync()) return photoPath;
    final fileName = p.basename(photoPath);
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _mealPhotosDir, fileName);
  }
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, photoPath);
}
