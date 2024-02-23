import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/FpsScreen/fps_screen_providers.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';

class SelectGpuProcessWidget extends ConsumerWidget {
  const SelectGpuProcessWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpuProcesses = ref.watch(gpuProcessesProvider);
    final selectedGpuProcess = ref.watch(selectedGpuProcessProvider);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          Text(
            "Select your game",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<GpuProcess>(
                  style: Theme.of(context).textTheme.labelMedium,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  value: selectedGpuProcess,
                  onChanged: (GpuProcess? value) {
                    if (value != null) {
                      ref.read(fpsDataProvider.notifier).reset();
                      ref.read(selectedGpuProcessProvider.notifier).state = value;
                      ref.read(webrtcProvider.notifier).sendMessage("start_fps", value.pid.toString());
                      Navigator.of(context).pop();
                    }
                  },
                  items: gpuProcesses.value?.map<DropdownMenuItem<GpuProcess>>((GpuProcess value) {
                    return DropdownMenuItem<GpuProcess>(
                      value: value,
                      child: Row(
                        children: [
                          if ([null, ""].contains(value.icon) == false)
                            Image.memory(
                              base64Decode(value.icon!),
                              gaplessPlayback: true,
                              scale: 1,
                            ),
                          Text(value.name),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              IconButton(
                  onPressed: () {
                    ref.invalidate(selectedGpuProcessProvider);
                    ref.invalidate(gpuProcessesProvider);
                  },
                  icon: gpuProcesses.isLoading ? const CircularProgressIndicator() : const Icon(FontAwesomeIcons.arrowsRotate))
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
