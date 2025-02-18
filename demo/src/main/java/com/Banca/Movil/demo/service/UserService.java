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

    public User registerOrLoginUser(User user) {
        Optional<User> userRegister = userRepository.findByEmail(user.getEmail());

        if (userRegister.isPresent()) {
            return  userRegister.get();
        }

        User newUser = new User();

        newUser.setEmail(user.getEmail());
        newUser.setName(user.getName());
        newUser.setSaldo(0.00);

        return userRepository.save(newUser);
    }
}