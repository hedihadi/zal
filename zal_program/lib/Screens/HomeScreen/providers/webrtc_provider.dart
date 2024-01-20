import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:zal/Functions/Models/models.dart';
import 'package:zal/Functions/webrtcModel.dart';
import 'package:zal/Screens/HomeScreen/providers/log_list_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/server_socket_stream_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/task_manager_provider.dart';
import 'package:zal/Screens/MainScreen/main_screen_providers.dart';
import 'package:zal/Screens/NotificationsScreen/notifications_screen_providers.dart';

import '../../../Functions/utils.dart';

class WebRtcNotifier extends StateNotifier<WebrtcProviderModel> {
  StateNotifierProviderRef<Object?, Object?> ref;
  late WebrtcModel webrtc;
  WebRtcNotifier(this.ref) : super(WebrtcProviderModel(isConnected: false)) {
    webrtc = WebrtcModel(ref);
  }

  sendMessage(
    ///the name of the message, ie. key.
    String name,
    //the data to be sent
    String data,
  ) {
    final compressedData = jsonEncode(
      {
        'name': name,
        'data': data,
      },
    );
    webrtc.sendMessage(compressedData);
  }

  sdpChanged(RTCSessionDescription? sdp) {
    if (sdp == null) return;
    if (sdp.type == 'answer') {
      ref.read(serverSocketObjectProvider).value?.socket.emit('accept_answer', sdp.toMap());
      ref.read(logListProvider.notifier).addElement('sending accept_answer to mobile...');
    }
  }

  answerConnection(Map<String, dynamic> data) async {
    RTCSessionDescription offer = RTCSessionDescription(
      data["sdp"],
      data["type"],
    );
    try {
      await webrtc.answerConnection(offer);
      ref.read(logListProvider.notifier).addElement('received sdp offer from mobile.');
    } catch (c) {
      ref.read(logListProvider.notifier).addElement('error answering sdp connection, informing mobile to send another offer...');
      ref.read(serverSocketObjectProvider).value?.socket.emit('offer_failed', '');
    }
  }

  stateChanged(RTCPeerConnectionState channelState) {
    if (channelState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      state = WebrtcProviderModel(isConnected: true);
      ref.read(notificationsProvider.notifier).broadcastNotificationsToMobile();
      ref.read(logListProvider.notifier).addElement('p2p connection established.');
    } else if (channelState == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
      state = WebrtcProviderModel(isConnected: false);
      ref.read(taskmanagerProvider.notifier).reset();
    }
  }

  messageReceived(RTCDataChannelMessage data) async {
    final parsedData = jsonDecode(data.text);
    final messageName = parsedData['name'];
    final messageData = parsedData['data'];
    ref.read(logListProvider.notifier).addElement("message received, \nname:$messageName\ndata:$messageData");
    state = WebrtcProviderModel(
      isConnected: state.isConnected,
      data: WebrtcData(
        data: messageData,
        type: convertStringToWebrtcDataType(
          messageName,
        ),
      ),
    );

    if (state.data?.type == WebrtcDataType.restartAdmin) {
      ref.read(localSocketObjectProvider)?.socket.emit("restart_admin");
    } else if (state.data?.type == WebrtcDataType.changePrimaryNetwork) {
      final socket = ref.read(localSocketObjectProvider)?.socket;
      socket?.emit("change_primary_network", state.data?.data.toString());
    } else if (state.data?.type == WebrtcDataType.newNotification) {
      ref.read(notificationsProvider.notifier).addNewRawNotification(state.data!.data);
    } else if (state.data?.type == WebrtcDataType.editNotification) {
      ref.read(notificationsProvider.notifier).editNotification(state.data!.data);
    } else if (state.data?.type == WebrtcDataType.killProcess) {
      List<int> processes = List<int>.from(jsonDecode(state.data!.data));
      for (final processId in processes) {
        await Process.run('taskkill', ['/F', '/PID', processId.toString()]);
      }
    }
  }
}

final webrtcProvider = StateNotifierProvider<WebRtcNotifier, WebrtcProviderModel>((ref) => WebRtcNotifier(ref));
