package com.Banca.Movil.demo.controller;

import com.Banca.Movil.demo.model.Transaction;
import com.Banca.Movil.demo.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@RestController
@RequestMapping("/transactions")
@CrossOrigin(origins = "*")
public class TransactionController {

    @Autowired
    private TransactionService transactionService;

    private static final DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @GetMapping("/{userId}")
    public ResponseEntity<List<Transaction>> getTransactionsByUser(@PathVariable Long userId) {
        return ResponseEntity.ok(transactionService.getTransactionsByUser(userId));
    }

    @GetMapping("/{userId}/date")
    public ResponseEntity<List<Transaction>> getTransactionsByDate(
            @PathVariable Long userId,
            @RequestParam String startDate,
            @RequestParam String endDate) {
        try {
            LocalDateTime start = LocalDateTime.parse(startDate, formatter);
            LocalDateTime end = LocalDateTime.parse(endDate, formatter);
            return ResponseEntity.ok(transactionService.getTransactionsByDate(userId, start, end));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(null);
        }
    }
}