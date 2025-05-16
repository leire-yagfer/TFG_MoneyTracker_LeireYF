import 'package:cloud_firestore/cloud_firestore.dart';

//Clase que contiene la referencia a la base de datos, indicando el nombre de la primera colección
class Firebasedb {
  static CollectionReference data = FirebaseFirestore.instance.collection("users");
}