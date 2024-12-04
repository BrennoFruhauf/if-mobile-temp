import 'package:cloud_firestore/cloud_firestore.dart';

class MovementModel {
  String? id;
  final String? userId;
  final String movementType;
  final String description;
  final double value;
  final Timestamp date;

  MovementModel({
    this.id,
    this.userId,
    required this.movementType,
    required this.description,
    required this.value,
    required this.date,
  });

  factory MovementModel.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;

    return MovementModel(
      id: snapshot.id,
      userId: data['userId'],
      movementType: data['movementType'],
      description: data['description'],
      value: data['value'],
      date: data['date'],
    );
  }

  factory MovementModel.fromJson(Map<String, dynamic> json) {
    try {
      return MovementModel(
        id: json['id'],
        userId: json['userId'],
        movementType: json['movementType'],
        description: json['description'],
        value: json['value'],
        date: json['date'],
      );
    } catch (e) {
      throw Exception(e);
    }
  }
}
