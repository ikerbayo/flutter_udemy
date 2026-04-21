package es.sl1iickdev.loloapi.config;

import es.sl1iickdev.loloapi.models.Role;
import es.sl1iickdev.loloapi.repositories.RoleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.annotation.Transactional;

@Configuration
@RequiredArgsConstructor
public class DefaultRolesSeeder implements CommandLineRunner {

    private final RoleRepository roleRepository;

    @Override
    @Transactional
    public void run(String... args) {
        for (Role.RoleName roleName : Role.RoleName.values()) {
            if (roleRepository.findByNombre(roleName).isEmpty()) {
                Role newRole = new Role();
                newRole.setNombre(roleName);
                roleRepository.save(newRole);
            }
        }
    }
}
