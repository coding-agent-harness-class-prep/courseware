package com.example.orders.service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

import com.example.orders.model.Order;

public interface OrderRepository {

    void save(Order order);

    Optional<Order> find(UUID id);

    List<Order> all();
}
