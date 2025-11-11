<?php
/**
 * Router principal de la aplicación LINGOverse
 * Gestiona todas las rutas y redirige a los controladores correspondientes
 */

session_start();

// Autoloader simple para cargar clases
spl_autoload_register(function ($class) {
    $file = __DIR__ . '/../app/' . str_replace('\\', '/', $class) . '.php';
    if (file_exists($file)) {
        require_once $file;
    }
});

// Configuración de la base de datos
require_once __DIR__ . '/database.php';

// Obtener la URI y el método de la petición
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$method = $_SERVER['REQUEST_METHOD'];

// Rutas de la API
$routes = [
    // Autenticación
    'POST /api/register' => ['Controllers\AuthController', 'register'],
    'POST /api/login' => ['Controllers\AuthController', 'login'],
    'POST /api/logout' => ['Controllers\AuthController', 'logout'],
    'GET /api/user' => ['Controllers\AuthController', 'getUser'],
    
    // Juego
    'GET /api/game/start' => ['Controllers\GameController', 'start'],
    'POST /api/game/validate' => ['Controllers\GameController', 'validateWord'],
    'POST /api/game/finish' => ['Controllers\GameController', 'finish'],
    'POST /api/game/force-finish' => ['Controllers\GameController', 'forceFinish'],
    
    // Ranking
    'GET /api/ranking' => ['Controllers\RankingController', 'getRanking'],
    
    // Configuración
    'GET /api/config' => ['Controllers\ConfigController', 'getConfig'],
    'POST /api/config' => ['Controllers\ConfigController', 'updateConfig'],
];

// Buscar la ruta
$routeKey = "$method $uri";
if (isset($routes[$routeKey])) {
    [$controllerClass, $method] = $routes[$routeKey];
    $controller = new $controllerClass();
    $controller->$method();
} elseif ($uri === '/' || $uri === '/index.php') {
    // Servir el archivo HTML principal
    require_once __DIR__ . '/index.html';
} else {
    // Ruta no encontrada
    header('HTTP/1.1 404 Not Found');
    echo json_encode(['error' => 'Ruta no encontrada']);
}