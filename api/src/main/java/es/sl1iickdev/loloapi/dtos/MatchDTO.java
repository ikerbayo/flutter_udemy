package es.sl1iickdev.loloapi.dtos;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class MatchDTO {
    private Long id;

    private Long teamHomeId;
    private String teamHomeNombre;

    /** Equipo rival del sistema (opcional si se usa rivalNombre). */
    private Long teamAwayId;
    private String teamAwayNombre;

    /**
     * Nombre libre del rival cuando no tiene equipo registrado.
     * Si se envía este campo y teamAwayId es null, el partido
     * se crea sin equipo visitante registrado.
     */
    private String rivalNombre;

    private LocalDateTime fecha;
    private String estado; // Programado, En Curso, Finalizado
}