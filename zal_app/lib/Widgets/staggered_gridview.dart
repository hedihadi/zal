import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/utils.dart';

class StaggeredGridview extends ConsumerWidget {
  const StaggeredGridview({super.key, required this.children});
  final List<Widget?> children;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> evenIndexes = [];
    List<Widget> oddIndexes = [];
    final List<Widget> filteredChildren = List<Widget>.from(children.where((element) => element != null).toList());

    for (int i = 0; i < filteredChildren.length; i++) {
      if (i % 2 == 0) {
        evenIndexes.add(filteredChildren[i]);
      } else {
        oddIndexes.add(filteredChildren[i]);
      }
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //left side
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: evenIndexes,
          ),
        ),
        //right side
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: oddIndexes,
          ),
        ),
      ],
    );
  }

  Color getTemperatureColor(double temperature) {
    // List of colors from blue to red
    List<Color> colors = [
      HexColor("#00BBFF"),
      HexColor("#87DFFF"),
      HexColor("#FFF94C"),
      HexColor("#FFCB5C"),
      HexColor("#FA852B"),
      HexColor("#FF3838"),
    ];
    final t = temperature;
    if (1 <= t && t <= 10) {
      return colors[0];
    } else if (10 <= t && t <= 30) {
      return colors[1];
    } else if (30 <= t && t <= 50) {
      return colors[2];
    } else if (50 <= t && t <= 60) {
      return colors[3];
    } else if (60 <= t && t <= 80) {
      return colors[4];
    } else if (80 <= t && t <= 1000) {
      return colors[5];
    } else {
      throw Exception("WHAT?");
    }
  }
}
