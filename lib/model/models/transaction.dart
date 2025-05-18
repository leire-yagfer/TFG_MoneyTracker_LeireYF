import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg_monetracker_leireyafer/model/models/category.dart';
import 'package:tfg_monetracker_leireyafer/model/models/currency.dart';
import 'package:tfg_monetracker_leireyafer/model/util/changecurrencyapi.dart';

///Clase que representa una transacción. Se llama así porque puedo tener probelmas con el nombre Transaction del propio FireBase
class TransactionModel {
  final String transactionId;
  final String transactionTittle;
  final DateTime transactionDate;
  final Currency transactionCurrency;
  final Currency transactionSecondCurrency;
  final Category transactionCategory;
  double transactionImport;
  double transactionSecondImport;
  final String? transactionDescription;
  //No se necesita el usuario porque está en el provider y todo lo que se haga se guarda en su sesión

  TransactionModel({
    required this.transactionId,
    required this.transactionTittle,
    required this.transactionDate,
    required this.transactionCurrency,
    required this.transactionSecondCurrency,
    required this.transactionCategory,
    required this.transactionImport,
    required this.transactionSecondImport,
    this.transactionDescription,
  });

  //a aprtir de un mapa creo una transacción
  static TransactionModel fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      transactionId: map['id'],
      transactionTittle: map['title'],
      transactionDate: (map['datetime'] as Timestamp)
          .toDate(), //converitr timestamp a DateTime porque en FireBase es TimeStamp
      transactionCurrency: APIUtils.getFromList(map['currency'])!,
      transactionSecondCurrency: APIUtils.getFromList(map['secondcurrency'])!,
      transactionCategory: Category.fromMap(map['categoria']),
      transactionImport: map['import'],
      transactionSecondImport: map['secondimport'],
      transactionDescription: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': transactionCurrency.currencyCode,
      'secondcurrency': transactionSecondCurrency.currencyCode,
      'datetime': Timestamp.fromDate(transactionDate),
      'description': transactionDescription,
      'import': transactionImport,
      'secondimport': transactionSecondImport,
      'title': transactionTittle
    };
  }
}
