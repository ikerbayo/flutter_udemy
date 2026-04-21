# Documentación de Lologol API

A continuación se detallan todos los endpoints disponibles en la API, junto con los cuerpos de petición (bodies) necesarios y ejemplos.

Todas las peticiones a endpoints protegidos deben incluir el header:
`Authorization: Bearer <tu_token_jwt>`

---

## 1. Autenticación (`/api/auth`)

### Registrar un nuevo usuario
- **Método**: `POST`
- **Ruta**: `/api/auth/register`
- **Body (`RegisterRequestDTO`)**:
```json
{
  "nombre": "Juan Pérez",
  "email": "juan@example.com",
  "password": "PasswordSegura123"
}
```

### Iniciar sesión
- **Método**: `POST`
- **Ruta**: `/api/auth/login`
- **Body (`AuthRequestDTO`)**:
```json
{
  "email": "juan@example.com",
  "password": "PasswordSegura123"
}
```

---

## 2. Gestión de Clubes (`/api/clubs`)

### Obtener todos los clubes
- **Método**: `GET`
- **Ruta**: `/api/clubs`

### Obtener un club por su ID
- **Método**: `GET`
- **Ruta**: `/api/clubs/{id}`
- **Ejemplo**: `GET /api/clubs/1`

### Crear un club
- **Método**: `POST`
- **Ruta**: `/api/clubs`
- **Body (`ClubDTO`)**:
```json
{
  "nombre": "Real Madrid FC",
  "logo": "https://url-del-logo.com/logo.png",
  "totalEquipos": 0,
  "propietarioId": 1
}
```

---

## 3. Gestión de Equipos (`/api/teams`)

### Obtener mis equipos (los gestionados por el usuario logueado)
- **Método**: `GET`
- **Ruta**: `/api/teams/my-teams`

### Obtener equipos de un club en concreto
- **Método**: `GET`
- **Ruta**: `/api/teams/club/{clubId}`
- **Ejemplo**: `GET /api/teams/club/1`

### Obtener un equipo por su ID
- **Método**: `GET`
- **Ruta**: `/api/teams/{id}`
- **Ejemplo**: `GET /api/teams/5`

### Crear un equipo
- **Método**: `POST`
- **Ruta**: `/api/teams`
- **Body (`TeamDTO`)**:
```json
{
  "nombre": "Real Madrid Alevín",
  "categoriaFutbol": "Fútbol 7",
  "clubId": 1,
  "escudoUrl": "https://url-escudo.com/escudo.png"
}
```

---

## 4. Gestión de Jugadores (`/api/players`)

### Obtener jugadores de un equipo
- **Método**: `GET`
- **Ruta**: `/api/players/team/{teamId}`
- **Ejemplo**: `GET /api/players/team/5`

### Obtener un jugador por su ID
- **Método**: `GET`
- **Ruta**: `/api/players/{id}`
- **Ejemplo**: `GET /api/players/10`

### Crear un jugador
- **Método**: `POST`
- **Ruta**: `/api/players`
- **Body (`PlayerDTO`)**:
```json
{
  "nombre": "Leo Messi",
  "dorsal": 10,
  "posicion": "Delantero",
  "foto": "https://url-foto.com/messi.png",
  "teamId": 5
}
```

---

## 5. Gestión de Partidos (`/api/matches`)

### Obtener todos los partidos
- **Método**: `GET`
- **Ruta**: `/api/matches`

### Obtener un partido por su ID
- **Método**: `GET`
- **Ruta**: `/api/matches/{id}`
- **Ejemplo**: `GET /api/matches/3`

### Actualizar el estado de un partido
- **Método**: `PATCH`
- **Ruta**: `/api/matches/{id}/status?estado={estado}`
- **Ejemplo**: `PATCH /api/matches/3/status?estado=En Curso`
- **Estados posibles**: `Programado`, `En Curso`, `Finalizado`

### Crear un partido
- **Método**: `POST`
- **Ruta**: `/api/matches`
- **Body (`MatchDTO`)**:
```json
{
  "teamHomeId": 5,
  "teamAwayId": 8,
  "fecha": "2024-05-15T18:30:00"
}
```

---

## 6. Eventos de Partido (`/api/events`)
*(Estos endpoints permiten registrar goles, tarjetas o faltas dentro de un partido).*

### Obtener eventos de un partido
- **Método**: `GET`
- **Ruta**: `/api/events/{matchId}`
- **Ejemplo**: `GET /api/events/3`

### Registrar un único evento de partido
- **Método**: `POST`
- **Ruta**: `/api/events`
- **Body (`MatchEventRequestDTO`)**:
```json
{
  "matchId": 3,
  "playerId": 10,
  "tipo": "Gol",
  "minuto": 45,
  "valor": 1,
  "descripcionPersonalizada": "Gol de tiro libre directo",
  "creadoPorUserId": 1
}
```

### Registrar múltiples eventos (Sincronización masiva desde frontend/local)
- **Método**: `POST`
- **Ruta**: `/api/events/sync`
- **Body (`MatchEventBulkRequestDTO`)**:
```json
{
  "events": [
    {
       "matchId": 3,
       "playerId": 10,
       "tipo": "Gol",
       "minuto": 45,
       "valor": 1,
       "descripcionPersonalizada": "Gol de tiro libre directo",
       "creadoPorUserId": 1
    },
    {
       "matchId": 3,
       "playerId": 4,
       "tipo": "Amarilla",
       "minuto": 42,
       "valor": 1,
       "descripcionPersonalizada": "Falta táctica",
       "creadoPorUserId": 1
    }
  ]
}
```

---

## 7. Clasificaciones y Rankings (`/api/standings`)

### Obtener la clasificación de un club 
- **Método**: `GET`
- **Ruta**: `/api/standings/club/{clubId}`
- **Ejemplo**: `GET /api/standings/club/1`

### Obtener mi clasificación (clasificación de los equipos del usuario logueado)
- **Método**: `GET`
- **Ruta**: `/api/standings/my-standings`

### Obtener el historial de partidos de un equipo en concreto
- **Método**: `GET`
- **Ruta**: `/api/standings/team/{teamId}/history`
- **Ejemplo**: `GET /api/standings/team/5/history`
