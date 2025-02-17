package com.Banca.Movil.demo.service;

import com.Banca.Movil.demo.model.User;
import com.Banca.Movil.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public User registerUser(User user) {
        // Verificar que el email no esté registrado
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new RuntimeException("El email ya está registrado");
        }

        // Guardar el usuario sin encriptar la contraseña
        return userRepository.save(user);
    }
}