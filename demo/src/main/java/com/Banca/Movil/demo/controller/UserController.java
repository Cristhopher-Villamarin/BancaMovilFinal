package com.Banca.Movil.demo.controller;

import com.Banca.Movil.demo.model.User;
import com.Banca.Movil.demo.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/registerOrLogin")
    public ResponseEntity<?> registerOrLoginUser(@RequestBody User user) {
        try {
            return ResponseEntity.ok(userService.registerOrLoginUser(user));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error al registrar usuario: " + e.getMessage());
        }
    }

    @PostMapping("/refresh")
    public ResponseEntity<?> refreshUserInfo(@RequestBody User user) {
        try {
            return ResponseEntity.ok(userService.refreshUserInfo(user));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error obteniendo información del usuario: " + e.getMessage());
        }
    }
}