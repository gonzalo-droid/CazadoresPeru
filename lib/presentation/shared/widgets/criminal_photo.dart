import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/utils/base64_utils.dart';

/// Widget que renderiza una foto Base64 de criminal con fallback.
class CriminalPhoto extends StatelessWidget {
  const CriminalPhoto({
    super.key,
    this.base64Photo,
    this.size = 60,
    this.borderRadius,
    this.shape = BoxShape.circle,
  });

  final String? base64Photo;
  final double size;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final bytes = Base64Utils.decodePhoto(base64Photo);
    return _PhotoWidget(
      bytes: bytes,
      size: size,
      borderRadius: borderRadius,
      shape: shape,
    );
  }
}

class _PhotoWidget extends StatelessWidget {
  const _PhotoWidget({
    required this.bytes,
    required this.size,
    this.borderRadius,
    required this.shape,
  });

  final Uint8List? bytes;
  final double size;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
          image: DecorationImage(
            image: MemoryImage(bytes!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Icon(
        Icons.person,
        size: size * 0.55,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
