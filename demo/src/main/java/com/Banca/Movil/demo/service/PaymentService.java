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
        // Verificar que la tarjeta no esté congelada
        Card card = cardRepository.findByCardNumber(payment.getCardNumber())
                .orElseThrow(() -> new RuntimeException("Tarjeta no encontrada"));
        if (card.isFrozen()) {
            throw new RuntimeException("La tarjeta está congelada");
        }

        // Obtener el usuario y asignarlo al pago
        User user = userRepository.findById(payment.getUser().getId())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        payment.setUser(user);

        payment.setPaymentDate(LocalDateTime.now());
        Payment savedPayment = paymentRepository.save(payment);

        Transaction transaction = new Transaction();
        transaction.setPayment(savedPayment);
        transaction.setAmount(payment.getAmount());
        transaction.setType("Pago");
        transaction.setTransactionDate(LocalDateTime.now());

        transactionRepository.save(transaction);
        return savedPayment;
    }

    public List<Payment> getPaymentsByUser(Long userId) {
        return paymentRepository.findByUserIdOrderByPaymentDateDesc(userId);
    }
}