import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/model/util/firebasedb.dart';

///Clase que gestiona las categorías en la base de datos
class CategoryDao {
  CollectionReference data = Firebasedb.data;

  ///Obtener todas las categorías
  Future<List<Category>> getCategories(UserModel usuario) async {
    //1. sacar el docuemnto del user --> de un usuario en concreto pq se lo paso por parametro
    var userRef = await data.doc(usuario.userId).get();

    //2. coger categ asignadas a ese usuario
    var userCategories =
        await userRef.reference.collection("categories").get();

    //3. guardar todos los datos
    List<Category> userCategoriesList = [];

    for (var c in userCategories.docs) {
      //saco los datos de categoria
      var categoryData = c.data();
      var categoryName = c.id;
      userCategoriesList.add(Category(
          categoryName: categoryName,
          
          categoryIsIncome: categoryData["isincome"],
          categoryColor: Color.fromARGB(255, categoryData["cr"],
              categoryData["cg"], categoryData["cb"])));
    }
    return userCategoriesList;
  }

  ///Obtener categoría por tipo
  Future<List<Category>> getCategoriesByType(
      UserModel u, bool type) async {
    //cojo todas las categorias
    List<Category> userCategories = await getCategories(u);

    //me quedo con aquellas que tengan la booleana en el mismo párametro que "tipo"
    userCategories.retainWhere((uc) => uc.categoryIsIncome == type);
    return userCategories;
  }

  ///Insertar categoría
  Future<void> insertCategory(UserModel u, Category c) async {
    //sacar el usuario pasado por param
    var userRef = await data.doc(u.userId);

    //añado la categoría a la colección
    await userRef.collection("categories").doc(c.categoryName).set(c.toMap()); //creo el documento con el nombre de la categoría (doc(c.categoryName)) y le meto los datos propios (.set(c.toMap()))
  }
  
  /*
  Future<void> insertarCategoria(UserModel u, Category c) async {
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userRef = await data.doc(u.userId).get();

    //2. guardar los datos de la categoria
    await userRef.reference.collection("categories").doc(c.categoryName).set({
      
      "isincome": c.categoryIsIncome,
      "cr": c.categoryColor.red,
      "cg": c.categoryColor.green,
      "cb": c.categoryColor.blue
    });
  }*/

  ///Eliminar categoría
  Future<void> deleteCategory(UserModel u, Category c) async {
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userRef = await data.doc(u.userId).get();

    //2. eliminar la categoria
    await userRef.reference
        .collection("categories")
        .doc(c.categoryName)
        .delete();
  }

  ///Insertar varias categorías de primeras al registrarse un usuario
  Future<void> insertarCategoriasRegistro(String uid) async { //le paso el uid del usuario proporcionaod por firebase que se genera al registrarse
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userRef = await data.doc(uid).get();

    //2. guardar los datos de la categoria
    await userRef.reference.collection("categories").doc('Housing').set(
        {"isincome": false, "cr": 242, "cg": 153, "cb": 74});
    await userRef.reference.collection("categories").doc("Salary").set(
        {"isincome": true, "cr": 245, "cg": 210, "cb": 85});
  }
}
