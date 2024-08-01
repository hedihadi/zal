import 'dart:async';
import 'dart:convert';

import 'package:color_print/color_print.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:zal/Functions/models.dart';
import 'package:zal/Functions/utils.dart';
import 'package:zal/Functions/webrtcModel.dart';
import 'package:zal/Screens/HomeScreen/Providers/home_screen_providers.dart';

class WebRtcNotifier extends StateNotifier<WebrtcProviderModel> {
  ///this list keeps track of all the offers, we send offers one by one to PC until one of the offers manage to work.
  List<RTCSessionDescription> sdpOffers = [];
  DateTime lastWait = DateTime.now();
  bool isWaitingForOfferResponse = false;
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
  }

  ///this function will be called from the PC, when the PC fails to connect with the offer we sent, we'll send another offer.
  offerFailed() {
    if (sdpOffers.isEmpty) {
      initiateConnection();
      return;
    }
    final sdp = sdpOffers.first;
    sdpOffers.removeAt(0);
    _sendSdpToPc(sdp);
    isWaitingForOfferResponse = true;
  }

  sdpChanged(RTCSessionDescription? sdp) {
    if (sdp == null) return;
    if (sdp.type == 'offer') {
      logWarning("$isWaitingForOfferResponse");
      if (isWaitingForOfferResponse == false || (DateTime.now().millisecondsSinceEpoch - lastWait.millisecondsSinceEpoch) > 2000) {
        _sendSdpToPc(sdp);
        lastWait = DateTime.now();
        isWaitingForOfferResponse = true;
      } else {
        sdpOffers.add(sdp);
      }
    }
  }

  _sendSdpToPc(RTCSessionDescription sdp) {
    ref.read(socketObjectProvider)?.socket.emit('offer_sdp', sdp.toMap());
    logWarning("sent");
  }

  ///this function will be called from the PC, when the PC receives offer and creates and answer message,
  ///it sends the answerMessage, which then we accept it.
  acceptAnswer(Map<String, dynamic> data) {
    RTCSessionDescription offer = RTCSessionDescription(
      data["sdp"],
      data["type"].toString(),
    );
    try {
      webrtc.acceptAnswer(offer);
    } catch (c) {
      Logger().w("error accepting answer");
    }
  }

  stateChanged(RTCPeerConnectionState channelState) {
    if (channelState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      state = WebrtcProviderModel(isConnected: true);
      isWaitingForOfferResponse = false;
      logError('reset');
    } else if (channelState == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
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
    if (ref.read(localSocketObjectProvider)?.socket.connected ?? false) {
      ref.read(localSocketObjectProvider.notifier).state?.socket.emit('message', compressedData);
    }
    try {
      webrtc.sendMessage(compressedData);
    } catch (c) {}
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
