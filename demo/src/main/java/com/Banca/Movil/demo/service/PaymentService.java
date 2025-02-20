package com.Banca.Movil.demo.service;

import com.Banca.Movil.demo.model.*;
import com.Banca.Movil.demo.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
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

    @Autowired
    private NotificationRepository notificationRepository;

    @Transactional
    public Payment processPayment(Payment payment) {
        // 1. Verificar si la cuenta destino existe
        User destinationUser = userRepository.findByNumeroCuenta(payment.getNumeroCuentaDestino())
                .orElseThrow(() -> new RuntimeException("Cuenta destino no encontrada"));

        User originAccount = userRepository.findById(payment.getUser().getId())
                .orElseThrow(() -> new RuntimeException("Cuenta de origen no encontrada"));

        if(destinationUser.getNumeroCuenta().equals(originAccount.getNumeroCuenta())) {
            throw new RuntimeException("No se puede transferir al número de cuenta propio");
        }

        // 2. Verificar saldo del usuario origen
        List<Transaction> transactions = transactionRepository.findByAccountNumber(originAccount.getNumeroCuenta(), Sort.by(Sort.Order.desc("transactionDate")));
        double saldo = transactions.stream().mapToDouble(Transaction::getAmount).sum();

        if (saldo < payment.getAmount()) {
            throw new RuntimeException("Saldo insuficiente en la cuenta origen");
        }

        // 3. Guardar el pago en la base de datos
        payment.setPaymentDate(LocalDateTime.now());
        payment.setId(null);
        Payment paymentSaved = paymentRepository.save(payment);

        // 4. Crear transacciones para la cuenta origen y cuenta destino
        createTransaction(paymentSaved, originAccount.getNumeroCuenta(), -paymentSaved.getAmount());
        createTransaction(paymentSaved, destinationUser.getNumeroCuenta(), paymentSaved.getAmount());

        createNotification(originAccount, "A realizado una trasferencia por un valor de " + paymentSaved.getAmount() + "$.");
        createNotification(destinationUser, "A recivido una trasferencia por un valor de " + paymentSaved.getAmount() + "$.");

        return paymentSaved;
    }

    private void createNotification(User originAccount, String message) {
        Notification notification = new Notification(null, originAccount, message , false);
        notificationRepository.save(notification);
    }

    private void createTransaction(Payment payment, String account, double amount) {
        Transaction transaction = new Transaction();
        transaction.setPayment(payment);
        transaction.setType("Transferencia");
        transaction.setAccountNumber(account);
        transaction.setAmount(amount);
        transaction.setTransactionDate(LocalDateTime.now());
        transactionRepository.save(transaction);
    }

    public List<Payment> getPaymentsByUser(Long userId) {
        return paymentRepository.findByUserIdOrderByPaymentDateDesc(userId);
    }
}