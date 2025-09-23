package com.example.demo;
import java.util.Map; import org.springframework.web.bind.annotation.*;
@RestController public class HelloController{ @GetMapping("/") public Map<String,String> hello(){ return Map.of("message","Hello, GKE! (Windows PoC)"); } }
