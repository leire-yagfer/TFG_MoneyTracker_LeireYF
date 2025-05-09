import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:proyecto2eva_budget/model/models/categoria.dart';
import 'package:proyecto2eva_budget/model/models/usuario.dart';
import 'package:proyecto2eva_budget/model/services/firebasedb.dart';

///Clase que gestiona las categorías en la base de datos
class CategoriaDao {
  CollectionReference data = Firebasedb.data;

  ///Obtener todas las categorías
  Future<List<Categoria>> obtenerCategorias(Usuario usuario) async {
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userdoc = await data.doc(usuario.id).get();

    //2. coger categ asignadas a ese usuario
    var categoriasCollection =
        await userdoc.reference.collection("categories").get();

    //3. guardar todos los datos
    List<Categoria> categoriasUser = [];

    for (var categoria in categoriasCollection.docs) {
      //saco los datos de categoria
      var datosCategoria = categoria.data();
      var nombreCategoria = categoria.id;
      categoriasUser.add(Categoria(
          nombre: nombreCategoria,
          icono: datosCategoria["icon"],
          esingreso: datosCategoria["isincome"],
          colorCategoria: Color.fromARGB(255, datosCategoria["cr"],
              datosCategoria["cg"], datosCategoria["cb"])));
    }
    return categoriasUser;
  }

  ///Obtener categoría por tipo
  Future<List<Categoria>> obtenerCategoriasPorTipo(
      Usuario usuario, bool tipo) async {
    //cojo todas las categorias
    List<Categoria> categoriasUser = await obtenerCategorias(usuario);

    //me quedo con aquellas que tengan la booleana en el mismo párametro que "tipo"
    categoriasUser.retainWhere((elemento) => elemento.esingreso == tipo);
    return categoriasUser;
  }

  ///Insertar categoría
  Future<void> insertarCategoria(Usuario usuario, Categoria categoria) async {
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userdoc = await data.doc(usuario.id).get();

    //2. guardar los datos de la categoria
    await userdoc.reference.collection("categories").doc(categoria.nombre).set({
      "icon": categoria.icono,
      "isincome": categoria.esingreso,
      "cr": categoria.colorCategoria.red,
      "cg": categoria.colorCategoria.green,
      "cb": categoria.colorCategoria.blue
    });
  }

  ///Eliminar categoría
  Future<void> eliminarCategoria(Usuario usuario, Categoria categoria) async {
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userdoc = await data.doc(usuario.id).get();

    //2. eliminar la categoria
    await userdoc.reference
        .collection("categories")
        .doc(categoria.nombre)
        .delete();
  }

  ///Insertar varias categorías de primeras al registrarse un usuario
  Future<void> insertarCategoriasRegistro(String uid) async {
    //1. sacar el docuemnto del user --> d eun usuario en concreto pq se lo paso por parametro
    var userdoc = await data.doc(uid).get();

    //2. guardar los datos de la categoria
    await userdoc.reference.collection("categories").doc('Housing').set(
        {"icon": "house", "isincome": false, "cr": 232, "cg": 160, "cb": 242});
    await userdoc.reference.collection("categories").doc("Salary").set(
        {"icon": "money", "isincome": true, "cr": 160, "cg": 242, "cb": 233});
  }
}
