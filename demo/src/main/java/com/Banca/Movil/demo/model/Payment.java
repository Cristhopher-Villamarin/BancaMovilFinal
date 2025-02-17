package com.Banca.Movil.demo.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Data
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)

    private User user;

    private Double amount;
    private String cardNumber;
    private LocalDateTime paymentDate;

    // Getters y Setters (generados por Lombok @Data)
}