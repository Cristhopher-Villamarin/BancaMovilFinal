package com.Banca.Movil.demo.service;

import com.Banca.Movil.demo.model.Card;
import com.Banca.Movil.demo.model.Notification;
import com.Banca.Movil.demo.model.User;
import com.Banca.Movil.demo.repository.CardRepository;
import com.Banca.Movil.demo.repository.NotificationRepository;
import com.Banca.Movil.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class CardService {

    @Autowired
    private CardRepository cardRepository;

    @Autowired
    private UserRepository userRepository; // Añadido para validar el usuario

    @Autowired
    NotificationRepository notificationRepository;

    public List<Card> getCardsByUser(Long userId) {
        return cardRepository.findByUserId(userId);
    }

    public Card addCard(Card card) {
        // Verificar que el usuario exista
        User user = userRepository.findById(card.getUser().getId())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        card.setUser(user);
        card.setId(null);
        card.setCardNumber(null);

        Notification notification = new Notification(null, card.getUser(), "A solicitado una nueva tarjeta y a sido activada", false);
        notificationRepository.save(notification);

        return cardRepository.save(card);
    }

    public Card freezeCard(Long cardId) {
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Tarjeta no encontrada"));
        card.setFrozen(true);
        return cardRepository.save(card);
    }

    public Card unfreezeCard(Long cardId) {
        Card card = cardRepository.findById(cardId)
                .orElseThrow(() -> new RuntimeException("Tarjeta no encontrada"));
        card.setFrozen(false);
        return cardRepository.save(card);
    }
}