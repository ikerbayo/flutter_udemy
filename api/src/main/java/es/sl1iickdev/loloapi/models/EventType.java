package es.sl1iickdev.loloapi.models;

public enum EventType {
    // --- ATAQUE Y GOLES ---
    Gol,
    Asistencia,
    Tiro_Puerta,
    Tiro_Fuera,
    Penalti_Marcado,
    Penalti_Fallado,
    Fuera_Juego,

    // --- DEFENSA Y PORTERÍA ---
    Falta_Cometida,
    Falta_Recibida,
    Robo,
    Intercepcion,
    Parada_Portero,
    Gol_Encajado,

    // --- DISTRIBUCIÓN ---
    Pase_Exitoso,
    Pase_Fallado,
    Centro_Area,

    // --- SANCIONES Y CAMBIOS ---
    Amarilla,
    Roja,
    Cambio_Entra,
    Cambio_Sale,

    // --- CONTROL DE PARTIDO Y ERRORES ---
    Inicio_Partido,
    Fin_Partido,
    Gol_Anulado,     // Para cuando el VAR o el árbitro lo echan atrás
    Evento_Erroneo,  // Para marcar un evento que debe ser ignorado en stats
    Gol_Propia_Puerta,
    Personalizado    // Evento manual introducido por un usuario (ej. padre)
}