import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const String _mealPhotosDir = 'meal_photos';

String? _cachedDocsDir;

/// Inicializa o cache do diretório de documentos. Deve ser chamado uma vez
/// no startup do app (ou antes de exibir fotos).
Future<String> getDocsDir() async {
  if (_cachedDocsDir != null) return _cachedDocsDir!;
  final dir = await getApplicationDocumentsDirectory();
  _cachedDocsDir = dir.path;
  return _cachedDocsDir!;
}

/// Retorna o docsDir cacheado, ou null se ainda não foi inicializado.
String? get cachedDocsDir => _cachedDocsDir;

/// Copia a foto de [sourcePath] para o armazenamento persistente do app,
/// usando [entryId] como nome do arquivo. Retorna o **path relativo**
/// (ex: `meal_photos/123.jpg`) para ser salvo no banco — paths relativos
/// sobrevivem a rebuilds que alteram o UUID do sandbox no iOS/Android.
Future<String> copyToPersistentStorage(
  String sourcePath,
  String entryId,
) async {
  final dir = await getApplicationDocumentsDirectory();
  final photosDir = Directory(p.join(dir.path, _mealPhotosDir));
  if (!photosDir.existsSync()) {
    photosDir.createSync(recursive: true);
  }
  final extension = p.extension(sourcePath).isEmpty
      ? '.jpg'
      : p.extension(sourcePath);
  final fileName = '$entryId$extension';
  final destPath = p.join(photosDir.path, fileName);

  final source = File(sourcePath);
  final dest = File(destPath);
  if (source.path != dest.path) {
    await source.copy(destPath);
  }

  return p.join(_mealPhotosDir, fileName);
}

/// Resolve um [photoPath] (relativo ou absoluto legado) para o path absoluto
/// do arquivo no sistema de arquivos.
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

/// Versão síncrona de [resolvePhotoPath] quando o [docsDir] já é conhecido.
String resolvePhotoPathSync(String photoPath, String docsDir) {
  if (p.isAbsolute(photoPath)) {
    if (File(photoPath).existsSync()) return photoPath;
    return p.join(docsDir, _mealPhotosDir, p.basename(photoPath));
  }
  return p.join(docsDir, photoPath);
}
