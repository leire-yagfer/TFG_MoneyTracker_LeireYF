import 'package:proyecto2eva_budget/model/models/usuario.dart';
import 'package:proyecto2eva_budget/model/services/firebasedb.dart';
import '../transaccion.dart';

///Clase que gestiona las transacciones en la base de datos
class TransaccionCRUD {
  ///Obtener las transacciones ordenadas por fecha 
  

  //Este tiene el orderBy, pero que yo lo hago en el provider con el sort
  Future<List<Transaccion>> obtenerTransaccionesPorFecha(Usuario u) async {
    List<Transaccion> allTransacciones = [];
    var userdata = await Firebasedb.data.doc(u.id).get(); //obtengo el usuario

    var categories = await userdata.reference
        .collection('categories')
        .get(); //obtengo las categorias

    //obtengo las transacciones de cada categoria ordenadas por fecha
    for (var c in categories.docs) {
      var transacciones = await c.reference
          .collection('transactions')
          .orderBy('datetime',
              descending:
                  true) //ordena por fecha, de más reciente a más antiguo
          .get();

      for (var t in transacciones.docs) {
        var transaccion = t.data();
        transaccion["id"] =
            t.id; //le paso el ID de la transacción pq no lo pasa directamente
        transaccion["categoria"] = c
            .data(); //le paso todos los datos que implica la categoria a la que pertenece dicha transacción
        transaccion["categoria"]["id"] = c
            .id; //le paso el ID de la categoria pq no lo pasa directamente --> id = nombre

        allTransacciones.add(Transaccion.fromMap(
            transaccion)); //método transacción que se encarga de crear la transacción a partir del mapa
      }
    }

    return allTransacciones;
  }
  /*
  Future<List<Transaccion>> obtenerTransaccionesPorFecha(Usuario u) async {
    List<Transaccion> allTransacciones = [];
    var userdata = await Firebasedb.data.doc(u.id).get(); //obtengo el usuario

    var categories = await userdata.reference
        .collection('categories')
        .get(); //obtengo las categorias

    //obtengo las transacciones de cada categoria
    for (var c in categories.docs) {
      var transacciones = await c.reference.collection('transactions').get();
      for (var t in transacciones.docs) {
        var transaccion = t.data();
        transaccion["id"] =
            t.id; //le paso el ID de la transacción pq no lo pasa directamente
        transaccion["categoria"] = c
            .data(); //le paso todos los datos que implica la categoria a la que pertenece dicha transacción
        transaccion["categoria"]["id"] =
            c.id; //le paso el ID de la categoria pq no lo pasa directamente --> id = nombre

        allTransacciones.add(Transaccion.fromMap(
            transaccion)); //método transacción que se encarga de crear la transacción a partir del mapa
      }
    }
    return allTransacciones;
  }*/

  ///Eliminar una transacción por ID
  Future<void> eliminarTransaccion(Usuario u, Transaccion t) async {
    var userRef = await Firebasedb.data.doc(u.id);
    var categoryRef = userRef.collection("categories").doc(t.categoria.nombre);
    var transaccionRef =
        categoryRef.collection("transactions").doc(t.id); //ID de la transacción
    await transaccionRef.delete(); //eliminar la transacción
  }
}
