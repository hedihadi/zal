import 'package:flutter/material.dart';

class HorizontalCircleProgressBar extends StatelessWidget {
  final double progress;
  final Color inactiveColor;
  final double dotSize;

  const HorizontalCircleProgressBar({
    super.key,
    required this.progress,
    this.inactiveColor = Colors.grey,
    this.dotSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the maximum number of dots that can fit within the available width
        int totalDots = (constraints.maxWidth / (dotSize * 1.5)).floor();

        // Ensure the totalDots is at least 1
        totalDots = totalDots.clamp(1, totalDots);

        int activeDots = (totalDots * progress).ceil();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalDots, (index) {
            if (index < activeDots) {
              return Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
              );
            } else {
              return Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inactiveColor,
                ),
              );
            }
          }),
        );
      },
    );
  }
}
