import 'package:color_print/color_print.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';

final informationTextProvider = FutureProvider<SocketData>((ref) {
  final sub = ref.listen(socketStreamProvider, (prev, cur) {
    if (cur.valueOrNull?.type == SocketDataType.informationText) {
      final context = ref.read(contextProvider)!;
      logInfo(cur.valueOrNull?.data);
      showSnackbar(cur.valueOrNull!.data, context);
    }
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});
