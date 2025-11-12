<?php
namespace Models;

/**
 * Modelo Configuracion - Gestiona las preferencias del usuario
 * Maneja personalización visual y de sonido
 */
class Configuracion {
    private $db;
    
    public function __construct() {
        $this->db = \Database::getInstance()->getConnection();
    }
    
    /**
     * Obtiene la configuración de un usuario
     */
    public function getByUsuarioId($usuarioId) {
        $sql = "SELECT * FROM configuraciones WHERE usuario_id = :usuario_id LIMIT 1";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':usuario_id' => $usuarioId]);
        return $stmt->fetch();
    }
    
    /**
     * Crea una configuración por defecto para un usuario
     */
    public function create($usuarioId) {
        $sql = "INSERT INTO configuraciones (usuario_id, tema, tamano_fuente, sonido_activo) 
                VALUES (:usuario_id, 'claro', 'normal', TRUE)";
        $stmt = $this->db->prepare($sql);
        return $stmt->execute([':usuario_id' => $usuarioId]);
    }
    
    /**
     * Actualiza la configuración de un usuario
     */
    public function update($usuarioId, $tema, $tamanoFuente, $sonidoActivo) {
        $sql = "UPDATE configuraciones 
                SET tema = :tema, tamano_fuente = :tamano_fuente, sonido_activo = :sonido_activo
                WHERE usuario_id = :usuario_id";
        $stmt = $this->db->prepare($sql);
        return $stmt->execute([
            ':usuario_id' => $usuarioId,
            ':tema' => $tema,
            ':tamano_fuente' => $tamanoFuente,
            ':sonido_activo' => $sonidoActivo
        ]);
    }
    
    /**
     * Obtiene o crea la configuración de un usuario
     */
    public function getOrCreate($usuarioId) {
        $config = $this->getByUsuarioId($usuarioId);
        if (!$config) {
            $this->create($usuarioId);
            $config = $this->getByUsuarioId($usuarioId);
        }
        return $config;
    }
}