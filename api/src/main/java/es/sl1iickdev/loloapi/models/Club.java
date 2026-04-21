package es.sl1iickdev.loloapi.models;

import jakarta.persistence.*;
import lombok.Data;
import java.util.List;

@Entity
@Table(name = "clubs")
@Data
public class Club {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String nombre;

    private String logo;

    // Relación opcional: Un club tiene muchos equipos
    @OneToMany(mappedBy = "club", cascade = CascadeType.ALL)
    private List<Team> teams;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "propietario_id")
    private User propietario;
}