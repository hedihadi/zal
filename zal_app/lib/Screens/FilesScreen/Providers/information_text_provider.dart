import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';

final informationTextProvider = FutureProvider<WebrtcProviderModel>((ref) {
  final sub = ref.listen(webrtcProvider, (prev, cur) {
    if (cur.data?.type == WebrtcDataType.informationText) {
      final context = ref.read(contextProvider)!;
      showSnackbar(cur.data!.data, context);
    }
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});
