class UserI {
  final int id;
  final String? email;
  final String? name;
  final String? numeroCuenta;
  final double? saldo;

  UserI({
    required this.id,
    required this.email,
    required this.name,
    required this.numeroCuenta,
    required this.saldo,
  });

  // Método para convertir un JSON a un objeto User
  factory UserI.fromJson(Map<String, dynamic> json) {
    return UserI(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      numeroCuenta: json['numeroCuenta'] as String,
      saldo: json['saldo'] as double,
    );
  }

  // Método para convertir un objeto User a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'numeroCuenta': numeroCuenta,
      'saldo': saldo,
    };
  }
}
