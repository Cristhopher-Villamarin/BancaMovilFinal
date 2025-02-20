package com.Banca.Movil.demo.model;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.Data;

import java.security.SecureRandom;

@Entity
@Data
public class Card {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)

    private User user;

    @Column(unique = true, length = 20)
    private String cardNumber;

    private boolean isFrozen;

    // Getters y Setters (generados por Lombok @Data)
    @PrePersist
    private void generateNumeroCuenta() {
        if (cardNumber == null || cardNumber.isEmpty()) {
            this.cardNumber = generateRandomcardNumber();
        }
    }

    private String generateRandomcardNumber() {
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder(16);
        sb.append(random.nextInt(9) + 1); // Primer dígito no puede ser 0
        for (int i = 1; i < 16; i++) {
            if (i % 4 == 0) {
                sb.append(" ");
            }
            sb.append(random.nextInt(10));
        }
        return sb.toString();
    }
}