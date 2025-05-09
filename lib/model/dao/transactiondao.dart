import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto2eva_budget/model/models/categoria.dart';
import 'package:proyecto2eva_budget/model/models/transaccion.dart';
import 'package:proyecto2eva_budget/model/models/usuario.dart';
import 'package:proyecto2eva_budget/model/services/firebasedb.dart';

///Clase que gestiona transacciones en la base de datos
class TransaccionDao {
  CollectionReference data = Firebasedb.data;

  ///Método para insertar una transacción
  Future<void> insertarTransaccion(Usuario u, Transaccion t) async {
    //sacar el usuario pasado por param
    var userRef = await data.doc(u.id);

    //recojo la categoría que tiene asignada la transacción t pasada por parametro --> si no hay la crea
    var categoryRef = userRef.collection("categories").doc(t.categoria.nombre);

    //añadiendo la transaccion a la colección de transacciones, de la categoría a la que pertence, del usuario
    await categoryRef.collection("transactions").add(
        t.toMap()); //el id no se pasa porque se autogenera solo en firebase
  }

  ///Consulta para obtener ingresos/gastos por categoría
  Future<Map<Categoria, List<Transaccion>>> obtenerIngresosGastosPorCategoria({
    String filter = 'all',
    String? year,
    required Usuario u,
    required String actualCode,
    required bool isIncome,
  }) async {
    //lista de cada categoría con sus transacciones
    Map<Categoria, List<Transaccion>> mapaCategories = {};

    //acceder a las categorías del usuario
    var userRef = await data.doc(u.id).collection("categories").get();
    //recorrer cada categoría
    for (var c in userRef.docs) {
      Map<String, dynamic> cat = c.data(); //cat --> datos categoria
      cat['id'] = c.id;
      Categoria categoria = Categoria.fromMap(
          cat); //crear objeto categoria en funcion del valor obtenido
      //acceder a las transacciones de la categoría por la que se llega recorriendo
      var transactionsInCategory =
          await c.reference.collection('transactions').get();
      //creo lista de transacciones que va a pertenecer a una categoria concreta
      List<Transaccion> transacciones = [];
      //recorrer cada transacción
      for (var t in transactionsInCategory.docs) {
        Map<String, dynamic> transdata = t.data();
        transdata['id'] = t.id;
        Transaccion transaccion = Transaccion.fromMap(transdata);
        //añadir la transacción a la lista
        transacciones.add(transaccion);
      }
      //añadir la categoría y sus transacciones a la lista
      mapaCategories[categoria] = transacciones;
    }
    //filtrar por ingreso
    mapaCategories.removeWhere((key, _) => !(key.esingreso == isIncome));
    //filtrar por año
    if (filter == 'year' && year != null) {
      mapaCategories.forEach((key, value) {
        value.removeWhere(
            (transaccion) => transaccion.fecha.year.toString() != year);
      });
    }
    return mapaCategories;
  }

  ///Consulta para obtener el balance de los movimientos
  Future<double> obtenerTotalPorTipo({
    required Usuario u,
    required bool isIncome,
    String filter = 'all',
    String? year,
  }) async {
    //lista de cada categoría con sus transacciones
    double total = 0;

    //acceder a las categorías del usuario
    var userRef = await data.doc(u.id).collection("categories").get();
    //recorrer cada categoría
    for (var c in userRef.docs) {
      if (c.data()['isincome'] != isIncome)
        continue; //si no es el tipo de transacción que busco, continuar
      //acceder a las transacciones de la categoría por la que se llega recorriendo
      var transactionsInCategory =
          await c.reference.collection('transactions').get();
      //creo lista de transacciones que va a pertenecer a una categoria concreta
      //recorrer cada transacción
      for (var t in transactionsInCategory.docs) {
        Map<String, dynamic> transdata = t.data();
        if (filter == 'year' && year != null) {
          if(transdata['datetime'].year.toString() == year) {
            total += transdata['import'];
          }
        }else{
          total+=transdata['import'];
        }
      }
    }
    return total;
  }
}
