package es.sl1iickdev.loloapi.dtos;

import lombok.Data;

@Data
public class MatchEventRequestDTO {
    private Long matchId;
    private Long playerId;
    private String tipo;    // "Gol", "Amarilla", etc.
    private Integer minuto;
    private Integer valor; // +1 or -1
    private String descripcionPersonalizada;
    private Long creadoPorUserId;
}
