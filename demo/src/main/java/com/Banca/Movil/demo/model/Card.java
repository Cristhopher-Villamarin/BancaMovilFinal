package com.Banca.Movil.demo.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class Card {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)

    private User user;

    private String cardNumber;
    private String cardHolder;
    private boolean isFrozen;

    // Getters y Setters (generados por Lombok @Data)
}