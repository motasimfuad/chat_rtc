import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/room_model.dart';

class RoomsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Room>> getRooms() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('rooms').orderBy('createdAt').get();
      return snapshot.docs
          .map(
            (doc) => Room.fromMap(
              {'id': doc.id, ...doc.data() as Map<String, dynamic>},
            ),
          )
          .toList();
    } on FirebaseException catch (e) {
      print('Error fetching rooms: $e');
      return [];
    }
  }

  Future<bool> joinRoom(String roomId, String userId) async {
    if (userId.trim().isEmpty) {
      return false;
    }
    try {
      await _firestore.collection('rooms').doc(roomId).update({
        'users': FieldValue.arrayUnion([userId])
      });
      return true;
    } on FirebaseException catch (e) {
      print('Error joining room: $e');
      return false;
    }
  }
}
