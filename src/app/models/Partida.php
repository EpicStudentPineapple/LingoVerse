<?php
namespace Models;

/**
 * Modelo Partida - Gestiona las partidas del juego
 * Maneja el CRUD de partidas y su relación con usuarios
 */
class Partida {
    private $db;
    
    public function __construct() {
        $this->db = \Database::getInstance()->getConnection();
    }
    
    /**
     * Crea una nueva partida
     */
    public function create($usuarioId, $palabraSecreta) {
        $sql = "INSERT INTO partidas (usuario_id, palabra_secreta, intentos_usados, intentos_maximos, estado, puntuacion, tiempo_total) 
                VALUES (:usuario_id, :palabra_secreta, 0, 5, 'en_curso', 0, 0)";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([
            ':usuario_id' => $usuarioId,
            ':palabra_secreta' => $palabraSecreta
        ]);
        return $this->db->lastInsertId();
    }
    
    /**
     * Obtiene una partida por ID
     */
    public function findById($id) {
        $sql = "SELECT * FROM partidas WHERE id = :id LIMIT 1";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);
        return $stmt->fetch();
    }
    
    /**
     * Actualiza el estado de una partida
     */
    public function update($id, $intentosUsados, $estado, $puntuacion, $tiempoTotal) {
        $sql = "UPDATE partidas 
                SET intentos_usados = :intentos_usados, 
                    estado = :estado, 
                    puntuacion = :puntuacion,
                    tiempo_total = :tiempo_total
                WHERE id = :id";
        $stmt = $this->db->prepare($sql);
        return $stmt->execute([
            ':id' => $id,
            ':intentos_usados' => $intentosUsados,
            ':estado' => $estado,
            ':puntuacion' => $puntuacion,
            ':tiempo_total' => $tiempoTotal
        ]);
    }
    
    /**
     * Obtiene las mejores partidas para el ranking
     */
    public function getTopPartidas($limit = 10) {
        $sql = "SELECT u.username, p.puntuacion, p.intentos_usados, p.tiempo_total, p.created_at
                FROM partidas p
                INNER JOIN usuarios u ON p.usuario_id = u.id
                WHERE p.estado = 'ganada'
                ORDER BY p.puntuacion DESC, p.tiempo_total ASC
                LIMIT :limit";
        $stmt = $this->db->prepare($sql);
        $stmt->bindValue(':limit', $limit, \PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }
    
    /**
     * Guarda un intento individual
     */
    public function saveIntento($partidaId, $palabraIntento, $numeroIntento, $resultado, $tiempoUsado) {
        $sql = "INSERT INTO intentos (partida_id, palabra_intento, numero_intento, resultado, tiempo_usado) 
                VALUES (:partida_id, :palabra_intento, :numero_intento, :resultado, :tiempo_usado)";
        $stmt = $this->db->prepare($sql);
        return $stmt->execute([
            ':partida_id' => $partidaId,
            ':palabra_intento' => $palabraIntento,
            ':numero_intento' => $numeroIntento,
            ':resultado' => json_encode($resultado),
            ':tiempo_usado' => $tiempoUsado
        ]);
    }
}