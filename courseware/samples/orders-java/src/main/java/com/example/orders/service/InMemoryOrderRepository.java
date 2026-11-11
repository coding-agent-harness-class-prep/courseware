package com.example.orders.service;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Repository;

import com.example.orders.model.Order;

@Repository
public class InMemoryOrderRepository implements OrderRepository {

    private final Map<UUID, Order> orders = new ConcurrentHashMap<>();

    @Override
    public void save(Order order) {
        orders.put(order.getId(), order);
    }

    @Override
    public Optional<Order> find(UUID id) {
        return Optional.ofNullable(orders.get(id));
    }

    @Override
    public List<Order> all() {
        return orders.values().stream().sorted(Comparator.comparing(Order::getCreatedAt)).toList();
    }
}
