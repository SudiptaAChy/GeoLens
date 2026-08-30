import 'package:flutter/material.dart';

class CaptureButton extends StatelessWidget {
  final bool isCapturing;
  final VoidCallback onTap;

  const CaptureButton({super.key, required this.isCapturing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCapturing ? null : onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCapturing ? Colors.white38 : Colors.white,
          ),
          alignment: Alignment.center,
          child: isCapturing
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.black54,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
