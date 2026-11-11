package com.example.orders.web;

import java.net.URI;
import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.orders.model.Order;
import com.example.orders.model.OrderStatus;
import com.example.orders.service.CreateOrderOutcome;
import com.example.orders.service.CreateOrderRequest;
import com.example.orders.service.OrderService;

@RestController
@RequestMapping("/orders")
public class OrderController {

    private final OrderService service;

    public OrderController(OrderService service) {
        this.service = service;
    }

    @GetMapping
    public List<Order> list(@RequestParam(required = false) OrderStatus status) {
        return service.list(status);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> find(@PathVariable UUID id) {
        return ResponseEntity.of(service.find(id));
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody CreateOrderRequest request) {
        CreateOrderOutcome outcome = service.create(request);
        if (outcome.order().isPresent()) {
            Order order = outcome.order().get();
            return ResponseEntity.created(URI.create("/orders/" + order.getId())).body(order);
        }

        ProblemDetail problem = ProblemDetail.forStatus(HttpStatus.BAD_REQUEST);
        problem.setTitle("The order is not valid.");
        problem.setProperty("errors", outcome.validation().errors());
        return ResponseEntity.badRequest().body(problem);
    }
}
