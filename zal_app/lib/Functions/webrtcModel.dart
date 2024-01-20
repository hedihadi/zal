import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:zal/Screens/HomeScreen/Providers/webrtc_provider.dart';

class WebrtcModel {
  final connectionConfiguration = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
    ]
  };

  final offerAnswerConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };
  WebrtcModel(this.ref);
  RTCDataChannel? _dataChannel;
  RTCPeerConnection? connection;
  RTCSessionDescription? _sdp;
  StateNotifierProviderRef<Object?, Object?> ref;

  Future<void> offerConnection() async {
    connection = await _createPeerConnection();
    connection?.onConnectionState = (state) {
      print(state);
      ref.read(webrtcProvider.notifier).stateChanged(state);
    };
    await _createDataChannel();
    RTCSessionDescription? offer = await connection?.createOffer(offerAnswerConstraints);
    if (offer != null) await connection?.setLocalDescription(offer);
  }

  Future<void> answerConnection(RTCSessionDescription offer) async {
    connection = await _createPeerConnection();

    await connection?.setRemoteDescription(offer);

    final answer = await connection?.createAnswer(offerAnswerConstraints);
    _sdpChanged();
    if (answer != null) await connection?.setLocalDescription(answer);
  }

  Future<void> acceptAnswer(RTCSessionDescription answer) async {
    try {
      await connection?.setRemoteDescription(answer);
    } catch (c) {}
  }

  Future<void> sendMessage(String message) async {
    await _dataChannel?.send(RTCDataChannelMessage(message));
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final con = await createPeerConnection(connectionConfiguration);
    con.onIceCandidate = (candidate) {
      _sdpChanged();
    };
    con.onDataChannel = (channel) {
      _addDataChannel(channel);
    };
    return con;
  }

  void _sdpChanged() async {
    _sdp = await connection?.getLocalDescription();
    ref.read(webrtcProvider.notifier).sdpChanged(_sdp);
  }

  Future<void> _createDataChannel() async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel? channel = await connection?.createDataChannel("textchat-chan", dataChannelDict);
    if (channel != null) _addDataChannel(channel);
  }

  void _addDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;
    _dataChannel?.onMessage = (data) {
      ref.read(webrtcProvider.notifier).messageReceived(data);
    };
    _dataChannel?.onDataChannelState = (state) {
      //ref.read(webrtcProvider.notifier).stateChanged(state);
    };
  }
}
