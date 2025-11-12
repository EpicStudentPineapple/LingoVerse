<?php
namespace Controllers;

use Models\Configuracion;

/**
 * Controlador de Configuración
 * Gestiona las preferencias personalizadas del usuario
 */
class ConfigController {
    private $configModel;
    
    public function __construct() {
        $this->configModel = new Configuracion();
    }
    
    /**
     * Verifica autenticación del usuario
     */
    private function checkAuth() {
        if (!isset($_SESSION['user_id'])) {
            http_response_code(401);
            echo json_encode(['error' => 'Debe iniciar sesión']);
            return false;
        }
        return true;
    }
    
    /**
     * Obtiene la configuración del usuario
     */
    public function getConfig() {
        header('Content-Type: application/json');
        
        if (!$this->checkAuth()) {
            return;
        }
        
        try {
            // Obtener o crear configuración
            $config = $this->configModel->getOrCreate($_SESSION['user_id']);
            
            echo json_encode([
                'config' => [
                    'tema' => $config['tema'],
                    'tamano_fuente' => $config['tamano_fuente'],
                    'sonido_activo' => (bool)$config['sonido_activo']
                ]
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener configuración: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Actualiza la configuración del usuario
     */
    public function updateConfig() {
        header('Content-Type: application/json');
        
        if (!$this->checkAuth()) {
            return;
        }
        
        // Obtener datos
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($data['tema']) || !isset($data['tamano_fuente']) || !isset($data['sonido_activo'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Faltan datos de configuración']);
            return;
        }
        
        // Validar valores
        $temasValidos = ['claro', 'oscuro'];
        $tamanosValidos = ['pequeño', 'normal', 'grande'];
        
        if (!in_array($data['tema'], $temasValidos)) {
            http_response_code(400);
            echo json_encode(['error' => 'Tema inválido']);
            return;
        }
        
        if (!in_array($data['tamano_fuente'], $tamanosValidos)) {
            http_response_code(400);
            echo json_encode(['error' => 'Tamaño de fuente inválido']);
            return;
        }
        
        try {
            // Actualizar configuración
            $this->configModel->update(
                $_SESSION['user_id'],
                $data['tema'],
                $data['tamano_fuente'],
                $data['sonido_activo']
            );
            
            echo json_encode([
                'message' => 'Configuración actualizada exitosamente',
                'config' => [
                    'tema' => $data['tema'],
                    'tamano_fuente' => $data['tamano_fuente'],
                    'sonido_activo' => (bool)$data['sonido_activo']
                ]
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al actualizar configuración: ' . $e->getMessage()]);
        }
    }
}