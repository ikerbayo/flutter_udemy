package es.sl1iickdev.loloapi.repositories;

import es.sl1iickdev.loloapi.models.Match;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface MatchRepository extends JpaRepository<Match, Long> {

    @Query("SELECT m FROM Match m " +
           "LEFT JOIN m.teamAway ta " +
           "WHERE (m.teamHome.id = :teamId OR ta.id = :teamId) " +
           "AND m.estado = 'Finalizado' ORDER BY m.fecha DESC")
    List<Match> findUltimosPartidosFinalizados(@Param("teamId") Long teamId, Pageable pageable);

    @Query("SELECT m FROM Match m " +
           "LEFT JOIN m.teamAway ta " +
           "WHERE m.teamHome.id = :teamId OR ta.id = :teamId")
    List<Match> findAllByTeamId(@Param("teamId") Long teamId);

    // --- IDOR Protection: queries filtered by owner (through team -> club -> propietario) ---

    @Query("SELECT DISTINCT m FROM Match m " +
           "JOIN m.teamHome th " +
           "JOIN th.club chc " +
           "LEFT JOIN m.teamAway ta " +
           "LEFT JOIN ta.club rvc " +
           "WHERE chc.propietario.id = :userId " +
           "OR (ta IS NOT NULL AND rvc.propietario.id = :userId)")
    List<Match> findAllByOwner(@Param("userId") Long userId);

    @Query("SELECT m FROM Match m " +
           "JOIN m.teamHome th " +
           "JOIN th.club chc " +
           "LEFT JOIN m.teamAway ta " +
           "LEFT JOIN ta.club rvc " +
           "WHERE m.id = :id AND (chc.propietario.id = :userId " +
           "OR (ta IS NOT NULL AND rvc.propietario.id = :userId))")
    Optional<Match> findByIdAndOwner(@Param("id") Long id, @Param("userId") Long userId);

    // --- Standings Optimization: single query for all finished matches of a club ---

    @Query("SELECT m FROM Match m " +
           "JOIN m.teamHome th " +
           "JOIN th.club chc " +
           "LEFT JOIN m.teamAway ta " +
           "LEFT JOIN ta.club rvc " +
           "WHERE m.estado = 'Finalizado' AND (chc.id = :clubId OR (ta IS NOT NULL AND rvc.id = :clubId)) " +
           "ORDER BY m.fecha ASC")
    List<Match> findFinishedMatchesByClubId(@Param("clubId") Long clubId);
}