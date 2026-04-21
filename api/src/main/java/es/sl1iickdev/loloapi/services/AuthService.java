package es.sl1iickdev.loloapi.services;

import es.sl1iickdev.loloapi.dtos.AuthRequestDTO;
import es.sl1iickdev.loloapi.dtos.AuthResponseDTO;
import es.sl1iickdev.loloapi.dtos.RegisterRequestDTO;
import es.sl1iickdev.loloapi.models.*;
import es.sl1iickdev.loloapi.repositories.RoleRepository;
import es.sl1iickdev.loloapi.repositories.UserRepository;
import es.sl1iickdev.loloapi.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository repository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    public AuthResponseDTO register(RegisterRequestDTO request) {
        if(repository.existsByEmail(request.getEmail())) {
            throw new RuntimeException("El email ya está en uso");
        }
        
        var user = new User();
        user.setNombre(request.getNombre());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRoles(new ArrayList<>());
        
        // Guardar el usuario primero para que tenga un ID asignado en la BD
        var savedUser = repository.save(user);

        // Buscar el Rol Admin y asociarlo
        var adminRole = roleRepository.findByNombre(Role.RoleName.Admin)
                .orElseThrow(() -> new RuntimeException("El rol Admin no está definido en la BD"));
                
        var userRole = new UserRole();
        var userRoleId = new UserRoleId();
        userRoleId.setUserId(savedUser.getId());
        userRoleId.setRoleId(adminRole.getId());
        
        userRole.setId(userRoleId);
        userRole.setUser(savedUser);
        userRole.setRole(adminRole);
        
        savedUser.getRoles().add(userRole);
        repository.save(savedUser); // Guardar de nuevo para persistir la relación

        var jwtToken = jwtService.generateToken(savedUser);
        return AuthResponseDTO.builder()
                .token(jwtToken)
                .build();
    }

    public AuthResponseDTO authenticate(AuthRequestDTO request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );
        var user = repository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
                
        var jwtToken = jwtService.generateToken(user);
        return AuthResponseDTO.builder()
                .token(jwtToken)
                .build();
    }
}
