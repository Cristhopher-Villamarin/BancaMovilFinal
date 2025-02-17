package com.Banca.Movil.demo.repository;

import com.Banca.Movil.demo.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);

    // Método adicional para verificar si un email ya está registrado
    boolean existsByEmail(String email);
}