package com.Banca.Movil.demo;

import com.Banca.Movil.demo.controller.CardController;
import com.Banca.Movil.demo.model.Card;
import com.Banca.Movil.demo.model.User;
import com.Banca.Movil.demo.service.CardService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ExtendWith(MockitoExtension.class)
public class CardControllerTest {

    private MockMvc mockMvc;

    @Mock
    private CardService cardService;

    @InjectMocks
    private CardController cardController;

    @BeforeEach
    void setup() {
        MockitoAnnotations.openMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(cardController).build();
    }

    @Test
    public void testAddCardWithValidData() throws Exception {
        // Simulación de un usuario válido
        User user = new User();
        user.setId(1L);
        user.setEmail("user@example.com");

        // Simulación de una tarjeta válida
        Card validCard = new Card();
        validCard.setUser(user);

        when(cardService.addCard(any(Card.class))).thenReturn(validCard);

        mockMvc.perform(post("/cards/add")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(validCard)))
                .andExpect(status().isOk()) // HTTP 200 OK esperado
                .andExpect(jsonPath("$.user.id").value(1L));
    }

    @Test
    public void testAddCardWithInvalidUser() throws Exception {
        // Simulamos el caso donde el usuario no existe
        when(cardService.addCard(any(Card.class))).thenThrow(new RuntimeException("Usuario no encontrado"));

        Card invalidCard = new Card();
        invalidCard.setUser(new User()); // Usuario vacío o sin ID válido

        mockMvc.perform(post("/cards/add")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(new ObjectMapper().writeValueAsString(invalidCard)))
                .andExpect(status().isBadRequest()) // Ahora esperamos un 400 en lugar de un 500
                .andExpect(jsonPath("$").value("Usuario no encontrado")); // Verifica el mensaje de error
    }


    @Test
    public void testFreezeCard() throws Exception {
        Long cardId = 1L;

        // Simulación de la tarjeta existente
        Card mockCard = new Card();
        mockCard.setId(cardId);
        mockCard.setFrozen(true);

        Mockito.when(cardService.freezeCard(cardId)).thenReturn(mockCard);

        mockMvc.perform(put("/cards/freeze/{cardId}", cardId) // Ruta corregida
                        .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.frozen").value(true)); // Verifica si la tarjeta está congelada
    }



}
