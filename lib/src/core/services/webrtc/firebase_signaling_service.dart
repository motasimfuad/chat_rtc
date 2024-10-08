import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreSignalingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrGetConnection(
    String roomId,
    String user1Email,
    String user2Email,
  ) async {
    String connectionId1 = '${user1Email}_$user2Email'.replaceAll('.', '_');
    String connectionId2 = '${user2Email}_$user1Email'.replaceAll('.', '_');

    DocumentSnapshot doc1 = await getConnectionDocument(roomId, connectionId1);
    if (doc1.exists) {
      return connectionId1;
    }

    DocumentSnapshot doc2 = await getConnectionDocument(roomId, connectionId2);
    if (doc2.exists) {
      return connectionId2;
    }

    final docRef = await _docRef(roomId, connectionId1);
    await docRef.set({
      'initiator': user1Email,
      'receiver': user2Email,
      'offer': null,
      'answer': null,
      'iceCandidates': {},
    });

    return connectionId1;
  }

  Future<void> setOffer(
    String roomId,
    String connectionId,
    Map<String, dynamic> offer,
  ) async {
    final docRef = await _docRef(
      roomId,
      connectionId,
    );
    await docRef.update({
      'offer': offer,
    });
  }

  Future<void> setAnswer(
    String roomId,
    String connectionId,
    Map<String, dynamic> answer,
  ) async {
    final docRef = await _docRef(
      roomId,
      connectionId,
    );
    await docRef.update({
      'answer': answer,
    });
  }

  Future<void> addIceCandidate(
    String roomId,
    String connectionId,
    Map<String, dynamic> candidate,
  ) async {
    final docRef = await _docRef(
      roomId,
      connectionId,
    );
    await docRef.update({
      'iceCandidates.${candidate['sdpMid']}_${candidate['sdpMLineIndex']}':
          candidate,
    });
  }

  Future<Stream<DocumentSnapshot<Object?>>> listenToConnection(
    String roomId,
    String connectionId,
  ) async {
    final docRef = await _docRef(
      roomId,
      connectionId,
    );
    return docRef.snapshots();
  }

  Future<DocumentSnapshot> getConnectionDocument(
    String roomId,
    String connectionId,
  ) async {
    final docRef = await _docRef(
      roomId,
      connectionId,
    );
    return await docRef.get();
  }

  Future<DocumentReference> _docRef(
    String roomId,
    String connectionId,
  ) async {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('connections')
        .doc(connectionId);
  }
}
