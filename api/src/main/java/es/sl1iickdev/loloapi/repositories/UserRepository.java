package es.sl1iickdev.loloapi.repositories;

import es.sl1iickdev.loloapi.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    // Metodo para encontrar por email
    Optional<User> findByEmail(String email);

    // Comprueba si existe antes de intentar registrarlo
    boolean existsByEmail(String email);
}