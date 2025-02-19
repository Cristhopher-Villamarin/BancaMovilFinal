import 'dart:async'; // Para el Timer
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../Controller/UserController.dart'; // Importa tu servicio de usuario
import 'login_screen.dart';
import 'pantalla_pagos.dart';
import 'pantalla_tarjetas.dart';
import 'pantalla_historial.dart';
import 'package:banca_movil_final/Model/UserI.dart';

class PantallaInicio extends StatefulWidget {
  final User user;
  final UserI userI;

  const PantallaInicio({Key? key, required this.user, required this.userI})
      : super(key: key);

  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  late UserI userData;
  Timer? _timer; // Timer para actualización periódica

  @override
  void initState() {
    super.initState();
    userData = widget.userI;
    fetchUserData(); // Obtener datos al iniciar
    _startAutoRefresh(); // Iniciar actualización automática
  }

  @override
  void dispose() {
    _timer?.cancel(); // Detener el Timer cuando se sale de la pantalla
    super.dispose();
  }

  /// 🚀 Obtiene la información más reciente del usuario
  Future<void> fetchUserData() async {
    try {
      UserI? updatedUser = await UserController.registerOrLoginUser(widget.userI);

      setState(() {
        userData = updatedUser!;
      });
    } catch (e) {
      print("Error al actualizar datos del usuario: $e");
    }
  }

  /// 🔄 Inicia la actualización automática cada 30 segundos
  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      fetchUserData();
    });
  }

  /// 📌 Formatear fecha y hora
  String _obtenerFechaHoraActual() {
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  }

  /// ✅ Navegar a otra pantalla y actualizar datos al volver
  void _navigateAndRefresh(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen))
        .then((_) => fetchUserData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        title: Text("Inicio", style: TextStyle(color: Colors.white)),
      ),
      drawer: _buildMenuLateral(context),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Text(
                  "Bienvenido/a, ${widget.user.displayName ?? "Usuario"}!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                SizedBox(height: 5),
                Text(
                  "Último acceso: ${_obtenerFechaHoraActual()}",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 20),
              ],
            ),

            // 📌 Tarjeta con saldo actualizado
            Column(
              children: [
                Image.asset(
                  'assests/logo_banco.png',
                  height: 80,
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.lightBlueAccent,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Column(
                      children: [
                        Text("Número de cuenta", style: TextStyle(fontSize: 16, color: Colors.white70)),
                        SizedBox(height: 5),
                        Text(
                          userData.numeroCuenta ?? "",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 15),
                        Text("Saldo Disponible", style: TextStyle(fontSize: 16, color: Colors.white70)),
                        SizedBox(height: 5),
                        Text(
                          "\$${(userData.saldo ?? 0).toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 📌 Accesos rápidos
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShortcutButton(
                    icon: Icons.payment,
                    label: "Pagos",
                    onTap: () => _navigateAndRefresh(PantallaPagos(userI: userData)),
                  ),
                  _buildShortcutButton(
                    icon: Icons.history,
                    label: "Historial",
                    onTap: () => _navigateAndRefresh(PantallaHistorial(userI: userData)),
                  ),
                  _buildShortcutButton(
                    icon: Icons.credit_card,
                    label: "Tarjetas",
                    onTap: () => _navigateAndRefresh(PantallaTarjetas(userI: userData)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Menú lateral (Drawer)
  Widget _buildMenuLateral(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.lightBlueAccent),
            accountName: Text(
              widget.user.displayName ?? "Usuario",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              widget.user.email ?? "",
              style: TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              radius: 40,
              backgroundImage: widget.user.photoURL != null
                  ? NetworkImage(widget.user.photoURL!)
                  : AssetImage('assets/default_avatar.png') as ImageProvider,
            ),
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.red),
            title: Text("Cerrar sesión"),
            onTap: () async {
              await AuthService().signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
            },
          ),
        ],
      ),
    );
  }

  /// ✅ Botones de acceso rápido
  Widget _buildShortcutButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 30, color: Colors.indigo),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo)),
        ],
      ),
    );
  }
}
