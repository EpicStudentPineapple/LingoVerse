<?php
namespace Models;

/**
 * Modelo Usuario - Gestiona los datos de usuarios
 * Interactúa con la tabla 'usuarios' en la base de datos
 */
class Usuario {
    private $db;
    
    public function __construct() {
        $this->db = \Database::getInstance()->getConnection();
    }
    
    /**
     * Crea un nuevo usuario
     */
    public function create($username, $email, $password) {
        $sql = "INSERT INTO usuarios (username, email, password) VALUES (:username, :email, :password)";
        $stmt = $this->db->prepare($sql);
        $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
        
        return $stmt->execute([
            ':username' => $username,
            ':email' => $email,
            ':password' => $hashedPassword
        ]);
    }
    
    /**
     * Busca un usuario por nombre de usuario
     */
    public function findByUsername($username) {
        $sql = "SELECT * FROM usuarios WHERE username = :username LIMIT 1";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':username' => $username]);
        return $stmt->fetch();
    }
    
    /**
     * Busca un usuario por email
     */
    public function findByEmail($email) {
        $sql = "SELECT * FROM usuarios WHERE email = :email LIMIT 1";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':email' => $email]);
        return $stmt->fetch();
    }
    
    /**
     * Busca un usuario por ID
     */
    public function findById($id) {
        $sql = "SELECT id, username, email, created_at FROM usuarios WHERE id = :id LIMIT 1";
        $stmt = $this->db->prepare($sql);
        $stmt->execute([':id' => $id]);
        return $stmt->fetch();
    }
    
    /**
     * Verifica la contraseña de un usuario
     */
    public function verifyPassword($user, $password) {
        return password_verify($password, $user['password']);
    }
}