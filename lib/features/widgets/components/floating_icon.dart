import 'package:flutter/material.dart';

// Floating Icons Decor
Widget floatingIcon(String assetPath, double size) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      image: DecorationImage(image: AssetImage(assetPath)),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
    ),
  );
}


