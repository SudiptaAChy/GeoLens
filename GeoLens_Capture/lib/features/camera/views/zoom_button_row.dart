import 'package:flutter/material.dart';

class ZoomButtonRow extends StatelessWidget {
  final double minZoom;
  final double maxZoom;
  final double currentZoom;
  final ValueChanged<double> onZoomSelected;

  const ZoomButtonRow({super.key, 
    required this.minZoom,
    required this.maxZoom,
    required this.currentZoom,
    required this.onZoomSelected,
  });

  @override
  Widget build(BuildContext context) {
    final presets = [
      0.5,
      1.0,
      2.0,
      3.0,
    ].where((z) => z >= minZoom && z <= maxZoom).toList();

    if (presets.isEmpty) presets.add(minZoom);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: presets.map((zoom) {
        final isSelected = (currentZoom - zoom).abs() < 0.05;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => onZoomSelected(zoom),
            child: Container(
              width: isSelected ? 44 : 36,
              height: isSelected ? 44 : 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.yellow : Colors.black45,
              ),
              alignment: Alignment.center,
              child: Text(
                zoom == zoom.roundToDouble() ? '${zoom.toInt()}x' : '${zoom}x',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSelected ? 13 : 11,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
