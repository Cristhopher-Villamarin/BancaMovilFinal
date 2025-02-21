package com.Banca.Movil.demo;
import com.Banca.Movil.demo.controller.UserController;
import com.Banca.Movil.demo.model.User;
import com.Banca.Movil.demo.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ExtendWith(MockitoExtension.class)
public class UserControllerTest {

    private MockMvc mockMvc;

    @Mock
    private UserService userService;

    @InjectMocks
    private UserController userController;

    @BeforeEach
    void setup() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(userController).build();
    }

    @Test
    public void testRegisterOrLoginUser() throws Exception {
        User user = new User();
        user.setEmail("test@example.com");
        user.setName("test@example.com");

        when(userService.registerOrLoginUser(any(User.class))).thenReturn(user);

        mockMvc.perform(post("/users/registerOrLogin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(user)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("test@example.com"));
    }
    @Test
    public void testLoginWithValidCredentials() throws Exception {
        // Simulando usuario válido
        User validUser = new User();
        validUser.setEmail("test@example.com");
        validUser.setName("test@example.com");

        when(userService.registerOrLoginUser(any(User.class))).thenReturn(validUser);

        mockMvc.perform(post("/users/registerOrLogin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(validUser)))
                .andExpect(status().isOk()) // Esperamos HTTP 200
                .andExpect(jsonPath("$.email").value("test@example.com"));
    }

    @Test
    public void testLoginWithInvalidCredentials() throws Exception {
        // Simulando que el usuario no existe
        when(userService.registerOrLoginUser(any(User.class))).thenThrow(new RuntimeException("Usuario no encontrado"));

        User invalidUser = new User();
        invalidUser.setEmail("invalid@example.com");
        invalidUser.setName("Invalid User");

        mockMvc.perform(post("/users/registerOrLogin")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(invalidUser)))
                .andExpect(status().isInternalServerError()) // Esperamos HTTP 500
                .andExpect(jsonPath("$").value("Error al registrar usuario: Usuario no encontrado"));
    }

}
