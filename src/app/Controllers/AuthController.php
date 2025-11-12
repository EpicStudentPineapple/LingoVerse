<?php
namespace Controllers;

use Models\Usuario;
use Models\Configuracion;

/**
 * Controlador de Autenticación
 * Gestiona registro, login, logout y obtención de usuario actual
 */
class AuthController {
    private $usuarioModel;
    private $configModel;
    
    public function __construct() {
        $this->usuarioModel = new Usuario();
        $this->configModel = new Configuracion();
    }
    
    /**
     * Registra un nuevo usuario
     */
    public function register() {
        header('Content-Type: application/json');
        
        // Obtener datos del cuerpo de la petición
        $data = json_decode(file_get_contents('php://input'), true);
        
        // Validar datos
        if (!isset($data['username']) || !isset($data['email']) || !isset($data['password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Faltan datos requeridos']);
            return;
        }
        
        // Validar longitud de username
        if (strlen($data['username']) < 3 || strlen($data['username']) > 50) {
            http_response_code(400);
            echo json_encode(['error' => 'El nombre de usuario debe tener entre 3 y 50 caracteres']);
            return;
        }
        
        // Validar formato de email
        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            echo json_encode(['error' => 'Email inválido']);
            return;
        }
        
        // Validar longitud de contraseña
        if (strlen($data['password']) < 6) {
            http_response_code(400);
            echo json_encode(['error' => 'La contraseña debe tener al menos 6 caracteres']);
            return;
        }
        
        // Verificar si el usuario ya existe
        if ($this->usuarioModel->findByUsername($data['username'])) {
            http_response_code(409);
            echo json_encode(['error' => 'El nombre de usuario ya está en uso']);
            return;
        }
        
        // Verificar si el email ya existe
        if ($this->usuarioModel->findByEmail($data['email'])) {
            http_response_code(409);
            echo json_encode(['error' => 'El email ya está registrado']);
            return;
        }
        
        // Crear usuario
        try {
            if ($this->usuarioModel->create($data['username'], $data['email'], $data['password'])) {
                // Obtener el usuario recién creado
                $user = $this->usuarioModel->findByUsername($data['username']);
                
                // Crear configuración por defecto
                $this->configModel->create($user['id']);
                
                // Iniciar sesión automáticamente
                $_SESSION['user_id'] = $user['id'];
                $_SESSION['username'] = $user['username'];
                
                http_response_code(201);
                echo json_encode([
                    'message' => 'Usuario registrado exitosamente',
                    'user' => [
                        'id' => $user['id'],
                        'username' => $user['username'],
                        'email' => $user['email']
                    ]
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Error al crear el usuario']);
            }
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error del servidor: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Inicia sesión de un usuario
     */
    public function login() {
        header('Content-Type: application/json');
        
        // Obtener datos del cuerpo de la petición
        $data = json_decode(file_get_contents('php://input'), true);
        
        // Validar datos
        if (!isset($data['username']) || !isset($data['password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Faltan credenciales']);
            return;
        }
        
        // Buscar usuario
        $user = $this->usuarioModel->findByUsername($data['username']);
        
        if (!$user) {
            http_response_code(401);
            echo json_encode(['error' => 'Credenciales inválidas']);
            return;
        }
        
        // Verificar contraseña
        if (!$this->usuarioModel->verifyPassword($user, $data['password'])) {
            http_response_code(401);
            echo json_encode(['error' => 'Credenciales inválidas']);
            return;
        }
        
        // Iniciar sesión
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['username'] = $user['username'];
        
        echo json_encode([
            'message' => 'Inicio de sesión exitoso',
            'user' => [
                'id' => $user['id'],
                'username' => $user['username'],
                'email' => $user['email']
            ]
        ]);
    }
    
    /**
     * Cierra sesión del usuario
     */
    public function logout() {
        header('Content-Type: application/json');
        
        // Destruir sesión
        session_destroy();
        
        echo json_encode(['message' => 'Sesión cerrada exitosamente']);
    }
    
    /**
     * Obtiene el usuario actual
     */
    public function getUser() {
        header('Content-Type: application/json');
        
        // Verificar si hay sesión activa
        if (!isset($_SESSION['user_id'])) {
            http_response_code(401);
            echo json_encode(['error' => 'No hay sesión activa']);
            return;
        }
        
        // Obtener usuario
        $user = $this->usuarioModel->findById($_SESSION['user_id']);
        
        if (!$user) {
            http_response_code(404);
            echo json_encode(['error' => 'Usuario no encontrado']);
            return;
        }
        
        echo json_encode([
            'user' => [
                'id' => $user['id'],
                'username' => $user['username'],
                'email' => $user['email']
            ]
        ]);
    }
}