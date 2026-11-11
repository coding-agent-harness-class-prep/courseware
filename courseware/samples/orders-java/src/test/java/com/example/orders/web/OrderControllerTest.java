package com.example.orders.web;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class OrderControllerTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void getProducts_returnsCatalog() throws Exception {
        mvc.perform(get("/products"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(6));
    }

    @Test
    void postOrder_valid_returns201WithLocation() throws Exception {
        String body = """
                {"customerId": "C-1001", "customerTier": "STANDARD", "region": "OR",
                 "lines": [{"sku": "KB-MECH", "quantity": 1}]}
                """;

        mvc.perform(post("/orders").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isCreated())
                .andExpect(header().string("Location", org.hamcrest.Matchers.startsWith("/orders/")));
    }

    @Test
    void postOrder_invalid_returns400WithErrorCodes() throws Exception {
        String body = """
                {"customerId": "", "customerTier": "STANDARD", "region": "OR", "lines": []}
                """;

        mvc.perform(post("/orders").contentType(MediaType.APPLICATION_JSON).content(body))
                .andExpect(status().isBadRequest())
                .andExpect(content().string(org.hamcrest.Matchers.containsString("ORD001")))
                .andExpect(content().string(org.hamcrest.Matchers.containsString("ORD003")));
    }

    @Test
    void getOrder_unknown_returns404() throws Exception {
        mvc.perform(get("/orders/" + UUID.randomUUID()))
                .andExpect(status().isNotFound());
    }
}
