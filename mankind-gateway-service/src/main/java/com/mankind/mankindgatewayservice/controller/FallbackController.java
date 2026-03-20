package com.mankind.mankindgatewayservice.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class FallbackController {

    @GetMapping("/fallback/users")
    public ResponseEntity<List<?>> usersFallback() {
        return ResponseEntity.ok(List.of());
    }
}
