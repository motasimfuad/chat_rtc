import 'dart:async';
import 'dart:developer';

import 'package:chat_rtc/src/core/services/webrtc/firebase_signaling_service.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

enum CallState {
  notStarted,
  gettingUserMedia,
  creatingOffer,
  offerCreated,
  waitingForOffer,
  offerReceived,
  answerCreated,
  waitingForAnswer,
  answerReceived,
  waitingForInitiator,
  connected,
  error,
}

class WebRTCService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  final Rx<RTCVideoRenderer> localRenderer = RTCVideoRenderer().obs;
  final Rx<RTCVideoRenderer> remoteRenderer = RTCVideoRenderer().obs;
  String? roomId;
  String? userEmail;
  String? targetUserEmail;
  String? connectionId;
  bool isInitiator = false;
  StreamSubscription? _signalingSubscription;
  Function(MediaStream)? onRemoteStreamAdded;
  CallState connectionState = CallState.notStarted;

  final Rx<CallState> callState = CallState.notStarted.obs;
  final RxMap<String, dynamic> firebaseData = <String, dynamic>{}.obs;

  final FirestoreSignalingService signalingService =
      FirestoreSignalingService();

  Future<void> initialize(
      String roomId, String userEmail, String targetUserEmail) async {
    log('Initializing WebRTC service...');
    this.roomId = roomId;
    this.userEmail = userEmail;
    this.targetUserEmail = targetUserEmail;

    await localRenderer.value.initialize();
    await remoteRenderer.value.initialize();

    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"}
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    peerConnection =
        await createPeerConnection(configuration, offerSdpConstraints);
    if (peerConnection == null) {
      throw Exception('Failed to create peer connection');
    }
    _setupPeerConnectionListeners();

    connectionId = await signalingService.createOrGetConnection(
      roomId,
      userEmail,
      targetUserEmail,
    );
    if (connectionId == null) {
      throw Exception('Failed to create or get connection ID');
    }
    isInitiator =
        await signalingService.isInitiator(roomId, connectionId!, userEmail);

    await _listenForSignalingEvents();

    if (isInitiator) {
      callState.value = CallState.waitingForAnswer;
    } else {
      callState.value = CallState.waitingForOffer;
    }
  }

  void _setupPeerConnectionListeners() {
    log('👂🏼📃 Setting up peer connection listeners...');
    peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
      await signalingService.addIceCandidate(
        roomId!,
        connectionId!,
        candidate.toMap(),
      );
    };

    peerConnection!.onAddStream = (MediaStream stream) {
      log('👂🏼 Remote stream added: ${stream.id}');
      onRemoteStreamAdded?.call(stream);
    };

    peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      log('👂🏼 Connection state changed: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        callState.value = CallState.connected;
      }
    };

    peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      log('👂🏼 ICE Connection state changed: $state');
    };

    peerConnection!.onSignalingState = (RTCSignalingState state) {
      log('👂🏼 Signaling state changed: $state');
    };

    peerConnection!.onTrack = (RTCTrackEvent event) {
      log('onTrack event received');
      if (event.streams.isNotEmpty) {
        remoteRenderer.value.srcObject = event.streams[0];
      }
    };
  }

  Future<void> startCall() async {
    try {
      callState.value = CallState.gettingUserMedia;
      await _getUserMedia();
      await _createPeerConnection();
      _setupPeerConnectionListeners();

      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });

      if (isInitiator) {
        callState.value = CallState.waitingForAnswer;
      } else {
        callState.value = CallState.waitingForOffer;
      }
    } catch (e) {
      log('Error in startCall: $e');
      callState.value = CallState.error;
      rethrow;
    }
  }

  Future<void> _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          'minWidth': '640',
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };

    try {
      localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      localRenderer.value.srcObject = localStream;
    } catch (e) {
      log('🎥 ❌ Error getting user media: $e');
      rethrow;
    }
  }

  Future<void> createAndStoreOffer() async {
    try {
      callState.value = CallState.creatingOffer;
      RTCSessionDescription offer = await peerConnection!.createOffer();
      await peerConnection!.setLocalDescription(offer);
      await signalingService.setOffer(
        roomId!,
        connectionId!,
        offer.toMap(),
      );
      callState.value = CallState.waitingForAnswer;
    } catch (e) {
      log('Error creating and storing offer: $e');
      callState.value = CallState.error;
      rethrow;
    }
  }

  Future<void> handleAnswerCall() async {
    try {
      await startCall();
      await handleStoredOffer();
      await _createAndStoreAnswer();
      await _handleRemoteStream();
    } catch (e) {
      log('Error handling answer call: $e');
      callState.value = CallState.error;
      rethrow;
    }
  }

  Future<void> handleStoredOffer() async {
    try {
      if (firebaseData['offer'] == null) {
        throw Exception('Offer not added in Firebase');
      }
      callState.value = CallState.offerReceived;
      RTCSessionDescription offer = RTCSessionDescription(
        firebaseData['offer']['sdp'],
        firebaseData['offer']['type'],
      );
      await peerConnection!.setRemoteDescription(offer);
    } catch (e) {
      log('Error handling stored offer: $e');
      callState.value = CallState.error;
      rethrow;
    }
  }

  Future<void> _createAndStoreAnswer() async {
    try {
      RTCSessionDescription answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);
      await signalingService.setAnswer(roomId!, connectionId!, answer.toMap());
      callState.value = CallState.answerCreated;
    } catch (e) {
      log('Error creating and storing answer: $e');
      callState.value = CallState.error;
      rethrow;
    }
  }

  Future<void> handleStoredAnswer() async {
    try {
      if (firebaseData['answer'] == null) {
        throw Exception('Answer not added in Firebase');
      }
      callState.value = CallState.answerReceived;
      RTCSessionDescription answer = RTCSessionDescription(
        firebaseData['answer']['sdp'],
        firebaseData['answer']['type'],
      );
      await peerConnection!.setRemoteDescription(answer);
      callState.value = CallState.connected;

      await signalingService.updateConnection(
        roomId!,
        connectionId!,
        {'callStatus': 'connected'},
      );
    } catch (e) {
      log('Error handling stored answer: $e');
      callState.value = CallState.error;
      rethrow;
    }
  }

  Future<void> _handleIceCandidates(Map<String, dynamic> iceCandidates) async {
    for (var entry in iceCandidates.entries) {
      try {
        Map<String, dynamic> iceCandidate = entry.value;
        RTCIceCandidate candidate = RTCIceCandidate(
          iceCandidate['candidate'],
          iceCandidate['sdpMid'],
          iceCandidate['sdpMLineIndex'],
        );
        await peerConnection!.addCandidate(candidate);
      } catch (e) {
        log('🧊 ❌ Error adding ICE candidate: $e');
      }
    }
  }

  Future<void> _listenForSignalingEvents() async {
    _signalingSubscription?.cancel();
    _signalingSubscription = signalingService
        .listenToConnection(roomId!, connectionId!)
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        firebaseData.value = data;

        _handleSignalingData(data);
      }
    });
  }

  Future<void> _handleSignalingData(Map<String, dynamic> data) async {
    if (data['offer'] != null &&
        !isInitiator &&
        callState.value == CallState.waitingForOffer) {
      log('Handling stored offer');
      await handleStoredOffer();
      _handleRemoteStream();
    }
    if (data['answer'] != null &&
        isInitiator &&
        callState.value == CallState.waitingForAnswer) {
      log('Handling stored answer');
      await handleStoredAnswer();
      _handleRemoteStream();
    }
    if (data['iceCandidates'] != null) {
      log('Handling ICE candidates');
      await _handleIceCandidates(data['iceCandidates']);
    }
    if (data['callStatus'] == 'connected' && !isInitiator) {
      callState.value = CallState.connected;
      _handleRemoteStream();
    }
  }

  Future<void> _handleRemoteStream() async {
    peerConnection!.onTrack = (RTCTrackEvent event) {
      log('onTrack event received');
      if (event.streams.isNotEmpty) {
        remoteRenderer.value.srcObject = event.streams[0];
      }
    };
  }

  Future<void> handleRejectCall() async {
    try {
      await signalingService
          .updateConnection(roomId!, connectionId!, {'offer': null});
      callState.value = CallState.notStarted;
    } catch (e) {
      log('Error rejecting call: $e');
      callState.value = CallState.error;
      rethrow;
    }
  }

  Future<void> _createPeerConnection() async {
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };

    try {
      peerConnection =
          await createPeerConnection(configuration, offerSdpConstraints);
      log('Peer connection created');

      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        log('🧊 New ICE candidate: ${candidate.toMap()}');
        signalingService.addIceCandidate(
          roomId!,
          connectionId!,
          candidate.toMap(),
        );
      };

      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });
    } catch (e) {
      log('Error creating peer connection: $e');
      rethrow;
    }
  }

  Future<void> endCall() async {
    await localStream?.dispose();
    await peerConnection?.close();
    await localRenderer.value.dispose();
    await remoteRenderer.value.dispose();
    await _signalingSubscription?.cancel();
    connectionState = CallState.notStarted;
  }

  void dispose() {
    endCall();
    peerConnection?.dispose();
  }
}
