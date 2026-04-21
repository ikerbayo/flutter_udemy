package es.sl1iickdev.loloapi.repositories;

import es.sl1iickdev.loloapi.models.Team;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TeamRepository extends JpaRepository<Team, Long> {
    List<Team> findByClubId(Long clubId);

    // --- IDOR Protection: queries filtered by club owner ---
    List<Team> findByClubPropietarioId(Long propietarioId);
    Optional<Team> findByIdAndClubPropietarioId(Long id, Long propietarioId);
    List<Team> findByClubIdAndClubPropietarioId(Long clubId, Long propietarioId);
}
