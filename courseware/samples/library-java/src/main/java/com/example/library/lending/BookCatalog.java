package com.example.library.lending;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.stereotype.Repository;

import com.example.library.model.Book;

/** The books the library holds. In memory for now. */
@Repository
public class BookCatalog {

    private final Map<String, Book> books = Stream.of(
            new Book("9780134685991", "Effective Java", "Joshua Bloch", 2),
            new Book("9781617294532", "C# in Depth", "Jon Skeet", 1),
            new Book("9780321125217", "Domain-Driven Design", "Eric Evans", 3),
            new Book("9780135957059", "The Pragmatic Programmer", "David Thomas and Andrew Hunt", 2),
            new Book("9781492040347", "Designing Data-Intensive Applications", "Martin Kleppmann", 1))
            .collect(Collectors.toMap(Book::isbn, Function.identity()));

    public List<Book> all() {
        return books.values().stream().sorted(Comparator.comparing(Book::title)).toList();
    }

    public Optional<Book> find(String isbn) {
        return Optional.ofNullable(books.get(isbn));
    }
}
