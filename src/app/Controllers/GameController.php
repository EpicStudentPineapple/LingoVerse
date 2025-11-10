<?php
namespace Controllers;

use Models\Partida;
use Models\Diccionario;

/**
 * Controlador del Juego
 * Gestiona el inicio de partidas, validación de palabras y finalización
 */
class GameController {
    private $partidaModel;
    private $diccionarioModel;
    
    public function __construct() {
        $this->partidaModel = new Partida();
        $this->diccionarioModel = new Diccionario();
    }
    
    /**
     * Verifica autenticación del usuario
     */
    private function checkAuth() {
        if (!isset($_SESSION['user_id'])) {
            http_response_code(401);
            echo json_encode(['error' => 'Debe iniciar sesión para jugar']);
            return false;
        }
        return true;
    }
    
    /**
     * Inicia una nueva partida
     */
    public function start() {
        header('Content-Type: application/json');
                
        if (!$this->checkAuth()) {
            return;
        }
        
        try {
            // Obtener palabra aleatoria
            $palabra = $this->diccionarioModel->getPalabraAleatoria(5);
            
            if (!$palabra) {
                http_response_code(500);
                echo json_encode(['error' => 'No se pudo obtener una palabra']);
                return;
            }
            
            // Crear nueva partida
            $partidaId = $this->partidaModel->create($_SESSION['user_id'], $palabra);
            
            // Guardar ID de partida en sesión
            $_SESSION['partida_id'] = $partidaId;
            
            echo json_encode([
                'partida_id' => $partidaId,
                'longitud_palabra' => strlen($palabra),
                'intentos_maximos' => 5
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al iniciar partida: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Valida una palabra introducida por el jugador
     */
    public function validateWord() {
        header('Content-Type: application/json');
        
        if (!$this->checkAuth()) {
            return;
        }
        
        // Obtener datos
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($data['palabra']) || !isset($data['partida_id']) || !isset($data['numero_intento']) || !isset($data['tiempo_usado'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Faltan datos requeridos']);
            return;
        }
        
        $palabra = strtoupper($data['palabra']);
        $partidaId = $data['partida_id'];
        $numeroIntento = $data['numero_intento'];
        $tiempoUsado = $data['tiempo_usado'];
        
        // Verificar que la partida pertenece al usuario
        $partida = $this->partidaModel->findById($partidaId);
        
        if (!$partida || $partida['usuario_id'] != $_SESSION['user_id']) {
            http_response_code(403);
            echo json_encode(['error' => 'No tiene permiso para esta partida']);
            return;
        }
        
        // Verificar si la palabra existe en el diccionario
        if (!$this->diccionarioModel->existePalabra($palabra)) {
            echo json_encode([
                'valida' => false,
                'error' => 'La palabra no existe en el diccionario'
            ]);
            return;
        }
        
        // Comparar con la palabra secreta
        $palabraSecreta = $partida['palabra_secreta'];
        $resultado = $this->compararPalabras($palabra, $palabraSecreta);
        
        // Guardar intento
        $this->partidaModel->saveIntento($partidaId, $palabra, $numeroIntento, $resultado, $tiempoUsado);
        
        // Verificar si ganó
        $ganado = ($palabra === $palabraSecreta);
        
        echo json_encode([
            'valida' => true,
            'resultado' => $resultado,
            'ganado' => $ganado,
            'palabra_secreta' => $ganado ? $palabraSecreta : null
        ]);
    }
    
    /**
     * Compara dos palabras y retorna el resultado
     * 0 = letra no está, 1 = letra existe pero en otra posición, 2 = letra en posición correcta
     */
    private function compararPalabras($intento, $secreta) {
        $resultado = [];
        $longitudSecreta = strlen($secreta);
        $letrasSecreta = str_split($secreta);
        $letrasUsadas = array_fill(0, $longitudSecreta, false);
        
        // Primera pasada: marcar aciertos exactos
        for ($i = 0; $i < strlen($intento); $i++) {
            if ($intento[$i] === $secreta[$i]) {
                $resultado[$i] = 2; // Posición correcta (verde)
                $letrasUsadas[$i] = true;
            } else {
                $resultado[$i] = 0; // Por defecto no está (rojo)
            }
        }
        
        // Segunda pasada: marcar letras que existen pero en otra posición
        for ($i = 0; $i < strlen($intento); $i++) {
            if ($resultado[$i] === 0) { // Si no es acierto exacto
                for ($j = 0; $j < $longitudSecreta; $j++) {
                    if (!$letrasUsadas[$j] && $intento[$i] === $letrasSecreta[$j]) {
                        $resultado[$i] = 1; // Existe pero en otra posición (naranja)
                        $letrasUsadas[$j] = true;
                        break;
                    }
                }
            }
        }
        
        return $resultado;
    }
    
    /**
     * Finaliza una partida
     */
    public function finish() {
        header('Content-Type: application/json');
        
        if (!$this->checkAuth()) {
            return;
        }
        
        // Obtener datos
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($data['partida_id']) || !isset($data['intentos_usados']) || !isset($data['ganado']) || !isset($data['tiempo_total'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Faltan datos requeridos']);
            return;
        }
        
        $partidaId = $data['partida_id'];
        $intentosUsados = $data['intentos_usados'];
        $ganado = $data['ganado'];
        $tiempoTotal = $data['tiempo_total'];
        
        // Verificar que la partida pertenece al usuario
        $partida = $this->partidaModel->findById($partidaId);
        
        if (!$partida || $partida['usuario_id'] != $_SESSION['user_id']) {
            http_response_code(403);
            echo json_encode(['error' => 'No tiene permiso para esta partida']);
            return;
        }
        
        // Calcular puntuación (basada en intentos restantes y tiempo)
        $puntuacion = 0;
        if ($ganado) {
            $intentosRestantes = 5 - $intentosUsados;
            $puntuacion = ($intentosRestantes * 200) + max(0, 300 - $tiempoTotal);
        }
        
        $estado = $ganado ? 'ganada' : 'perdida';
        
        // Actualizar partida
        $this->partidaModel->update($partidaId, $intentosUsados, $estado, $puntuacion, $tiempoTotal);
        
        // Limpiar sesión de partida
        unset($_SESSION['partida_id']);
        
        echo json_encode([
            'message' => 'Partida finalizada',
            'puntuacion' => $puntuacion,
            'estado' => $estado
        ]);
    }

    public function forceFinish() {
        
    }
}