package com.example.orders.web;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.orders.catalog.ProductCatalog;
import com.example.orders.model.Product;

@RestController
@RequestMapping("/products")
public class ProductController {

    private final ProductCatalog catalog;

    public ProductController(ProductCatalog catalog) {
        this.catalog = catalog;
    }

    @GetMapping
    public List<Product> all() {
        return catalog.all();
    }
}
