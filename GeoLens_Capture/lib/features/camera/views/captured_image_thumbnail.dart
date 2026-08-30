import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CapturedImageThumbnail extends StatelessWidget {
  final XFile? imageFile;
  final int batchCount;

  const CapturedImageThumbnail({super.key, 
    required this.imageFile,
    required this.batchCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 62,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.black45,
            ),
            clipBehavior: Clip.antiAlias,
            child: imageFile == null
                ? const Icon(
                    Icons.image_outlined,
                    color: Colors.white54,
                    size: 22,
                  )
                : Image.file(
                    File(imageFile!.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.white54,
                      size: 22,
                    ),
                  ),
          ),

          // Batch count badge — top right of the thumbnail
          if (batchCount > 0)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                constraints: const BoxConstraints(minWidth: 20),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$batchCount',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
