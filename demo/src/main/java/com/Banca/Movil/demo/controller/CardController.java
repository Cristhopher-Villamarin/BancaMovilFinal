package com.Banca.Movil.demo.controller;

import com.Banca.Movil.demo.model.Card;
import com.Banca.Movil.demo.service.CardService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/cards")
@CrossOrigin(origins = "*")
public class CardController {

    @Autowired
    private CardService cardService;

    @GetMapping("/{userId}")
    public ResponseEntity<List<Card>> getCardsByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(cardService.getCardsByUser(userId));
    }

    @PostMapping("/add")
    public ResponseEntity<?> addCard(@RequestBody Card card) {
        try {
            return ResponseEntity.ok(cardService.addCard(card)); // Devuelve la tarjeta en caso de éxito
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage()); // Ahora devuelve 400 en vez de 500
        }
    }



    @PutMapping("/freeze/{cardId}")
    public ResponseEntity<Card> freezeCard(@PathVariable Long cardId) {
        return ResponseEntity.ok(cardService.freezeCard(cardId));
    }

    @PutMapping("/unfreeze/{cardId}")
    public ResponseEntity<Card> unfreezeCard(@PathVariable Long cardId) {
        return ResponseEntity.ok(cardService.unfreezeCard(cardId));
    }
}