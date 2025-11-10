<?php
namespace Models;

/**
 * Modelo Diccionario - Gestiona las palabras válidas del juego
 * Permite obtener palabras aleatorias y validar palabras introducidas
 */
class Diccionario {
    private $db;
    
    public function __construct() {
        $this->db = \Database::getInstance()->getConnection();
    }
    
    /**
     * Obtiene una palabra aleatoria de una longitud específica
     */
    public function getPalabraAleatoria($longitud = 5) {
        $sql = "SELECT palabra FROM diccionario WHERE longitud = :longitud ORDER BY RAND() LIMIT 1";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':longitud' => $longitud]);
        $result = $stmt->fetch();
        return $result ? $result['palabra'] : null;
    }
    
    /**
     * Verifica si una palabra existe en el diccionario
     */
    public function existePalabra($palabra) {
        $sql = "SELECT COUNT(*) as count FROM diccionario WHERE palabra = :palabra";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':palabra' => strtoupper($palabra)]);
        $result = $stmt->fetch();
        return $result['count'] > 0;
    }
    
    /**
     * Obtiene todas las palabras de una longitud específica
     */
    public function getPalabrasPorLongitud($longitud) {
        $sql = "SELECT palabra FROM diccionario WHERE longitud = :longitud";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':longitud' => $longitud]);
        return $stmt->fetchAll(\PDO::FETCH_COLUMN);
    }
}