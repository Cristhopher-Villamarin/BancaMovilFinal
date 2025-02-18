package com.Banca.Movil.demo.service;

import com.Banca.Movil.demo.model.Card;
import com.Banca.Movil.demo.model.Payment;
import com.Banca.Movil.demo.model.Transaction;
import com.Banca.Movil.demo.model.User;
import com.Banca.Movil.demo.repository.CardRepository;
import com.Banca.Movil.demo.repository.PaymentRepository;
import com.Banca.Movil.demo.repository.TransactionRepository;
import com.Banca.Movil.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
@Service
public class PaymentService {

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private CardRepository cardRepository;

    @Autowired
    private UserRepository userRepository; // Añadido para obtener el usuario

    @Transactional
    public Payment processPayment(Payment payment) {
        // 1. Verificar si la cuenta destino existe
        User destinationUser = userRepository.findByNumeroCuenta(payment.getNumeroCuentaDestino())
                .orElseThrow(() -> new RuntimeException("Cuenta destino no encontrada"));

        // 2. Verificar saldo del usuario origen
        User originUser = payment.getUser(); // Usuario origen
        User originAccount = userRepository.findById(originUser.getId())
                .orElseThrow(() -> new RuntimeException("Cuenta de origen no encontrada"));

        if (originAccount.getSaldo() < payment.getAmount()) {
            throw new RuntimeException("Saldo insuficiente en la cuenta origen");
        }

        // 3. Realizar la transferencia (restar del saldo de origen y sumar al saldo de destino)
        originAccount.setSaldo(originAccount.getSaldo() - payment.getAmount());
        userRepository.save(originAccount);

        User destinationAccount = userRepository.findById(destinationUser.getId())
                .orElseThrow(() -> new RuntimeException("Cuenta destino no encontrada"));
        destinationAccount.setSaldo(destinationAccount.getSaldo() + payment.getAmount());
        userRepository.save(destinationAccount);

        // 4. Guardar el pago en la base de datos
        payment.setPaymentDate(LocalDateTime.now());
        payment.setId(null);
        Payment paymentSaved = paymentRepository.save(payment);

        // 5. Crear transacciones para la cuenta origen y cuenta destino
        createTransaction(paymentSaved, originUser, "enviado", originAccount.getNumeroCuenta());
        createTransaction(paymentSaved, destinationUser, "recibido", destinationAccount.getNumeroCuenta());

        return paymentSaved;
    }

    private void createTransaction(Payment payment, User user, String type, String account) {
        Transaction transaction = new Transaction();
        transaction.setPayment(payment);
        transaction.setType(type);
        transaction.setAccountNumber(account);
        transaction.setAmount(payment.getAmount());
        transaction.setTransactionDate(LocalDateTime.now());
        transactionRepository.save(transaction);
    }

    public List<Payment> getPaymentsByUser(Long userId) {
        return paymentRepository.findByUserIdOrderByPaymentDateDesc(userId);
    }
}