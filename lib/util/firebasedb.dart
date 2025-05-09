import 'package:cloud_firestore/cloud_firestore.dart';

class Firebasedb {
  static CollectionReference data = FirebaseFirestore.instance.collection("users"); //referencia a toda la base de datos
}