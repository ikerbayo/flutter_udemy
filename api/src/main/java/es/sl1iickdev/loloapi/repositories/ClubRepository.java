package es.sl1iickdev.loloapi.repositories;

import es.sl1iickdev.loloapi.models.Club;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ClubRepository extends JpaRepository<Club, Long> {
    Optional<Club> findFirstByPropietarioId(Long propietarioId);
    long countByPropietarioId(Long propietarioId);

    // --- IDOR Protection: queries filtered by owner ---
    Optional<Club> findByIdAndPropietarioId(Long id, Long propietarioId);
    List<Club> findAllByPropietarioId(Long propietarioId);
}