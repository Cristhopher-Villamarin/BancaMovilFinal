package com.Banca.Movil.demo.repository;

import com.Banca.Movil.demo.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    List<Payment> findByUserIdOrderByPaymentDateDesc(Long userId);

    // Método adicional para buscar pagos por rango de fechas
    List<Payment> findByUserIdAndPaymentDateBetween(Long userId, LocalDateTime startDate, LocalDateTime endDate);
}