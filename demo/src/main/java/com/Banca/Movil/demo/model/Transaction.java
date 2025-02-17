package com.Banca.Movil.demo.model;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "payment_id", nullable = false)
    private Payment payment;

    private String type;
    private LocalDateTime transactionDate;
    private Double amount;

    // Getters y Setters (generados por Lombok @Data)
}