package es.sl1iickdev.loloapi.controllers;

import es.sl1iickdev.loloapi.dtos.AuthRequestDTO;
import es.sl1iickdev.loloapi.dtos.AuthResponseDTO;
import es.sl1iickdev.loloapi.dtos.RegisterRequestDTO;
import es.sl1iickdev.loloapi.services.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService service;

    @PostMapping("/register")
    public ResponseEntity<AuthResponseDTO> register(
            @RequestBody RegisterRequestDTO request
    ) {
        return ResponseEntity.ok(service.register(request));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponseDTO> authenticate(
            @RequestBody AuthRequestDTO request
    ) {
        return ResponseEntity.ok(service.authenticate(request));
    }
}
