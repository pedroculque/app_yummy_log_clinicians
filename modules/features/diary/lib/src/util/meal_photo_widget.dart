import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:diary_feature/src/util/meal_photo_storage.dart';
import 'package:flutter/material.dart';

/// Widget que exibe foto de refeição, priorizando arquivo local e
/// fazendo fallback para URL remota quando disponível.
///
/// Ordem de prioridade:
/// 1. Arquivo local (photoPath) se existir
/// 2. URL remota (photoUrl) com cache via CachedNetworkImage
/// 3. Placeholder
class MealPhoto extends StatelessWidget {
  const MealPhoto({
    required this.photoPath,
    required this.photoUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  /// Caminho local da foto (relativo ou absoluto).
  final String? photoPath;

  /// URL da foto no Firebase Storage.
  final String? photoUrl;

  /// Largura do widget.
  final double? width;

  /// Altura do widget.
  final double? height;

  /// Como a imagem deve ser ajustada.
  final BoxFit fit;

  /// Raio das bordas arredondadas.
  final BorderRadius? borderRadius;

  /// Widget exibido enquanto carrega ou quando não há foto.
  final Widget? placeholder;

  /// Widget exibido em caso de erro.
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final hasLocalPath = photoPath != null && photoPath!.isNotEmpty;
    final hasRemoteUrl = photoUrl != null && photoUrl!.isNotEmpty;

    if (!hasLocalPath && !hasRemoteUrl) {
      return _wrapWithBorderRadius(
        placeholder ?? _defaultPlaceholder(context),
      );
    }

    if (hasLocalPath) {
      return _LocalPhotoImage(
        photoPath: photoPath!,
        photoUrl: photoUrl,
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }

    return _wrapWithBorderRadius(
      _buildNetworkImage(context),
    );
  }

  Widget _buildNetworkImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: photoUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ?? _defaultPlaceholder(context),
      errorWidget: (context, url, error) =>
          errorWidget ?? _defaultPlaceholder(context),
    );
  }

  Widget _wrapWithBorderRadius(Widget child) {
    if (borderRadius == null) return child;
    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }

  Widget _defaultPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          size: (width ?? height ?? 56) * 0.4,
        ),
      ),
    );
  }
}

class _LocalPhotoImage extends StatefulWidget {
  const _LocalPhotoImage({
    required this.photoPath,
    required this.photoUrl,
    required this.width,
    required this.height,
    required this.fit,
    required this.borderRadius,
    required this.placeholder,
    required this.errorWidget,
  });

  final String photoPath;
  final String? photoUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  State<_LocalPhotoImage> createState() => _LocalPhotoImageState();
}

class _LocalPhotoImageState extends State<_LocalPhotoImage> {
  File? _resolvedFile;
  bool _localExists = false;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveLocalFile());
  }

  @override
  void didUpdateWidget(_LocalPhotoImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoPath != widget.photoPath) {
      _checked = false;
      unawaited(_resolveLocalFile());
    }
  }

  Future<void> _resolveLocalFile() async {
    final docsDir = cachedDocsDir;
    String resolved;
    if (docsDir != null) {
      resolved = resolvePhotoPathSync(widget.photoPath, docsDir);
    } else {
      resolved = await resolvePhotoPath(widget.photoPath);
    }

    final file = File(resolved);
    final exists = file.existsSync();

    if (mounted) {
      setState(() {
        _resolvedFile = file;
        _localExists = exists;
        _checked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return _wrapWithBorderRadius(
        widget.placeholder ?? _defaultPlaceholder(context),
      );
    }

    if (_localExists && _resolvedFile != null) {
      return _wrapWithBorderRadius(
        Image.file(
          _resolvedFile!,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (context, error, stack) {
            if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
              return _buildNetworkFallback(context);
            }
            return widget.errorWidget ?? _defaultPlaceholder(context);
          },
        ),
      );
    }

    if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      return _wrapWithBorderRadius(_buildNetworkFallback(context));
    }

    return _wrapWithBorderRadius(
      widget.errorWidget ?? _defaultPlaceholder(context),
    );
  }

  Widget _buildNetworkFallback(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.photoUrl!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) =>
          widget.placeholder ?? _defaultPlaceholder(context),
      errorWidget: (context, url, error) =>
          widget.errorWidget ?? _defaultPlaceholder(context),
    );
  }

  Widget _wrapWithBorderRadius(Widget child) {
    if (widget.borderRadius == null) return child;
    return ClipRRect(
      borderRadius: widget.borderRadius!,
      child: child,
    );
  }

  Widget _defaultPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: widget.width,
      height: widget.height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          size: (widget.width ?? widget.height ?? 56) * 0.4,
        ),
      ),
    );
  }
}
