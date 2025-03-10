package com.Banca.Movil.demo.controller;

import com.Banca.Movil.demo.model.Notification;
import com.Banca.Movil.demo.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @GetMapping("/{userId}")
    public ResponseEntity<List<Notification>> getUserNotifications(@PathVariable Long userId) {
        return ResponseEntity.ok(notificationService.getUserNotifications(userId));
    }

    @PutMapping("/mark-as-read/{notificationId}")
    public ResponseEntity<Void> markNotificationAsRead(@PathVariable Long notificationId) {
        notificationService.markAsRead(notificationId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/countNotificationNoRead/{userId}")
    public ResponseEntity<Long> countNotificationNoRead(@PathVariable Long userId) {
        try {
            return ResponseEntity.ok(notificationService.countNotificationNoRead(userId));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }

    }

    // Método adicional para marcar todas las notificaciones como leídas
    @PutMapping("/mark-all-as-read/{userId}")
    public ResponseEntity<Void> markAllNotificationsAsRead(@PathVariable Long userId) {
        notificationService.markAllAsRead(userId);
        return ResponseEntity.noContent().build();
    }
}