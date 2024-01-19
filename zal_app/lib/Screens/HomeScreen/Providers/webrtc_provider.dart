import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Functions/webrtcModel.dart';
import 'package:zal/Screens/HomeScreen/Providers/home_screen_providers.dart';

class WebRtcNotifier extends StateNotifier<WebrtcProviderModel> {
  StateNotifierProviderRef<Object?, Object?> ref;
  late WebrtcModel webrtc;
  WebRtcNotifier(this.ref) : super(WebrtcProviderModel(isConnected: false)) {
    webrtc = WebrtcModel(ref);
  }
  StreamController dataStream = StreamController();
  RTCDataChannel? dataChannel;
  RTCPeerConnection? connection;
  RTCSessionDescription? sdp;

  initiateConnection() {
    webrtc.offerConnection();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (state.isConnected == false) {
        webrtc.offerConnection();
      }
    });
  }

  sdpChanged(RTCSessionDescription? sdp) {
    if (sdp == null) return;
    if (sdp.type == 'offer') {
      ref.read(socketObjectProvider)?.socket.emit('offer_sdp', sdp.toMap());
    }
  }

  acceptAnswer(Map<String, dynamic> data) {
    RTCSessionDescription offer = RTCSessionDescription(
      data["sdp"],
      data["type"],
    );
    try {
      webrtc.acceptAnswer(offer);
    } catch (c) {
      Logger().w("error accepting answer");
    }
  }

  stateChanged(RTCDataChannelState channelState) {
    if (channelState == RTCDataChannelState.RTCDataChannelOpen) {
      state = WebrtcProviderModel(isConnected: true);
    } else {
      state = WebrtcProviderModel(isConnected: false);
    }
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

  messageReceived(RTCDataChannelMessage data) {
    final parsedData = jsonDecode(data.text);
    final messageName = parsedData['name'];
    final messageData = parsedData['data'];

    state = WebrtcProviderModel(
      isConnected: state.isConnected,
      data: WebrtcData(
        data: messageData,
        type: convertStringToWebrtcDataType(
          messageName,
        ),
      ),
    );
  }
}

final webrtcProvider = StateNotifierProvider<WebRtcNotifier, WebrtcProviderModel>((ref) => WebRtcNotifier(ref));
