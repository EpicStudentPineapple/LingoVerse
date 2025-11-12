<?php
/**
 * Configuración de la base de datos
 * Maneja la conexión PDO con MySQL
 */

class Database {
    private static $instance = null;
    private $connection;
    
    // Configuración desde variables de entorno
    private $host;
    private $dbname;
    private $username;
    private $password;
    
    private function __construct() {
        // Obtener configuración desde variables de entorno o usar valores por defecto
        $this->host = getenv('DB_HOST') ?: 'db';
        $this->dbname = getenv('DB_DATABASE') ?: 'lingo_db';
        $this->username = getenv('DB_USERNAME') ?: 'lingo_user';
        $this->password = getenv('DB_PASSWORD') ?: 'lingo_pass';
        
        try {
            $dsn = "mysql:host={$this->host};dbname={$this->dbname};charset=utf8mb4";
            $this->connection = new PDO($dsn, $this->username, $this->password);
            $this->connection->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->connection->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            die("Error de conexión: " . $e->getMessage());
        }
    }
    
    /**
     * Obtiene la instancia única de la base de datos (Singleton)
     */
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }
    
    /**
     * Obtiene la conexión PDO
     */
    public function getConnection() {
        return $this->connection;
    }
    
    // Prevenir clonación
    private function __clone() {}
    
    // Prevenir unserialize
    public function __wakeup() {
        throw new Exception("No se puede deserializar singleton");
    }
}