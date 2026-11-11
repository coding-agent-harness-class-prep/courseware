package com.example.orders.catalog;

import java.math.BigDecimal;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.springframework.stereotype.Repository;

import com.example.orders.model.Product;

@Repository
public class InMemoryProductCatalog implements ProductCatalog {

    private final Map<String, Product> products;

    public InMemoryProductCatalog() {
        this(List.of(
                new Product("CAB-USBC", "USB-C cable, 1 m", new BigDecimal("8.40")),
                new Product("DOCK-TB4", "Thunderbolt 4 dock", new BigDecimal("199.00")),
                new Product("HS-NC", "Noise-canceling headset", new BigDecimal("129.99")),
                new Product("KB-MECH", "Mechanical keyboard", new BigDecimal("89.00")),
                new Product("MON-27", "27-inch monitor", new BigDecimal("249.00")),
                new Product("MS-WL", "Wireless mouse", new BigDecimal("24.50"))));
    }

    public InMemoryProductCatalog(List<Product> products) {
        this.products = products.stream()
                .collect(Collectors.toMap(p -> key(p.sku()), Function.identity()));
    }

    @Override
    public List<Product> all() {
        return products.values().stream().sorted(Comparator.comparing(Product::sku)).toList();
    }

    @Override
    public Optional<Product> find(String sku) {
        return sku == null ? Optional.empty() : Optional.ofNullable(products.get(key(sku)));
    }

    private static String key(String sku) {
        return sku.toUpperCase(Locale.ROOT);
    }
}
