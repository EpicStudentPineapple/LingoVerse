<?php
namespace Controllers;

use Models\Partida;

/**
 * Controlador de Ranking
 * Gestiona la obtención del ranking de mejores jugadores
 */
class RankingController {
    private $partidaModel;
    
    public function __construct() {
        $this->partidaModel = new Partida();
    }
    
    /**
     * Obtiene el ranking de mejores jugadores
     */
    public function getRanking() {
        header('Content-Type: application/json');
        
        try {
            // Obtener top 10 partidas
            $ranking = $this->partidaModel->getTopPartidas(10);
            
            // Formatear datos
            $rankingFormateado = array_map(function($item, $index) {
                return [
                    'posicion' => $index + 1,
                    'username' => $item['username'],
                    'puntuacion' => (int)$item['puntuacion'],
                    'intentos' => (int)$item['intentos_usados'],
                    'tiempo' => (int)$item['tiempo_total'],
                    'fecha' => date('d/m/Y H:i', strtotime($item['created_at']))
                ];
            }, $ranking, array_keys($ranking));
            
            echo json_encode([
                'ranking' => $rankingFormateado
            ]);
        } catch (\Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Error al obtener ranking: ' . $e->getMessage()]);
        }
    }
}