import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:banca_movil_final/Model/UserI.dart';
import 'package:banca_movil_final/Model/Payment.dart';
import 'package:banca_movil_final/Controller/PaymentController.dart';

class PantallaPagos extends StatefulWidget {
  final UserI userI;

  const PantallaPagos({required this.userI});

  @override
  _PantallaPagosState createState() => _PantallaPagosState();
}

class _PantallaPagosState extends State<PantallaPagos> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _montoController = TextEditingController();
  TextEditingController _tarjetaController = TextEditingController();
  bool _isLoading = false;

  final NumberFormat currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2);

  void _realizarPago() async {
    if (_formKey.currentState!.validate()) {
      String montoTexto = _montoController.text.replaceAll(RegExp(r'[^0-9.]'), '');
      double monto = double.parse(montoTexto);
      String numeroCuenta = _tarjetaController.text;

      Payment nuevoPago = Payment(
        id: 0, // Se generará en el backend
        user: widget.userI, // Suponiendo que el backend lo asigna
        amount: monto,
        numeroCuentaDestino: numeroCuenta,
        paymentDate: DateTime.now(),
      );

      setState(() => _isLoading = true);

      Payment? respuesta = await PaymentController.processPayment(nuevoPago);

      setState(() => _isLoading = false);

      if (respuesta != null) {
        _mostrarDialogo("Pago realizado con éxito.");
      } else {
        _mostrarDialogo("Error al procesar el pago.");
      }
    }
  }

  void _mostrarDialogo(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pago"),
        content: Text(mensaje),
        actions: [
          TextButton(
            child: Text("OK"),
            onPressed: () => {
              Navigator.pop(context),
              Navigator.pop(context)
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pagos y Transferencias"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent.shade100, Colors.white, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: 20),

            // Cuadro centrado con el formulario
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _montoController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          labelText: "Monto a pagar",
                          prefixText: '\$ ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Ingrese un monto válido";
                          }

                          // Validar formato numérico
                          String numericValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
                          if (double.tryParse(numericValue) == null) {
                            return "Formato inválido";
                          }

                          double parsedValue = double.parse(numericValue);

                          // Validar monto positivo
                          if (parsedValue <= 0) {
                            return "El monto debe ser mayor a 0";
                          }

                          // Validar decimales
                          List<String> parts = numericValue.split('.');
                          if (parts.length > 1 && parts[1].length > 2) {
                            return "Máximo dos decimales";
                          }

                          // Validar saldo
                          if (parsedValue > widget.userI.saldo!) {
                            return "Saldo insuficiente";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _tarjetaController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                        decoration: InputDecoration(
                          labelText: "Número de cuenta",
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        maxLength: 16,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Ingrese número de cuenta";
                          }
                          if (value.length != 16) {
                            return "Debe tener 16 dígitos";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botón en la parte inferior
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _realizarPago,
                child: Text("Realizar Pago", style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
