import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  final String name;
  final String email;
  String? password;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.password,
  });

  factory UserModel.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;

    return UserModel(
      id: snapshot.id,
      name: data['name'],
      email: data['email'],
      password: data['password'],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        password: json['password'],
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}
