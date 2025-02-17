package com.Banca.Movil.demo.controller;

import com.Banca.Movil.demo.model.Payment;
import com.Banca.Movil.demo.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
@RestController
@RequestMapping("/payments")
@CrossOrigin(origins = "*")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    @PostMapping("/pay")
    public ResponseEntity<?> processPayment(@RequestBody Payment payment) {
        try {
            return ResponseEntity.ok(paymentService.processPayment(payment));
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    @GetMapping("/{userId}")
    public ResponseEntity<List<Payment>> getPaymentsByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(paymentService.getPaymentsByUser(userId));
    }
}