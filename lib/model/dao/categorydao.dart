import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/util/firebasedb.dart';

///Clase que gestiona las categorías en la base de datos
class CategoryDao {
  CollectionReference data = Firebasedb.data;

  ///Obtener todas las categorías
  Future<List<Category>> getCategories(UserModel usuario) async {
    //1. sacar el docuemnto del user --> de un usuario en concreto pq se lo paso por parametro
    var userdoc = await data.doc(usuario.userId).get();

    //2. coger categ asignadas a ese usuario
    var userCategories =
        await userdoc.reference.collection("categories").get();

    //3. guardar todos los datos
    List<Category> userCategoriesList = [];

    for (var c in userCategories.docs) {
      //saco los datos de categoria
      var categoryData = c.data();
      var categoryName = c.id;
      userCategoriesList.add(Category(
          categoryName: categoryName,
          categoryIcon: categoryData["icon"],
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
  Future<void> insertarCategoria(UserModel u, Category c) async {
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userdoc = await data.doc(u.userId).get();

    //2. guardar los datos de la categoria
    await userdoc.reference.collection("categories").doc(c.categoryName).set({
      "icon": c.categoryIcon,
      "isincome": c.categoryIsIncome,
      "cr": c.categoryColor.red,
      "cg": c.categoryColor.green,
      "cb": c.categoryColor.blue
    });
  }

  ///Eliminar categoría
  Future<void> eliminarCategoria(UserModel usuario, Category categoria) async {
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userdoc = await data.doc(usuario.userId).get();

    //2. eliminar la categoria
    await userdoc.reference
        .collection("categories")
        .doc(categoria.categoryName)
        .delete();
  }

  ///Insertar varias categorías de primeras al registrarse un usuario
  Future<void> insertarCategoriasRegistro(String uid) async { //le paso el uid del usuario proporcionaod por firebase que se genera al registrarse
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userdoc = await data.doc(uid).get();

    //2. guardar los datos de la categoria
    await userdoc.reference.collection("categories").doc('Housing').set(
        {"icon": "house", "isincome": false, "cr": 232, "cg": 160, "cb": 242});
    await userdoc.reference.collection("categories").doc("Salary").set(
        {"icon": "money", "isincome": true, "cr": 160, "cg": 242, "cb": 233});
  }
}
