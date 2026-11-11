package com.example.library.lending;

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.stereotype.Repository;

import com.example.library.model.Loan;

/** Loans, active and returned. In memory for now. */
@Repository
public class LoanRepository {

    private final Map<UUID, Loan> loans = new ConcurrentHashMap<>();

    public void save(Loan loan) {
        loans.put(loan.getId(), loan);
    }

    public Optional<Loan> find(UUID id) {
        return Optional.ofNullable(loans.get(id));
    }

    public List<Loan> active() {
        return loans.values().stream()
                .filter(Loan::isActive)
                .sorted(Comparator.comparing(Loan::getDueOn))
                .toList();
    }
}
