import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:zal/Screens/HomeScreen/providers/log_list_provider.dart';
import 'package:zal/Screens/HomeScreen/providers/webrtc_provider.dart';

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
  RTCDataChannel? dataChannel;
  RTCPeerConnection? connection;
  RTCSessionDescription? _sdp;
  StateNotifierProviderRef<Object?, Object?> ref;

  Future<void> offerConnection() async {
    connection = await _createPeerConnection();
    await _createDataChannel();
    RTCSessionDescription? offer = await connection?.createOffer(offerAnswerConstraints);
    if (offer != null) await connection?.setLocalDescription(offer);
  }

  Future<void> answerConnection(RTCSessionDescription offer) async {
    connection = await _createPeerConnection();
    if (connection != null) {
      connection!.onConnectionState = ((state) {
        ref.read(logListProvider.notifier).addElement("connectionstate ${state.name}");
        ref.read(webrtcProvider.notifier).stateChanged(state);
      });
    }
    await connection?.setRemoteDescription(offer);
    final answer = await connection?.createAnswer(offerAnswerConstraints);
    _sdpChanged();
    if (answer != null) await connection?.setLocalDescription(answer);
  }

  Future<void> acceptAnswer(RTCSessionDescription answer) async {
    await connection?.setRemoteDescription(answer);
  }

  Future<void> sendMessage(String message) async {
    await dataChannel?.send(RTCDataChannelMessage(message));
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
    try {
      _sdp = await connection?.getLocalDescription();
      ref.read(webrtcProvider.notifier).sdpChanged(_sdp);
    } catch (c) {}
  }

  Future<void> _createDataChannel() async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit()
      ..maxRetransmits = 1000
      ..maxRetransmitTime = 100
      ..ordered = true;
    RTCDataChannel? channel = await connection?.createDataChannel("textchat-chan", dataChannelDict);
    if (channel != null) _addDataChannel(channel);
  }

  void _addDataChannel(RTCDataChannel channel) {
    dataChannel = channel;
    dataChannel?.onMessage = (data) {
      ref.read(webrtcProvider.notifier).messageReceived(data);
    };
    dataChannel?.onDataChannelState = (state) {
      ref.read(logListProvider.notifier).addElement("datachannelstate ${state.name}");
      //ref.read(webrtcProvider.notifier).stateChanged(state);
    };
  }
}
