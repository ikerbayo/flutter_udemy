package es.sl1iickdev.loloapi.dtos;

import lombok.Data;

@Data
public class ClubDTO {
    private Long id;
    private String nombre;
    private String logo;
    private int totalEquipos;
    private Long propietarioId;
}