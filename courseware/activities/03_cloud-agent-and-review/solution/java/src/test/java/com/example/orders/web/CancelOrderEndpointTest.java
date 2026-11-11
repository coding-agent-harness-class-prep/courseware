package com.example.orders.web;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
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
class CancelOrderEndpointTest {

    @Autowired
    private MockMvc mvc;

    private String placeOrder() throws Exception {
        String body = """
                {"customerId": "C-1001", "customerTier": "STANDARD", "region": "OR",
                 "lines": [{"sku": "MS-WL", "quantity": 1}]}
                """;
        return mvc.perform(post("/orders").contentType(MediaType.APPLICATION_JSON).content(body))
                .andReturn().getResponse().getHeader("Location");
    }

    @Test
    void cancel_pendingOrder_returns200WithCanceledStatus() throws Exception {
        String location = placeOrder();

        mvc.perform(post(location + "/cancel"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CANCELED"));
    }

    @Test
    void cancel_unknownOrder_returns404() throws Exception {
        mvc.perform(post("/orders/" + UUID.randomUUID() + "/cancel"))
                .andExpect(status().isNotFound());
    }

    @Test
    void cancel_alreadyCanceled_returns409() throws Exception {
        String location = placeOrder();
        mvc.perform(post(location + "/cancel"));

        mvc.perform(post(location + "/cancel"))
                .andExpect(status().isConflict());
    }
}
