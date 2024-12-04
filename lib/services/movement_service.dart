import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laura/constants/collections.dart';

import '../models/movement_model.dart';

class MovementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> add(MovementModel movementModel) async {
    final movementData = {
      'userId': movementModel.userId,
      'movementType': movementModel.movementType,
      'description': movementModel.description,
      'value': movementModel.value,
      'date': movementModel.date,
    };

    await _db.collection(Collections.movements).add(movementData);
  }

  Future<void> delete(String id) async {
    await _db.collection(Collections.movements).doc(id).delete();
  }

  Future<void> update(String id, MovementModel updatedMovement) async {
    await _db.collection(Collections.movements).doc(id).update({
      'description': updatedMovement.description,
      'value': updatedMovement.value,
      'movementType': updatedMovement.movementType,
      'date': updatedMovement.date,
    });
  }

  Stream<List<MovementModel>> getMovements(String userId) {
    return _db
        .collection(Collections.movements)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MovementModel.fromFirebase(doc))
            .toList());
  }
}
