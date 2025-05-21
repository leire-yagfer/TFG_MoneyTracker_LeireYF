import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/model/util/firebasedb.dart';

///Clase que gestiona las categorías en la base de datos
class CategoryDao {
  CollectionReference data = Firebasedb.data;

  ///Obtener todas las categorías de la BD
  Future<List<Category>> getCategories(UserModel usuario) async {
    //1. sacar el docuemnto del user --> de un usuario en concreto pq se lo paso por parametro
    var userRef = await data.doc(usuario.userId).get();

    //2. coger categ asignadas a ese usuario
    var userCategories = await userRef.reference.collection("categories").get();

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
    userCategoriesList.sort(
      (a, b) =>
          a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase()),
    );
    return userCategoriesList;
  }

  ///Obtener categoría por tipo para mostrarla en el dropDownButton de añadir ingreso/gasto y en la página de categorías
  Future<List<Category>> getCategoriesByType(UserModel u, bool type) async {
    //cojo todas las categorias
    List<Category> userCategories = await getCategories(u);

    //me quedo con aquellas que tengan la booleana en el mismo párametro que "tipo"
    userCategories.retainWhere((uc) => uc.categoryIsIncome == type);

    //ordeno alfabéticamente por nombre de categoría
    userCategories.sort(
      (a, b) =>
          a.categoryName.toLowerCase().compareTo(b.categoryName.toLowerCase()),
    );
    for (var c in userCategories) {
      print('"${c.categoryName}"');
    }

    return userCategories;
  }

  ///Insertar categoría
  Future<void> insertCategory(UserModel u, Category c) async {
    //sacar el usuario pasado por param
    var userRef = await data.doc(u.userId);

    //añado la categoría a la colección
    await userRef.collection("categories").doc(c.categoryName).set(c
        .toMap()); //creo el documento con el nombre de la categoría (doc(c.categoryName)) y le meto los datos propios (.set(c.toMap()))
  }

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
  Future<void> categoriesInRegistration(String uid) async {
    //le paso el uid del usuario proporcionaod por firebase que se genera al registrarse
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userRef = await data.doc(uid).get();

    //2. guardar los datos de la categoria
    //Gasto
    await userRef.reference
        .collection("categories")
        .doc('Personal')
        .set({"isincome": false, "cr": 240, "cg": 200, "cb": 195});
    //Ingreso
    await userRef.reference
        .collection("categories")
        .doc("General")
        .set({"isincome": true, "cr": 255, "cg": 221, "cb": 204});
  }

  //Actualizar categoría
  Future<void> updateCategory({
    required UserModel u,
    required Category oldCategory,
    required Category newCategory,
  }) async {
    final firestore = FirebaseFirestore.instance;

    final categoriesCollection =
        firestore.collection('users').doc(u.userId).collection('categories');

    final oldCategoryDoc = categoriesCollection.doc(oldCategory.categoryName);
    final newCategoryDoc = categoriesCollection.doc(newCategory.categoryName);

    //Compruebo si se ha cambiado el nombre
    if (oldCategory.categoryName == newCategory.categoryName) {
      //si se ha cambiado solo el nombre, unicamnete se actualizan los datos (color, ingreso/gasto, evito errores aunque eso no lo pueda cambair) de la categoría existente
      await oldCategoryDoc.update({
        'isincome': newCategory.categoryIsIncome, //evito errores
        'cr': newCategory.categoryColor.red,
        'cg': newCategory.categoryColor.green,
        'cb': newCategory.categoryColor.blue,
      });
    } else {
      /*crear nueva categoría --> porque FireBase no permite cambiar el nombre de un documento directamente, así que creo una nueva con el nombre actualizado y copio las transacciones para mantener la estructura*/
      await newCategoryDoc.set({
        'isincome': newCategory.categoryIsIncome, //evito errores
        'cr': newCategory.categoryColor.red,
        'cg': newCategory.categoryColor.green,
        'cb': newCategory.categoryColor.blue,
      });

      //Mover transacciones de la categoría antigua a la nueva --> esto se debe a que cada transacción tiene un id y está almacenada dentro de la subcolección de una categoría concreta, por lo que no se puede simplemente cambiar el nombre de la categoría, hay que copiarla manualmente a la nueva subcolección con el nuevo nombre de documento
      var oldTransactionsSnapshot =
          await oldCategoryDoc.collection('transactions').get();

      //Por cada transacción, copiarla a la nueva categoría
      for (var transactionDoc in oldTransactionsSnapshot.docs) {
        var transactionData = transactionDoc.data();
        await newCategoryDoc
            .collection('transactions')
            .doc(transactionDoc.id)
            .set(transactionData);
        await oldCategoryDoc
            .collection('transactions')
            .doc(transactionDoc.id)
            .delete();
      }

      // Borrar la categoría antigua
      await oldCategoryDoc.delete();
    }
  }
}
