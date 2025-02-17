package com.Banca.Movil.demo.service;

import com.Banca.Movil.demo.model.Transaction;
import com.Banca.Movil.demo.repository.TransactionRepository;
import com.Banca.Movil.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class TransactionService {

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private UserRepository userRepository; // Añadido para validar el usuario

    public List<Transaction> getTransactionsByUser(Long userId) {
        // Verificar que el usuario exista
        userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return transactionRepository.findByPaymentUserId(userId);
    }

    public List<Transaction> getTransactionsByDate(Long userId, LocalDateTime start, LocalDateTime end) {
        userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return transactionRepository.findByPaymentUserIdAndTransactionDateBetween(userId, start, end);
    }

    public List<Transaction> getTransactionsByType(Long userId, String type) {
        userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        return transactionRepository.findByPaymentUserIdAndType(userId, type);
    }
}