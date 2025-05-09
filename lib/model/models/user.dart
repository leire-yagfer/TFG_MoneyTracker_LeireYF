///Clase que representa un usuario
class Usuario {
  final String id;
  final String correoUsuario;
  
  //sin contraseña pq ya la guarda el authenticator de FireBase

  Usuario({
    required this.id,
    required this.correoUsuario
  });
}