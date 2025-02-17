package com.Banca.Movil.demo.repository;

import com.Banca.Movil.demo.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    List<Transaction> findByPaymentUserId(Long userId);
    List<Transaction> findByPaymentUserIdAndTransactionDateBetween(Long userId, LocalDateTime startDate, LocalDateTime endDate);
    List<Transaction> findByPaymentUserIdAndType(Long userId, String type);

    // Método adicional para contar transacciones por tipo
    long countByPaymentUserIdAndType(Long userId, String type);
}