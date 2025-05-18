import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/model/models/user.dart';
import 'package:tfg_monetracker_leireyafer/model/models/transaction.dart';
import 'package:tfg_monetracker_leireyafer/model/util/changecurrencyapi.dart';
import 'package:tfg_monetracker_leireyafer/model/util/firebasedb.dart';

/* ---------------------------------------------------------- */
//Explicación de lo que he hecho
// He creado al final un método que, en función de la moneda actual, convierto las transacciones a la moneda actual
// Se llama a esa función desde todas las demás funciones
// En la del total, simplemente lo he re creado para sacar el total de todas las monedas.
// Dará un par de errores en el código, por lo que en todos esos lados tienes que añadir actualCurrency : context.read<ConfigurationProvider>().actualCurrency.currencyCode
/* ---------------------------------------------------------- */

///Clase que gestiona transacciones en la base de datos
class TransactionDao {
  CollectionReference data = Firebasedb.data;

  ///Método para insertar una transacción
  Future<void> insertTransaction(UserModel u, TransactionModel t) async {
    //sacar el usuario pasado por param
    var userRef = await data.doc(u.userId);

    //recojo la categoría que tiene asignada la transacción t pasada por parametro --> si no hay la crea
    var categoryRef = userRef
        .collection("categories")
        .doc(t.transactionCategory.categoryName);

    //añado la transaccion a la colección de transacciones, de la categoría a la que pertence, del usuario
    await categoryRef.collection("transactions").add(
        t.toMap()); //el id no se pasa porque se autogenera solo en firebase
  }

  ///Obtener las transacciones ordenadas por fecha de un usuario
  Future<List<TransactionModel>> getTransactionsByDate(UserModel u,
      String primaryCurrencyCode, String secondaryCurrencyCode) async {
    List<TransactionModel> allTransacciones = [];
    var userdata =
        await Firebasedb.data.doc(u.userId).get(); //obtengo el usuario
    var userCategories = await userdata.reference
        .collection('categories')
        .get(); //obtengo las categorías del usuario
    for (var c in userCategories.docs) {
      var transactionsInCategory = await c.reference
          .collection('transactions')
          .orderBy('datetime',
              descending:
                  true) //ordenar por fecha en cada categoría en FireBase --> se ve más ordenado en la BD
          .get();
      for (var t in transactionsInCategory.docs) {
        var transactionPonter = t.data();
        transactionPonter["id"] = t.id; //añadir id de la transacción
        transactionPonter["categoria"] =
            c.data(); //añadir datos de la categoría
        transactionPonter["categoria"]["id"] = c.id; //añadir id de la categoría

        allTransacciones.add(TransactionModel.fromMap(transactionPonter));
      }
    }
    //ordenar todas las transacciones globalmente por fecha (de más reciente a más antigua) a la hora de la representación en la interfaz
    allTransacciones
        .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    allTransacciones = await getTransactionsOnCurrency(
        allTransacciones, primaryCurrencyCode, secondaryCurrencyCode);
    return allTransacciones;
  }

