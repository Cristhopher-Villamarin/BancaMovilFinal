import 'package:banca_movil_final/Model/UserI.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'pantalla_pagos.dart';
import 'pantalla_tarjetas.dart';
import 'pantalla_historial.dart';

class PantallaInicio extends StatefulWidget {
  final User user;
  final UserI userI;

  const PantallaInicio({Key? key, required this.user, required this.userI})
      : super(key: key);

  @override
  _PantallaInicioState createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {

  @override
  void initState() {
    super.initState();

  }

  Future<void> _signOut(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  String _obtenerFechaHoraActual() {
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
        title: Text("Inicio", style: TextStyle(color: Colors.white)),
      ),
      drawer: _buildMenuLateral(context), // Menú lateral
      body: Container(
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 📌 Mensaje de bienvenida y último acceso
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

            // 📌 Logo arriba de la tarjeta con saldo y número de cuenta
            Column(
              children: [
                Image.asset(
                  'assests/logo_banco.png', // Asegúrate de colocar esta imagen en la carpeta assets
                  height: 80,
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6, // Hace que la Card sea más ancha
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.lightBlueAccent,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20), // Más ancho
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Número de cuenta",
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.userI.numeroCuenta ?? "",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            "Saldo Disponible",
                            style: TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "\$${(widget.userI.saldo ?? 0).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 📌 Sección de accesos rápidos con fondo celeste
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
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PantallaPagos()),
                    ),
                  ),
                  _buildShortcutButton(
                    icon: Icons.history,
                    label: "Historial",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PantallaHistorial()),
                    ),
                  ),
                  _buildShortcutButton(
                    icon: Icons.credit_card,
                    label: "Tarjetas",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PantallaTarjetas(userI: widget.userI,)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Menú lateral (Drawer)
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
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }

  // ✅ Widget de accesos directos
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
