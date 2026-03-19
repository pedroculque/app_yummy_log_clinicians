import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:patients_feature/src/utils/meal_photo_storage_local.dart';

/// Widget que exibe imagem com altura adaptativa à proporção.
/// Preenche a largura sem zoom/crop e sem letterboxing — o container ajusta
/// a altura para mostrar a foto inteira.
class AdaptivePhoto extends StatefulWidget {
  const AdaptivePhoto({
    this.photoPath,
    this.photoUrl,
    this.maxHeight = 400,
    this.borderRadius,
    this.backgroundColor,
    this.placeholder,
    super.key,
  });

  final String? photoPath;
  final String? photoUrl;
  final double maxHeight;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Widget? placeholder;

  @override
  State<AdaptivePhoto> createState() => _AdaptivePhotoState();
}

/// Cache de dimensões por URL/path para evitar refetch ao reabrir a tela.
final Map<String, Size> _dimensionCache = {};
const int _maxCacheEntries = 100;

class _AdaptivePhotoState extends State<AdaptivePhoto> {
  Size? _imageSize;
  String? _resolvedPath;
  bool _loading = true;
  String? _error;

  bool get _hasLocal =>
      widget.photoPath != null && widget.photoPath!.isNotEmpty;
  bool get _hasRemote =>
      widget.photoUrl != null && widget.photoUrl!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    unawaited(_loadImageSize());
  }

  @override
  void didUpdateWidget(AdaptivePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoPath != widget.photoPath ||
        oldWidget.photoUrl != widget.photoUrl) {
      _imageSize = null;
      _resolvedPath = null;
      _loading = true;
      _error = null;
      unawaited(_loadImageSize());
    }
  }

  Future<void> _loadImageSize() async {
    if (!_hasLocal && !_hasRemote) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    final cacheKey = _hasLocal ? widget.photoPath! : widget.photoUrl!;
    final cached = _dimensionCache[cacheKey];
    if (cached != null) {
      String? resolved;
      if (_hasLocal) {
        await getDocsDir();
        resolved = cachedDocsDir != null
            ? resolvePhotoPathSync(widget.photoPath!, cachedDocsDir!)
            : await resolvePhotoPath(widget.photoPath!);
      }
      if (mounted) {
        setState(() {
          _imageSize = cached;
          _resolvedPath = resolved;
          _loading = false;
        });
      }
      return;
    }

    Size? size;
    String? resolved;

    if (_hasLocal) {
      try {
        await getDocsDir();
        resolved = cachedDocsDir != null
            ? resolvePhotoPathSync(widget.photoPath!, cachedDocsDir!)
            : await resolvePhotoPath(widget.photoPath!);
        final file = File(resolved);
        if (file.existsSync()) {
          final bytes = await file.readAsBytes();
          final image = await decodeImageFromList(bytes);
          size = Size(image.width.toDouble(), image.height.toDouble());
          image.dispose();
        }
      } on Object catch (e) {
        _error = e.toString();
      }
    }

    if (size == null && _hasRemote) {
      try {
        size = await _fetchRemoteImageSize(widget.photoUrl!);
      } on Object catch (e) {
        _error = e.toString();
      }
    }

    if (size != null) {
      if (_dimensionCache.length >= _maxCacheEntries) {
        _dimensionCache.remove(_dimensionCache.keys.first);
      }
      _dimensionCache[cacheKey] = size;
    }

    if (mounted) {
      setState(() {
        _imageSize = size;
        _resolvedPath = resolved;
        _loading = false;
      });
    }
  }

  Future<Size> _fetchRemoteImageSize(String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final bytes = await consolidateHttpClientResponseBytes(response);
      final image = await decodeImageFromList(bytes);
      final size = Size(image.width.toDouble(), image.height.toDouble());
      image.dispose();
      return size;
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLocal && !_hasRemote) {
      return _buildPlaceholder(context);
    }

    if (_loading) {
      return _buildPlaceholder(context, loading: true);
    }

    if (_error != null) {
      return _buildPlaceholder(context);
    }

    if (_imageSize == null && _hasRemote) {
      return _buildFallbackFixedHeight(context);
    }

    if (_imageSize != null) {
      return _buildAdaptiveImage(context);
    }

    return _buildFallbackFixedHeight(context);
  }

  Widget _buildAdaptiveImage(BuildContext context) {
    final size = _imageSize!;
    final aspectRatio = size.width / size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        var width = constraints.maxWidth;
        var height = width / aspectRatio;
        if (height > widget.maxHeight) {
          height = widget.maxHeight;
          width = height * aspectRatio;
        }

        return Center(
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: Container(
              width: width,
              height: height,
              color: widget.backgroundColor,
              child: _hasLocal && _resolvedPath != null
                ? Image.file(
                    File(_resolvedPath!),
                    width: width,
                    height: height,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        _buildNetworkFallback(width, height),
                  )
                : _buildNetworkImage(width, height),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNetworkImage(double width, double height) {
    if (widget.photoUrl == null || widget.photoUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }
    return CachedNetworkImage(
      imageUrl: widget.photoUrl!,
      width: width,
      height: height,
      fit: BoxFit.contain,
      placeholder: (_, _) => _buildPlaceholder(context, loading: true),
      errorWidget: (_, _, _) => _buildPlaceholder(context),
    );
  }

  Widget _buildNetworkFallback(double width, double height) {
    if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.photoUrl!,
        width: width,
        height: height,
        fit: BoxFit.contain,
        placeholder: (_, _) => _buildPlaceholder(context, loading: true),
        errorWidget: (_, _, _) => _buildPlaceholder(context),
      );
    }
    return _buildPlaceholder(context);
  }

  Widget _buildFallbackFixedHeight(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: Container(
        height: 220,
        width: double.infinity,
        color: widget.backgroundColor,
        child: _hasLocal
            ? FutureBuilder<String>(
                future: _resolvedPath != null
                    ? Future.value(_resolvedPath)
                    : resolvePhotoPath(widget.photoPath!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                  return _buildPlaceholder(context, loading: true);
                }
                  return Image.file(
                    File(snapshot.data!),
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        widget.photoUrl != null && widget.photoUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.photoUrl!,
                                fit: BoxFit.contain,
                                placeholder: (_, _) =>
                                    _buildPlaceholder(context, loading: true),
                                errorWidget: (_, _, _) =>
                                    _buildPlaceholder(context),
                              )
                            : _buildPlaceholder(context),
                  );
                },
              )
            : _hasRemote
                ? CachedNetworkImage(
                    imageUrl: widget.photoUrl!,
                    fit: BoxFit.contain,
                    placeholder: (_, _) =>
                        _buildPlaceholder(context, loading: true),
                    errorWidget: (_, _, _) =>
                        _buildPlaceholder(context),
                  )
                : _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, {bool loading = false}) {
    if (widget.placeholder != null && !loading) return widget.placeholder!;
    final theme = Theme.of(context);
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        color: widget.backgroundColor ??
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Center(
        child: loading
            ? SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
              )
            : Icon(
                Icons.restaurant_rounded,
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.4),
                size: 48,
              ),
      ),
    );
  }
}
