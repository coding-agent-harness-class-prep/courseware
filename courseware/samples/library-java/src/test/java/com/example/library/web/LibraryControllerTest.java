package com.example.library.web;

import static org.hamcrest.Matchers.startsWith;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class LibraryControllerTest {

    @Autowired
    private MockMvc mvc;

    @Test
    void getBooks_returnsCatalog() throws Exception {
        mvc.perform(get("/books"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(5));
    }

    @Test
    void postLoan_valid_returns201WithLocation() throws Exception {
        mvc.perform(post("/loans").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"memberId\": \"M-100\", \"isbn\": \"9780321125217\"}"))
                .andExpect(status().isCreated())
                .andExpect(header().string("Location", startsWith("/loans/")));
    }

    @Test
    void postLoan_unknownMember_returns404() throws Exception {
        mvc.perform(post("/loans").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"memberId\": \"M-999\", \"isbn\": \"9780321125217\"}"))
                .andExpect(status().isNotFound());
    }

    @Test
    void getMember_known_returnsOutstandingFines() throws Exception {
        mvc.perform(get("/members/M-300"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.outstandingFines").value(12.50));
    }
}
