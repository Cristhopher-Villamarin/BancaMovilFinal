package com.Banca.Movil.demo.repository;

import com.Banca.Movil.demo.model.Notification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByUserIdAndIsReadFalse(Long userId);
    List<Notification> findByUserId(Long userId);

    // Método adicional para contar notificaciones no leídas
    long countByUserIdAndIsReadFalse(Long userId);
}