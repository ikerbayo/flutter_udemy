package es.sl1iickdev.loloapi.models;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
@Table(name = "players")
public class Player {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Relación Muchos a Uno: Muchos jugadores pertenecen a un Equipo
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id") // Nombre de la columna FK en MariaDB
    private Team team;

    private String nombre;

    private int dorsal;

    @Column(name = "posicion_principal")
    private String posicionPrincipal;

    @Column(name = "tarjetas_acumuladas")
    private int tarjetasAcumuladas;

    private String foto;
}