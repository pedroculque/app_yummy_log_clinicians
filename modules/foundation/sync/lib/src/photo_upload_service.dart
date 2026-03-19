import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum _AuthUploadReady { ok, noUser, mismatch, tokenFailed }

/// Resultado do upload da foto de perfil.
class ProfilePhotoUploadResult {
  const ProfilePhotoUploadResult._({this.url, this.failureCode});

  const ProfilePhotoUploadResult.success(String downloadUrl)
      : this._(url: downloadUrl);

  const ProfilePhotoUploadResult.failure(this.failureCode) : url = null;

  final String? url;
  /// `unauthenticated` | `user_mismatch` | `token` | `storage`
  final String? failureCode;

  bool get isSuccess => url != null;
}

/// Serviço de upload/download de fotos de refeições para Cloud Storage.
///
/// Baseado no PhotoSyncService do growth_standards.
class PhotoUploadService {
  PhotoUploadService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Diretório local para fotos de refeições.
  static const String _mealPhotosDir = 'meal_photos';

  /// Prefixo para identificar URLs do Firebase Storage.
  static const String _httpsUrlPrefix = 'https://';

  /// Faz upload de uma foto local e retorna a URL pública.
  /// Path no Storage: `users/{userId}/meal_photos/{mealId}.jpg`
  Future<String?> uploadPhoto({
    required String userId,
    required String mealId,
    required String localPath,
  }) async {
    try {
      // Resolve o path absoluto
      final absolutePath = await _resolveLocalPath(localPath);
      if (absolutePath == null) {
        debugPrint('[PhotoUploadService] local file not found: $localPath');
        return null;
      }

      final file = File(absolutePath);
      if (!file.existsSync()) {
        debugPrint('[PhotoUploadService] file does not exist: $absolutePath');
        return null;
      }

      // Gera o path no Storage
      final extension = p.extension(localPath).toLowerCase();
      final ext = extension.isNotEmpty ? extension : '.jpg';
      final storagePath = 'users/$userId/meal_photos/$mealId$ext';

      debugPrint('[PhotoUploadService] uploading to $storagePath');

      // Faz upload
      final ref = _storage.ref(storagePath);
      await ref.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(ext),
          customMetadata: {
            'mealId': mealId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Retorna a URL de download
      final downloadUrl = await ref.getDownloadURL();
      debugPrint('[PhotoUploadService] SUCCESS - $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint(
        '[PhotoUploadService] FirebaseException: ${e.code} - ${e.message}',
      );
      return null;
    } on Object catch (e) {
      debugPrint('[PhotoUploadService] ERROR - $e');
      return null;
    }
  }

  /// Faz download de uma foto do Firebase Storage para armazenamento local.
  ///
  /// Para URLs https (com token), usa HTTP GET para evitar regras do Storage.
  /// Retorna o path local relativo, ou null se falhar.
  Future<String?> downloadPhoto({
    required String mealId,
    required String photoUrl,
  }) async {
    debugPrint('[PhotoUploadService] downloading from $photoUrl');

    // URLs de download do Firebase Storage (https com token) não passam pelas
    // regras do SDK; usar HTTP GET evita firebase_storage/unauthorized.
    if (photoUrl.startsWith(_httpsUrlPrefix)) {
      final path = await _downloadPhotoViaHttp(photoUrl, mealId);
      if (path != null) return path;
    }

    // Fallback para SDK
    try {
      final ref = _storage.refFromURL(photoUrl);

      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(appDir.path, _mealPhotosDir));
      if (!photosDir.existsSync()) {
        await photosDir.create(recursive: true);
      }

      final metadata = await ref.getMetadata();
      final extension = _getExtensionFromContentType(metadata.contentType);
      final fileName = '$mealId$extension';
      final localAbsolutePath = p.join(photosDir.path, fileName);

      final file = File(localAbsolutePath);
      await ref.writeToFile(file);

      final relativePath = p.join(_mealPhotosDir, fileName);
      debugPrint('[PhotoUploadService] download SUCCESS - $relativePath');
      return relativePath;
    } on Object catch (e) {
      debugPrint('[PhotoUploadService] download ERROR - $e');
      return null;
    }
  }

