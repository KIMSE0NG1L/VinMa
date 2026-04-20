import 'dart:io';

import 'package:flutter/material.dart';

import '../network/image_headers.dart';

class VinMaImage extends StatelessWidget {
  const VinMaImage({
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.error,
    super.key,
  });

  final String url;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? error;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _errorWidget(context);
    }

    if (url.startsWith('file://')) {
      final file = File(Uri.parse(url).toFilePath());
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _errorWidget(context),
      );
    }

    return Image.network(
      url,
      fit: fit,
      headers: imageRequestHeaders(url),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return _placeholderWidget(context);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return _placeholderWidget(context);
      },
      errorBuilder: (context, error, stackTrace) => _errorWidget(context),
    );
  }

  Widget _placeholderWidget(BuildContext context) {
    return placeholder ??
        ColoredBox(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator.adaptive()),
        );
  }

  Widget _errorWidget(BuildContext context) {
    return error ??
        ColoredBox(
          color: Colors.grey.shade200,
          child: const Center(child: Icon(Icons.image_not_supported_outlined)),
        );
  }
}
