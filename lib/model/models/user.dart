///Clase que representa un usuario. Se llama así porque puedo tener probelmas con el nombre User del propio FireBase
class UserModel {
  final String userId;
  final String userEmail;
  
  //sin contraseña pq ya la guarda el authenticator de FireBase

  UserModel({
    required this.userId,
    required this.userEmail
  });
}