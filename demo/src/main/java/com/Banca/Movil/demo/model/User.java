package com.Banca.Movil.demo.model;

import jakarta.persistence.*;
import lombok.Data;

import java.security.SecureRandom;

@Entity
@Data
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String email;
    private String name;

    @Column(unique = true, length = 16)
    private String numeroCuenta;

    @Column
    private double saldo = 0.0;


    @PrePersist
    private void generateNumeroCuenta() {
        if (numeroCuenta == null || numeroCuenta.isEmpty()) {
            this.numeroCuenta = generateRandomAccountNumber();
        }
    }

    private String generateRandomAccountNumber() {
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder(16);
        sb.append(random.nextInt(9) + 1); // Primer dígito no puede ser 0
        for (int i = 1; i < 16; i++) {
            sb.append(random.nextInt(10));
        }
        return sb.toString();
    }

}