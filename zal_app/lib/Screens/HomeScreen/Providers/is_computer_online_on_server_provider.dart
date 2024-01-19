import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Screens/HomeScreen/Providers/home_screen_providers.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';

///if this is true, it means that the computer is connected to the socketio server.
final isComputerOnlineOnServerProvider = FutureProvider<bool>((ref) async {
  final streamData = await ref.watch(_roomClientsProvider.future);
  if (List<int>.from(streamData.data).contains(0) == false) {
    return false;
  }
  ref.read(webrtcProvider.notifier).initiateConnection();
  return true;
});

final _roomClientsProvider = FutureProvider<StreamData>((ref) {
  final sub = ref.listen(computerSocketStreamProvider, (prev, cur) {
    if (cur.value?.type == StreamDataType.RoomClients) ref.state = cur;
  });
  ref.onDispose(() => sub.close());
  return ref.future;
});
