package com.example.library.web;

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
import org.springframework.web.bind.annotation.RestController;

import com.example.library.lending.BookCatalog;
import com.example.library.lending.BorrowOutcome;
import com.example.library.lending.LoanService;
import com.example.library.lending.MemberDirectory;
import com.example.library.model.Book;
import com.example.library.model.Loan;
import com.example.library.model.Member;

@RestController
public class LibraryController {

    public record BorrowRequest(String memberId, String isbn) {
    }

    private final BookCatalog books;
    private final MemberDirectory members;
    private final LoanService loans;

    public LibraryController(BookCatalog books, MemberDirectory members, LoanService loans) {
        this.books = books;
        this.members = members;
        this.loans = loans;
    }

    @GetMapping("/books")
    public List<Book> books() {
        return books.all();
    }

    @GetMapping("/members/{id}")
    public ResponseEntity<Member> member(@PathVariable String id) {
        return ResponseEntity.of(members.find(id));
    }

    @GetMapping("/loans/{id}")
    public ResponseEntity<Loan> loan(@PathVariable UUID id) {
        return ResponseEntity.of(loans.find(id));
    }

    @PostMapping("/loans")
    public ResponseEntity<?> borrow(@RequestBody BorrowRequest request) {
        BorrowOutcome outcome = loans.borrow(request.memberId(), request.isbn());
        return switch (outcome.status()) {
            case BORROWED -> ResponseEntity.created(URI.create("/loans/" + outcome.loan().getId()))
                    .body(outcome.loan());
            case NOT_ALLOWED -> {
                ProblemDetail problem = ProblemDetail.forStatus(HttpStatus.BAD_REQUEST);
                problem.setTitle("This loan is not allowed.");
                problem.setProperty("violations", outcome.policy().violations());
                yield ResponseEntity.badRequest().body(problem);
            }
            default -> ResponseEntity.notFound().build();
        };
    }

    @PostMapping("/loans/{id}/return")
    public ResponseEntity<Loan> returnLoan(@PathVariable UUID id) {
        return ResponseEntity.of(loans.returnLoan(id));
    }
}
