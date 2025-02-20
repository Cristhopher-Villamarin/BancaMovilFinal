import 'package:banca_movil_final/Controller/UserController.dart';
import 'package:banca_movil_final/Model/UserI.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'pantalla_inicio.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isProcessing = false;

  Future<void> _signInWithGoogle() async {
    if (_isProcessing) return; // Si ya se está procesando, no hacemos nada

    setState(() {
      _isProcessing = true;
    });

    try {
      // Opcionalmente, cierra sesión antes de iniciar una nueva autenticación
      await GoogleSignIn().signOut();
      await _firebaseAuth.signOut();

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
        signInOption: SignInOption.standard,
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);
        final user = userCredential.user;

        if (user != null) {
          final UserI userI = UserI(
            id: 0,
            email: user.email,
            name: user.displayName,
            numeroCuenta: "",
            saldo: 0,
          );
          final UserI? userILogin =
          await UserController.registerOrLoginUser(userI);

          if (userILogin != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PantallaInicio(user: user, userI: userILogin),
              ),
            );
          } else {
            print('Error al iniciar sesión con Google');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al iniciar sesión')),
            );
          }
        }
      }
    } catch (e) {
      print('Error al iniciar sesión con Google: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 📌 Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assests/fondo_banco.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // 📌 Capa de color semitransparente para mejorar la legibilidad
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 📌 Contenido centrado y optimizado
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 📌 Recuadro para el logo
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset(
                        'assests/logo_banco.png',
                        height: 80,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // 📌 Recuadro para el login
                  Card(
                    color: Colors.white.withOpacity(0.95),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bienvenido',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Accede a tu cuenta de manera segura con Google',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 20),

                          // 📌 Botón de inicio de sesión con Google
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: BorderSide(color: Colors.indigo),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 20,
                              ),
                            ),
                            icon: Image.asset(
                              'assests/google_logo.png',
                              height: 24,
                            ),
                            label: Text(
                              'Iniciar sesión con Google',
                              style: TextStyle(fontSize: 16),
                            ),
                            onPressed: _signInWithGoogle,
                          ),
                          SizedBox(height: 10),

                          Divider(thickness: 1, color: Colors.grey[300]),
                          SizedBox(height: 10),

                          Text(
                            "Capital Bank S.A.",
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
