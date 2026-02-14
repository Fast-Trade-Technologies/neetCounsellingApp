import 'package:flutter/material.dart';

class AppAssetImage extends StatelessWidget {
  const AppAssetImage(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: width,
        height: height,
        child: const Center(child: Icon(Icons.image_not_supported_outlined)),
      ),
    );
  }
}
