package com.Banca.Movil.demo.repository;

import com.Banca.Movil.demo.model.Card;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CardRepository extends JpaRepository<Card, Long> {
    List<Card> findByUserId(Long userId);
    Optional<Card> findByCardNumber(String cardNumber);

    // Método adicional para verificar si una tarjeta ya existe para un usuario
    boolean existsByUserIdAndCardNumber(Long userId, String cardNumber);
}