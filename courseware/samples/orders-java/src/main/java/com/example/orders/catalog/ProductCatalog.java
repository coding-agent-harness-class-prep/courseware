package com.example.orders.catalog;

import java.util.List;
import java.util.Optional;

import com.example.orders.model.Product;

public interface ProductCatalog {

    List<Product> all();

    Optional<Product> find(String sku);
}