  /// Download via HTTP GET usando a URL com token.
  Future<String?> _downloadPhotoViaHttp(String url, String mealId) async {
    try {
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode != 200) return null;

        final appDir = await getApplicationDocumentsDirectory();
        final photosDir = Directory(p.join(appDir.path, _mealPhotosDir));
        if (!photosDir.existsSync()) {
          await photosDir.create(recursive: true);
        }

        final contentType = response.headers.contentType?.mimeType;
        final extension = _getExtensionFromContentType(contentType);
        final fileName = '$mealId$extension';
        final localAbsolutePath = p.join(photosDir.path, fileName);

        final file = File(localAbsolutePath);
        final sink = file.openWrite();
        await response.pipe(sink);
        await sink.close();

        final relativePath = p.join(_mealPhotosDir, fileName);
        debugPrint(
          '[PhotoUploadService] HTTP download SUCCESS - $relativePath',
        );
        return relativePath;
      } finally {
        client.close();
      }
    } on Object catch (e) {
      debugPrint('[PhotoUploadService] HTTP download failed - $e');
      return null;
    }
  }

  /// Upload da foto de perfil. Path: `users/{userId}/profile/avatar{ext}`.
  Future<ProfilePhotoUploadResult> uploadProfilePhoto({
    required String userId,
    required String localPath,
  }) async {
    try {
      final absolutePath = await _resolveLocalPath(localPath);
      if (absolutePath == null) {
        debugPrint(
          '[PhotoUploadService] profile: local file not found: $localPath',
        );
        return const ProfilePhotoUploadResult.failure('storage');
      }
      final file = File(absolutePath);
      if (!file.existsSync()) {
        debugPrint(
          '[PhotoUploadService] profile: file missing: $absolutePath',
        );
        return const ProfilePhotoUploadResult.failure('storage');
      }
      final extension = p.extension(localPath).toLowerCase();
      final ext = extension.isNotEmpty ? extension : '.jpg';
      final storagePath = 'users/$userId/profile/avatar$ext';
      debugPrint('[PhotoUploadService] profile upload → $storagePath');
      switch (await _ensureAuthForUpload(userId)) {
        case _AuthUploadReady.noUser:
          return const ProfilePhotoUploadResult.failure('unauthenticated');
        case _AuthUploadReady.mismatch:
          return const ProfilePhotoUploadResult.failure('user_mismatch');
        case _AuthUploadReady.tokenFailed:
          return const ProfilePhotoUploadResult.failure('token');
        case _AuthUploadReady.ok:
          break;
      }
      final ref = _storage.ref(storagePath);
      await ref.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(ext),
          customMetadata: {
            'type': 'profile',
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );
      final downloadUrl = await ref.getDownloadURL();
      debugPrint('[PhotoUploadService] profile SUCCESS');
      return ProfilePhotoUploadResult.success(downloadUrl);
    } on FirebaseException catch (e) {
      debugPrint(
        '[PhotoUploadService] profile FirebaseException: ${e.code}',
      );
      return ProfilePhotoUploadResult.failure(
        e.code == 'unauthenticated' ? 'unauthenticated' : 'storage',
      );
    } on Object catch (e) {
      debugPrint('[PhotoUploadService] profile ERROR - $e');
      return const ProfilePhotoUploadResult.failure('storage');
    }
  }

  /// Verifica sessão ativa e UID correto.
  static Future<_AuthUploadReady> _ensureAuthForUpload(
    String expectedUserId,
  ) async {
    final u = firebase_auth.FirebaseAuth.instance.currentUser;
    if (u == null) {
      debugPrint('[PhotoUploadService] no Firebase user (sign in again)');
      return _AuthUploadReady.noUser;
    }
    if (u.uid != expectedUserId) {
      debugPrint(
        '[PhotoUploadService] auth uid=${u.uid} != userId=$expectedUserId',
      );
      return _AuthUploadReady.mismatch;
    }
    return _AuthUploadReady.ok;
  }

  /// Remove uma foto do Storage.
  Future<void> deletePhoto({
    required String userId,
    required String mealId,
  }) async {
    // Tenta deletar com diferentes extensões
    final extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

    for (final ext in extensions) {
      try {
        final storagePath = 'users/$userId/meal_photos/$mealId$ext';
        final ref = _storage.ref(storagePath);
        await ref.delete();
        debugPrint('[PhotoUploadService] deleted $storagePath');
        return;
      } on Object catch (_) {
        // Arquivo não existe com essa extensão, tenta próxima
      }
    }
  }

  /// Resolve um path local relativo para absoluto.
  Future<String?> _resolveLocalPath(String? path) async {
    if (path == null || path.isEmpty) return null;

    final appDir = await getApplicationDocumentsDirectory();

    // Se já é um path absoluto
    if (p.isAbsolute(path)) {
      return path;
    }

    // Se é um path relativo (começa com meal_photos/)
    if (path.startsWith(_mealPhotosDir)) {
      return p.join(appDir.path, path);
    }

    // Tenta como path relativo direto
    return p.join(appDir.path, path);
  }

  /// Retorna o content type baseado na extensão.
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Retorna a extensão baseada no content type.
  String _getExtensionFromContentType(String? contentType) {
    switch (contentType) {
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/gif':
        return '.gif';
      case 'image/webp':
        return '.webp';
      default:
        return '.jpg';
    }
  }
}
