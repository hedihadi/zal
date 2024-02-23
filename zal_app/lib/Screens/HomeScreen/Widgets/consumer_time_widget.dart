import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/consumer_times_provider.dart';
import 'package:zal/Screens/ProgramsTimeScreen/programs_time_provider.dart';
import 'package:zal/Screens/ProgramsTimeScreen/programs_time_screen.dart';
import 'package:zal/Widgets/card_widget.dart';

class ProgramTimesWidget extends ConsumerWidget {
  const ProgramTimesWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayConsumerTime = ref.watch(todayConsumerTimeProvider);
    ref.watch(programIconsProvider);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProgramTimesScreen()));
      },
      child: CardWidget(
        title: "your time",
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Column(
            children: [
              Text(
                convertMinutesToHoursAndMinutes(todayConsumerTime.valueOrNull ?? 0),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
