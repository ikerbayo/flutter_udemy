package es.sl1iickdev.loloapi.models;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "match_events")
@Data
public class MatchEvent {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "match_id")
    private Match match;

    @ManyToOne
    @JoinColumn(name = "player_id")
    private Player player;

    @Enumerated(EnumType.STRING)
    private EventType tipo;

    private Integer minuto;

    @Column(name = "valor", columnDefinition = "INT DEFAULT 1")
    private Integer valor;

    @Column(name = "descripcion_personalizada")
    private String descripcionPersonalizada;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "creado_por_user_id")
    private User creadoPorUser;

}