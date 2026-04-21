package es.sl1iickdev.loloapi.dtos;

import lombok.Data;

@Data
public class MatchEventDTO {
    private Long id;
    private String tipo;
    private Integer minuto;
    private Integer valor;
    private String playerNombre;
    private Long playerId;
    private String descripcionPersonalizada;
    private Long creadoPorUserId;
}