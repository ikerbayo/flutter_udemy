package es.sl1iickdev.loloapi.models;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

@Entity
@Data
@Table(name = "teams") // Coincide con el SQL
public class Team {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Relación ManyToOne: Muchos equipos pertenecen a un Club
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "club_id") // La FK en tu tabla SQL
    private Club club;

    private String nombre;

    // Usamos String o un Enum de Java para mapear el ENUM('5','7','8','11') de SQL
    @Column(name = "categoria_futbol")
    private String categoriaFutbol;

    // Opcional: Relación inversa para ver los jugadores desde el equipo
    @OneToMany(mappedBy = "team", cascade = CascadeType.ALL)
    private List<Player> players;
}