  //por si necesito recurrir a este metódo para ordenar por fecha y sin separar por categorias
  /*
  Future<List<Transaccion>> getTransactionsByDate(Usuario u) async {
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
  Future<void> deleteTransaction(UserModel u, TransactionModel t) async {
    var userRef = await Firebasedb.data.doc(u.userId);
    var categoryRef = userRef
        .collection("categories")
        .doc(t.transactionCategory.categoryName);
    var transaccionRef = categoryRef
        .collection("transactions")
        .doc(t.transactionId); //ID de la transacción
    await transaccionRef.delete(); //eliminar la transacción
  }

  ///Consulta para obtener ingresos/gastos por categoría
  Future<Map<Category, List<TransactionModel>>> getIncomeExpensesByCategory({
    String filter = 'all',
    String? year,
    required UserModel u,
    required String primaryCurrencyCode,
    required String secondaryCurrencyCode,
    required bool isIncome,
  }) async {
    //lista de cada categoría con sus transacciones
    Map<Category, List<TransactionModel>> mapaCategoriesWithTransactions = {};

    //acceder a las categorías del usuario
    var userRef = await data.doc(u.userId).collection("categories").get();
    //recorrer cada categoría
    for (var c in userRef.docs) {
      Map<String, dynamic> cat = c.data(); //cat --> datos categoria
      cat['id'] = c.id;
      Category categoria = Category.fromMap(
          cat); //crear objeto categoria en funcion del valor obtenido
      //acceder a las transacciones de la categoría por la que se llega recorriendo
      var transactionsInCategory =
          await c.reference.collection('transactions').get();
      //creo lista de transacciones que va a pertenecer a una categoria concreta
      List<TransactionModel> transacciones = [];
      //recorrer cada transacción
      for (var t in transactionsInCategory.docs) {
        Map<String, dynamic> transdata = t.data();
        transdata['id'] = t.id; //guardarlo en el mapa de transacciones
        transdata['categoria'] =
            cat; //guardarlo en el mapa y poder cargar todas sus transacciones
        TransactionModel transaccion = TransactionModel.fromMap(transdata);
        //añadir la transacción a la lista
        transacciones.add(transaccion);
      }
      transacciones = await getTransactionsOnCurrency(
          transacciones, primaryCurrencyCode, secondaryCurrencyCode);
      //añadir la categoría y sus transacciones a la lista
      mapaCategoriesWithTransactions[categoria] = transacciones;
    }
    //filtrar por tipo
    mapaCategoriesWithTransactions
        .removeWhere((key, _) => !(key.categoryIsIncome == isIncome));
    //filtrar por año
    if (filter == 'year' && year != null) {
      mapaCategoriesWithTransactions.forEach((key, value) {
        value.removeWhere((transaccion) =>
            transaccion.transactionDate.year.toString() != year);
      });
    }
    return mapaCategoriesWithTransactions;
  }

  ///Consulta para obtener el balance de los movimientos
  Future<double> getTotalByType(
      {required UserModel u,
      required bool isIncome,
      String filter = 'all',
      String? year,
      required String actualCurrency}) async {
    //lista de cada categoría con sus transacciones
    double total = 0;

    //acceder a las categorías del usuario
    var userRef = await data.doc(u.userId).collection("categories").get();
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
          if (transdata['datetime'].year.toString() == year) {
            if (transdata['currency'] != actualCurrency) {
              total = total += (transdata['import'] *
                  (await APIUtils.getChangesBasedOnCurrencyCode(
                      transdata['currency']!))[actualCurrency]);
            } else {
              total += transdata['import'];
            }
          }
        } else {
          if (transdata['currency'] != actualCurrency) {
            total = total += (transdata['import'] *
                (await APIUtils.getChangesBasedOnCurrencyCode(
                    transdata['currency']!))[actualCurrency]);
          } else {
            total += transdata['import'];
          }
        }
      }
    }
    return total;
  }

  ///Función para convertir la divisa de todas las transacciones a la moneda actual
  Future<List<TransactionModel>> getTransactionsOnCurrency(
      List<TransactionModel> transactions,
      String primaryCurrency,
      String secondaryCurrency) async {
    for (TransactionModel transaction in transactions) {
      if (transaction.transactionCurrency.currencyCode != primaryCurrency) {
        transaction.transactionImport *=
            (await APIUtils.getChangesBasedOnCurrencyCode(transaction
                .transactionCurrency.currencyCode))[primaryCurrency]!;
      }
      // Agregar la conversión para la moneda secundaria
      if (transaction.transactionSecondCurrency != null) {
        transaction.transactionSecondImport *=
            (await APIUtils.getChangesBasedOnCurrencyCode(transaction
                .transactionSecondCurrency.currencyCode))[secondaryCurrency]!;
      }
    }
    return transactions;
  }
}
