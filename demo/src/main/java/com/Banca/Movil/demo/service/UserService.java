package com.Banca.Movil.demo.service;

import com.Banca.Movil.demo.model.Notification;
import com.Banca.Movil.demo.model.Transaction;
import com.Banca.Movil.demo.model.User;
import com.Banca.Movil.demo.repository.NotificationRepository;
import com.Banca.Movil.demo.repository.TransactionRepository;
import com.Banca.Movil.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private NotificationRepository notificationRepository;

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public User registerOrLoginUser(User user) {
        Optional<User> userRegister = userRepository.findByEmail(user.getEmail());

        if (userRegister.isPresent()) {
            User userRegisterEntity = userRegister.get();

            List<Transaction> transactions = transactionRepository.findByAccountNumber(userRegisterEntity.getNumeroCuenta(), Sort.by(Sort.Order.desc("transactionDate")));
            double saldo = transactions.stream().mapToDouble(Transaction::getAmount).sum();
            saldo = BigDecimal.valueOf(saldo).setScale(2, RoundingMode.HALF_UP).doubleValue();

            userRegisterEntity.setSaldo(saldo);

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
            String formattedDateNow = LocalDateTime.now().format(formatter);

            createNotification(userRegisterEntity, "Inicio de sesión registrado el " + formattedDateNow);

            return userRegisterEntity;
        }

        User newUser = new User();

        newUser.setEmail(user.getEmail());
        newUser.setName(user.getName());
        newUser.setSaldo(0.00);

        newUser = userRepository.save(newUser);

        createNotification(newUser, "¡Hola! " + newUser.getName() + ", le damos la bienvenida a nuestra banca movil.");

        return newUser;
    }

    public User refreshUserInfo(User user) {
        Optional<User> userRegister = userRepository.findByEmail(user.getEmail());

        if (userRegister.isEmpty()) {
            throw new RuntimeException("Error obteniendo la informacion del usuario");
        }

        User userRegisterEntity = userRegister.get();

        List<Transaction> transactions = transactionRepository.findByAccountNumber(userRegisterEntity.getNumeroCuenta(), Sort.by(Sort.Order.desc("transactionDate")));
        double saldo = transactions.stream().mapToDouble(Transaction::getAmount).sum();
        saldo = BigDecimal.valueOf(saldo).setScale(2, RoundingMode.HALF_UP).doubleValue();

        userRegisterEntity.setSaldo(saldo);

        return userRegisterEntity;
    }


    private void createNotification(User originAccount, String message) {
        Notification notification = new Notification(null, originAccount, message , false);
        notificationRepository.save(notification);
    }
}