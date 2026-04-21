package es.sl1iickdev.loloapi.models;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "matches")
@Data
public class Match {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "team_home_id", nullable = false)
    private Team teamHome;

    /**
     * Equipo visitante registrado en el sistema.
     * Puede ser null si el rival es externo (ver rivalNombre).
     */
    @ManyToOne
    @JoinColumn(name = "team_away_id", nullable = true)
    private Team teamAway;

    /**
     * Nombre libre del equipo rival cuando no está en el sistema.
     * Si teamAway != null, este campo es ignorado.
     */
    @Column(name = "rival_nombre")
    private String rivalNombre;

    private LocalDateTime fecha;

    private String estado;
}