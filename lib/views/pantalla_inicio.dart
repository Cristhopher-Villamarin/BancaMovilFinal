import 'dart:async'; // Para el Timer
import 'package:banca_movil_final/Controller/NotificationController.dart';
import 'package:banca_movil_final/Model/Notification.dart';
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
import 'package:cached_network_image/cached_network_image.dart';


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
  late ImageProvider<Object> profileImage;
  List<NotificationI> _notifications = [];
  int _unreadCount = 0;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    userData = widget.userI;
    fetchUserData(); // Obtener datos al iniciar
    _startAutoRefresh(); // Iniciar actualización automática
    profileImage = CachedNetworkImageProvider(widget.user.photoURL!);
    _loadNotifications();
    _startNotificationChecker();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Detener el Timer cuando se sale de la pantalla
    _notificationTimer?.cancel();
    super.dispose();
  }

  /// Metodos para manejar notificaciónes

  Future<void> _loadNotifications() async {
    final notifications = await NotificationController.getUserNotifications(userData.id);
    final count = await NotificationController.countNotificationNoRead(userData.id);

    if (mounted) {
      setState(() {
        _notifications = notifications ?? [];
        _unreadCount = count ?? 0;
      });
    }
  }

  void _startNotificationChecker() {
    _notificationTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _loadNotifications();
    });
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            titlePadding: const EdgeInsets.all(16),
            contentPadding: const EdgeInsets.only(top: 10, bottom: 16),
            title: Row(
              children: [
                const Icon(Icons.notifications, color: Colors.blue),
                const SizedBox(width: 10),
                const Text(
                  'Notificaciones',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final success = await NotificationController
                        .markAllNotificationsAsRead(userData.id);
                    if (success) {
                      setState(() {
                        for (int i = 0; i < _notifications.length; i++) {
                          _notifications[i].read = true;
                        }
                        _unreadCount = 0;
                      });
                      setDialogState(() {}); // Actualiza solo el diálogo
                    }
                  },
                  child: const Text(
                    'Marcar todas',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: _notifications.isEmpty
                  ? const Center(
                child: Text('No tienes notificaciones nuevas'),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: notification.read
                          ? Colors.grey[100]
                          : Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(
                        notification.message,
                        style: TextStyle(
                          fontWeight: notification.read
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      trailing: notification.read
                          ? const Icon(Icons.check_circle,
                          color: Colors.green)
                          : IconButton(
                        icon: const Icon(Icons.mark_as_unread),
                        color: Colors.blue,
                        onPressed: () async {
                          final success =
                          await NotificationController
                              .markNotificationAsRead(
                              notification.id);

                          if (success) {
                            setState(() {
                              _notifications = List.from(
                                  _notifications); // Clonar la lista
                              _notifications[index] =
                                  NotificationI(
                                    id: notification.id,
                                    user: userData,
                                    message: notification.message,
                                    read: true,
                                  );
                              _unreadCount--;
                            });
                            setDialogState(() {}); // Actualiza solo el diálogo
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// 🚀 Obtiene la información más reciente del usuario
  Future<void> fetchUserData() async {
    try {
      UserI? updatedUser = await UserController.refreshUser(widget.userI);

      setState(() {
        userData = updatedUser!;
      });
    } catch (e) {
      print("Error al actualizar datos del usuario: $e");
    }
  }

  /// 🔄 Inicia la actualización automática cada 10 segundos
  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchUserData();
      _loadNotifications();
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
        title: Text(
          "Inicio",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: _showNotificationsDialog,
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
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
              backgroundImage: profileImage ?? AssetImage('assests/default_avatar.png') as ImageProvider,
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
  Widget _buildShortcutButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Cambia el cursor a una manito
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 30, color: Colors.indigo),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }

}
