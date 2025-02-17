package com.Banca.Movil.demo.service;

import com.Banca.Movil.demo.model.Notification;
import com.Banca.Movil.demo.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;

    public List<Notification> getUserNotifications(Long userId) {
        return notificationRepository.findByUserId(userId);
    }

    public List<Notification> getUnreadNotifications(Long userId) {
        return notificationRepository.findByUserIdAndIsReadFalse(userId);
    }

    public void markAsRead(Long notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
                .orElseThrow(() -> new RuntimeException("Notificación no encontrada"));
        notification.setRead(true);
        notificationRepository.save(notification);
    }

    // Método adicional para marcar todas las notificaciones como leídas
    public void markAllAsRead(Long userId) {
        List<Notification> notifications = notificationRepository.findByUserIdAndIsReadFalse(userId);
        notifications.forEach(notification -> notification.setRead(true));
        notificationRepository.saveAll(notifications);
    }
}