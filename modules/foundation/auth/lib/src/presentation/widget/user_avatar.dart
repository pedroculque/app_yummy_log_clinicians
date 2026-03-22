import 'dart:async';

import 'package:auth_foundation/src/auth_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

/// Avatar do usuário com foto ou iniciais.
///
/// URLs `firebasestorage.googleapis.com` usam regras do Storage que exigem
/// utilizador autenticado no pedido; o carregador de rede não envia sessão
/// sozinha — obtemos o ID token e enviamos em `Authorization`.
class UserAvatar extends StatefulWidget {
  const UserAvatar({
    required this.user,
    this.size = 40,
    /// Se a URL remota se mantém igual (overwrite no Storage), use um valor
    /// novo por upload (`updatedAt`, bust) para invalidar cache.
    this.networkImageCacheKey,
    super.key,
  });

  final AuthUser user;
  final double size;
  final String? networkImageCacheKey;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  Map<String, String>? _httpHeaders;
  bool _storageHeadersLoading = false;

  static bool _isFirebaseStorageDownloadUrl(String url) =>
      url.contains('firebasestorage.googleapis.com');

  @override
  void initState() {
    super.initState();
    unawaited(_resolveStorageAuthHeaders());
  }

  @override
  void didUpdateWidget(covariant UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.uid != widget.user.uid ||
        oldWidget.user.photoUrl != widget.user.photoUrl) {
      unawaited(_resolveStorageAuthHeaders());
    }
  }

  Future<void> _resolveStorageAuthHeaders() async {
    final url = widget.user.photoUrl;
    if (url == null ||
        url.isEmpty ||
        !_isFirebaseStorageDownloadUrl(url)) {
      if (_httpHeaders != null || _storageHeadersLoading) {
        setState(() {
          _httpHeaders = null;
          _storageHeadersLoading = false;
        });
      }
      return;
    }

    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || firebaseUser.uid != widget.user.uid) {
      if (_httpHeaders != null || _storageHeadersLoading) {
        setState(() {
          _httpHeaders = null;
          _storageHeadersLoading = false;
        });
      }
      return;
    }

    setState(() => _storageHeadersLoading = true);
    try {
      final token = await firebaseUser.getIdToken();
      if (!mounted) return;
      setState(() {
        _httpHeaders =
            token != null ? {'Authorization': 'Bearer $token'} : null;
        _storageHeadersLoading = false;
      });
    } on Object catch (e, st) {
      if (kDebugMode) {
        debugPrint('UserAvatar getIdToken: $e $st');
      }
      if (mounted) {
        setState(() {
          _httpHeaders = null;
          _storageHeadersLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.fromContext(context);

    if (widget.user.photoUrl != null && widget.user.photoUrl!.isNotEmpty) {
      final url = widget.user.photoUrl!;
      final needsStorageAuth = _isFirebaseStorageDownloadUrl(url);
      if (needsStorageAuth && _storageHeadersLoading) {
        return ClipOval(
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: ColoredBox(
              color: colors.grayLight,
              child: Center(
                child: SizedBox(
                  width: widget.size * 0.35,
                  height: widget.size * 0.35,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      final hasKey = widget.networkImageCacheKey != null &&
          widget.networkImageCacheKey!.isNotEmpty;
      var effectiveKey = hasKey
          ? '$url|${widget.networkImageCacheKey!}'
          : null;
      if (_httpHeaders != null) {
        effectiveKey = effectiveKey != null
            ? '$effectiveKey|firebaseAuth'
            : '$url|firebaseAuth';
      }

      return ClipOval(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CachedNetworkImage(
            imageUrl: url,
            cacheKey: effectiveKey,
            httpHeaders: _httpHeaders,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            placeholder: (context, url) => ColoredBox(
              color: colors.grayLight,
              child: Center(
                child: SizedBox(
                  width: widget.size * 0.35,
                  height: widget.size * 0.35,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              if (kDebugMode) {
                debugPrint(
                  'UserAvatar CachedNetworkImage error url=$url error=$error',
                );
              }
              return ColoredBox(
                color: colors.primary,
                child: Center(
                  child: Text(
                    widget.user.initials,
                    style: TextStyle(
                      color: colors.neutralWhite,
                      fontSize: widget.size * 0.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: widget.size / 2,
      backgroundColor: colors.primary,
      child: Text(
        widget.user.initials,
        style: TextStyle(
          color: colors.neutralWhite,
          fontSize: widget.size * 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
