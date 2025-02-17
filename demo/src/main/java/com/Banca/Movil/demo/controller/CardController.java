package com.Banca.Movil.demo.controller;

import com.Banca.Movil.demo.model.Card;
import com.Banca.Movil.demo.service.CardService;
import org.springframework.beans.factory.annotation.Autowired;
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
    public ResponseEntity<Card> addCard(@RequestBody Card card) {
        return ResponseEntity.ok(cardService.addCard(card));
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