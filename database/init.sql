-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS lingo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE lingo_db;

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de diccionario (palabras válidas)
CREATE TABLE IF NOT EXISTS diccionario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    palabra VARCHAR(10) NOT NULL,
    longitud INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_palabra (palabra),
    INDEX idx_longitud (longitud)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de partidas
CREATE TABLE IF NOT EXISTS partidas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    palabra_secreta VARCHAR(10) NOT NULL,
    intentos_usados INT DEFAULT 0,
    intentos_maximos INT DEFAULT 5,
    estado ENUM('en_curso', 'ganada', 'perdida') DEFAULT 'en_curso',
    puntuacion INT DEFAULT 0,
    tiempo_total INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id),
    INDEX idx_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de intentos individuales
CREATE TABLE IF NOT EXISTS intentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    partida_id INT NOT NULL,
    palabra_intento VARCHAR(10) NOT NULL,
    numero_intento INT NOT NULL,
    resultado JSON NOT NULL,
    tiempo_usado INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (partida_id) REFERENCES partidas(id) ON DELETE CASCADE,
    INDEX idx_partida (partida_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de configuración de usuario (personalización)
CREATE TABLE IF NOT EXISTS configuraciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    tema VARCHAR(20) DEFAULT 'claro',
    tamano_fuente VARCHAR(20) DEFAULT 'normal',
    sonido_activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE KEY unique_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertar palabras de ejemplo en el diccionario (5 letras)
INSERT INTO diccionario (palabra, longitud) VALUES
('ABETO',5), ('ACIDO',5), ('ACTOR',5), ('ACUDE',5), ('AFINO',5),
('AGORA',5), ('AGUDO',5), ('ALADO',5), ('ALDEA',5), ('ALTAR',5),
('AMADO',5), ('AMIGA',5), ('AMIGO',5), ('ANDAR',5), ('ANGEL',5),
('ANCHO',5), ('ANIMA',5), ('ANIMO',5), ('ANTES',5), ('ARENA',5),
('ARMAR',5), ('AROMA',5), ('ASADO',5), ('ASILO',5), ('ASTRO',5),
('AUTOR',5), ('AVION',5), ('BAILE',5), ('BANDA',5), ('BARCO',5),
('BARRA',5), ('BARRO',5), ('BASAR',5), ('BEBER',5), ('BELLO',5),
('BESAR',5), ('BICHO',5), ('BIZCO',5), ('BLUSA',5), ('BOINA',5),
('BRAVA',5), ('BRAVO',5), ('BRISA',5), ('BUENO',5), ('BURRO',5),
('CABRA',5), ('CALAR',5), ('CALLE',5), ('CALOR',5), ('CAMPO',5),
('CANAL',5), ('CANTO',5), ('CAPAZ',5), ('CARGA',5), ('CARNE',5),
('CASTA',5), ('CESTA',5), ('CHICA',5), ('CHICO',5), ('CIELO',5),
('CINCO',5), ('CIRCO',5), ('CLAVE',5), ('COBRA',5), ('COCHE',5),
('COLOR',5), ('CORAL',5), ('CREER',5), ('CRUCE',5), ('CUIDA',5),
('CURSO',5), ('DANZA',5), ('DEJAR',5), ('DIETA',5), ('DOLOR',5),
('DONDE',5), ('DULCE',5), ('ECHAR',5), ('EDUCA',5), ('EMITE',5),
('ENTRA',5), ('ERROR',5), ('ESTAR',5), ('EXITO',5), ('FALDA',5),
('FAVOR',5), ('FERIA',5), ('FELIZ',5), ('FIJAR',5), ('FIRME',5),
('FLACO',5), ('FLORA',5), ('FONDO',5), ('FUERA',5), ('GALLO',5),
('GENTE',5), ('GIRAR',5), ('GRANO',5), ('GRITO',5), ('GUAPA',5),
('GUION',5), ('HACER',5), ('HIELO',5), ('HONOR',5), ('IDEAL',5),
('IGUAL',5), ('JUGAR',5), ('JUSTO',5), ('LENTO',5), ('LETRA',5),
('LIMON',5), ('LINEA',5), ('LLAVE',5), ('MADRE',5), ('MAGIA',5),
('MAREA',5), ('METAL',5), ('MIEDO',5), ('MIRAR',5), ('MOLDE',5),
('MONTE',5), ('MORIR',5), ('MUJER',5), ('MUNDO',5), ('NACER',5),
('NAVAL',5), ('NIEVE',5), ('NOBLE',5), ('NORMA',5), ('OCASO',5),
('OCUPA',5), ('OPERA',5), ('ORDEN',5), ('OREJA',5), ('OSADO',5),
('OXIDO',5), ('PALMA',5), ('PAPEL',5), ('PARAR',5), ('PASTA',5),
('PECHO',5), ('PELAR',5), ('PERRO',5), ('PESCA',5), ('PILAR',5),
('PINTO',5), ('PISAR',5), ('PLATA',5), ('PLUMA',5), ('POLEN',5),
('PORTE',5), ('PRADO',5), ('PRISA',5), ('PUEDO',5), ('PUNTA',5),
('QUESO',5), ('QUIEN',5), ('RADAR',5), ('RASGO',5), ('RAZON',5),
('REINO',5), ('REMAR',5), ('RENTA',5), ('RESTA',5), ('RIEGO',5),
('RIGOR',5), ('RITMO',5), ('RIZAR',5), ('RODAR',5), ('ROMPE',5),
('RUEDA',5), ('RUMOR',5), ('SABER',5), ('SABIO',5), ('SALIR',5),
('SALTA',5), ('SANTO',5), ('SELVA',5), ('SILLA',5), ('SITIO',5),
('SOBRA',5), ('SOLAR',5), ('SONAR',5), ('SUAVE',5), ('SUELO',5),
('SUITE',5), ('TALLA',5), ('TARDA',5), ('TARRO',5), ('TECHO',5),
('TEMOR',5), ('TENOR',5), ('TERCO',5), ('TIARA',5), ('TINTO',5),
('TOCAR',5), ('TOMAR',5), ('TORRE',5), ('TRABA',5), ('TRAMA',5),
('TRATO',5), ('TROPA',5), ('TROZO',5), ('TUNEL',5), ('UNICO',5),
('UNION',5), ('USADO',5), ('VALOR',5), ('VARON',5), ('VENIR',5),
('VENTA',5), ('VERDE',5), ('VIAJE',5), ('VIENE',5), ('VIGOR',5),
('VISTA',5), ('VIVIR',5), ('VOLAR',5), ('VUELO',5), ('YERBA',5),
('YUNTA',5), ('ZAFAR',5), ('ZURDO',5), ('ALTOS',5), ('CIEGA',5), 
('FRESA',5), ('LUCES',5), ('LUNAR',5), ('NOTAR',5), ('NUBAR',5), 
('OBRAR',5), ('OTRAS',5), ('PECAR',5), ('POEMA',5), ('RAMAL',5), 
('ROCIO',5), ('RUTAR',5), ('SALON',5), ('SERIO',5), ('TORNO',5), 
('VELAR',5), ('VIVAZ',5), ('ZORRO',5), ('ZAFIO',5);


-- Insertar usuario de prueba (contraseña: test123)
INSERT INTO usuarios (username, email, password) VALUES
('testuser', 'test@lingo.local', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- Insertar configuración por defecto para el usuario de prueba
INSERT INTO configuraciones (usuario_id, tema, tamano_fuente, sonido_activo) VALUES
(1, 'claro', 'normal', TRUE);