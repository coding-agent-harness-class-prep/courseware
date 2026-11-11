package com.example.library.lending;

import java.math.BigDecimal;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.stereotype.Repository;

import com.example.library.model.Member;
import com.example.library.model.MemberType;

/** Library members. In memory for now. */
@Repository
public class MemberDirectory {

    private final Map<String, Member> members = Stream.of(
            new Member("M-100", "Avery Chen", MemberType.ADULT, new BigDecimal("0.00")),
            new Member("M-200", "Jordan Diaz", MemberType.STUDENT, new BigDecimal("0.00")),
            new Member("M-300", "Morgan Patel", MemberType.SENIOR, new BigDecimal("12.50")))
            .collect(Collectors.toMap(Member::getId, Function.identity()));

    public Optional<Member> find(String id) {
        return Optional.ofNullable(members.get(id));
    }
}
