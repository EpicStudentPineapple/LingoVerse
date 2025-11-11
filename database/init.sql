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
('ABEJA',5), ('ABETO',5), ('ABRIR',5), ('ACERO',5), ('ACIDO',5),
('ACTOR',5), ('ACTUA',5), ('ACUDE',5), ('ADMIN',5), ('AFINO',5),
('AGORA',5), ('AGRIO',5), ('AGUAS',5), ('AGUDO',5), ('AJENO',5),
('ALADO',5), ('ALAMO',5), ('ALDEA',5), ('ALERO',5), ('ALGAS',5),
('ALIAS',5), ('ALTAR',5), ('ALTOS',5), ('AMADO',5), ('AMIGA',5),
('AMIGO',5), ('ANCLA',5), ('ANCHO',5), ('ANDAR',5), ('ANGEL',5),
('ANIMA',5), ('ANIMO',5), ('ANTES',5), ('ANUAL',5), ('AÑEJO',5),
('APEGO',5), ('ARABE',5), ('ARAÑA',5), ('ARBOL',5), ('ARCOS',5),
('ARDOR',5), ('ARENA',5), ('ARGOT',5), ('ARMAR',5), ('AROMA',5),
('ARRAS',5), ('ASADO',5), ('ASEAR',5), ('ASILO',5), ('ASOMA',5),
('ASTRO',5), ('ATAJO',5), ('ATAUD',5), ('ATOMO',5), ('AUDAZ',5),
('AULAS',5), ('AUREO',5), ('AUTOR',5), ('AVENA',5), ('AVION',5),
('AVISO',5), ('AYUDA',5), ('AZOTE',5),

-- B (60 palabras)
('BACON',5), ('BAHIA',5), ('BAILE',5), ('BAJAR',5), ('BALSA',5),
('BAMBU',5), ('BANCA',5), ('BANDA',5), ('BAÑAR',5), ('BARBA',5),
('BARCO',5), ('BARRA',5), ('BARRO',5), ('BASAR',5), ('BASTA',5),
('BATEA',5), ('BEBER',5), ('BELLA',5), ('BELLO',5), ('BESAR',5),
('BICHO',5), ('BIDON',5), ('BINGO',5), ('BIZCO',5), ('BLUSA',5),
('BOCAS',5), ('BODAS',5), ('BOINA',5), ('BOLSA',5), ('BOMBA',5),
('BORDE',5), ('BOTAS',5), ('BOXEO',5), ('BRAZO',5), ('BRAVO',5),
('BRASA',5), ('BREVE',5), ('BRIBE',5), ('BRISA',5), ('BRUJA',5),
('BRUNO',5), ('BRUTO',5), ('BUENO',5), ('BUFON',5), ('BURLA',5),
('BURRO',5), ('BUSCA',5), ('BUZON',5), ('BUCEO',5), ('BUQUE',5),
('BUSTO',5), ('BULTO',5), ('BURDO',5), ('BURNS',5),

-- C (80 palabras)
('CABAL',5), ('CABER',5), ('CABRA',5), ('CACAO',5), ('CAIDA',5),
('CALAR',5), ('CALCO',5), ('CALDO',5), ('CALLE',5), ('CALMA',5),
('CALOR',5), ('CALVO',5), ('CAMAS',5), ('CAMPO',5), ('CANAL',5),
('CANJE',5), ('CANTO',5), ('CAOBA',5), ('CAPAZ',5), ('CARGA',5),
('CARGO',5), ('CARNE',5), ('CARRO',5), ('CARTA',5), ('CASAR',5),
('CASCO',5), ('CASOS',5), ('CASTA',5), ('CASTO',5), ('CATAR',5),
('CATRE',5), ('CAUCE',5), ('CAUSA',5), ('CAVAR',5), ('CAZAR',5),
('CEBAR',5), ('CEBRA',5), ('CEDER',5), ('CEDRO',5), ('CEGAR',5),
('CEJAS',5), ('CELDA',5), ('CENAR',5), ('CERCA',5), ('CERCO',5),
('CERDO',5), ('CEROS',5), ('CESAR',5), ('CESTA',5), ('CHICA',5),
('CHICO',5), ('CHILE',5), ('CHINA',5), ('CHINO',5), ('CHOZA',5),
('CICLO',5), ('CIEGA',5), ('CIEGO',5), ('CIELO',5), ('CIERO',5),
('CIFRA',5), ('CINCO',5), ('CIRCO',5), ('CISNE',5), ('CITAR',5),
('CIVIL',5), ('CLARA',5), ('CLARO',5), ('CLASE',5), ('CLAVE',5),
('CLAVO',5), ('CLIMA',5), ('COCER',5), ('COCHE',5), ('CODAL',5),
('COGER',5), ('COLAR',5), ('COLOR',5), ('COMER',5), ('COMUN',5),
('CONDE',5), ('COPAS',5), ('COPIA',5), ('CORAL',5), ('CORTO',5),
('COSAS',5), ('COSER',5), ('COSTA',5), ('COSTO',5), ('CRASO',5),
('CREER',5), ('CREMA',5), ('CRIAR',5), ('CROMO',5), ('CRUCE',5),
('CRUDA',5), ('CRUDO',5), ('CRUEL',5), ('CUAJO',5), ('CUEVA',5),
('CUIDA',5), ('CULPA',5), ('CULTO',5), ('CUPON',5), ('CURAR',5),
('CURSO',5), ('CURVA',5),

-- D (40 palabras)
('DAMAS',5), ('DANZA',5), ('DAÑAR',5), ('DARDO',5), ('DATAR',5),
('DATOS',5), ('DEBER',5), ('DEBIL',5), ('DECIR',5), ('DEJAR',5),
('DELTA',5), ('DEMAS',5), ('DENSO',5), ('DESEO',5), ('DEUDA',5),
('DIANA',5), ('DIETA',5), ('DIGNO',5), ('DIQUE',5), ('DISCO',5),
('DOBLE',5), ('DONAR',5), ('DONDE',5), ('DRAMA',5), ('DROGA',5),
('DUDAS',5), ('DUELO',5), ('DUEÑO',5), ('DULCE',5), ('DUNAS',5),
('DUQUE',5), ('DURAR',5), ('DOBLE',5), ('DORSO',5), ('DOSIS',5),
('DOMAR',5), ('DOGMA',5), ('DOTAR',5), ('DOSEL',5),

-- E (35 palabras)
('ECHAR',5), ('EDUCA',5), ('ELIGE',5), ('EMITE',5), ('ENANO',5),
('ENERO',5), ('ENTRA',5), ('ENTRE',5), ('ENVIO',5), ('EPOCA',5),
('ERROR',5), ('ESTAR',5), ('ETAPA',5), ('EUROS',5), ('EVITA',5),
('EXIGE',5), ('EXITO',5), ('EXTRA',5), ('ETICO',5), ('EBANO',5),
('EBRIO',5), ('EGIDA',5), ('ELDER',5), ('EMANA',5), ('EMOJI',5),
('ENANO',5), ('ERIZO',5), ('ERRAR',5), ('ESPIA',5), ('ESTIO',5),
('ETNIA',5), ('EVOCA',5),

-- F (50 palabras)
('FACIL',5), ('FALDA',5), ('FALLA',5), ('FALSO',5), ('FALTA',5),
('FAMAS',5), ('FANAL',5), ('FANGO',5), ('FAROL',5), ('FATAL',5),
('FAUNA',5), ('FAVOR',5), ('FECHA',5), ('FELIZ',5), ('FERIA',5),
('FEROZ',5), ('FICHA',5), ('FIDEO',5), ('FIERA',5), ('FIJAR',5),
('FILAS',5), ('FINAL',5), ('FINCA',5), ('FIRME',5), ('FLACO',5),
('FLAMA',5), ('FLOJO',5), ('FLORA',5), ('FONDA',5), ('FONDO',5),
('FORMA',5), ('FORRO',5), ('FOTOS',5), ('FRASE',5), ('FRENO',5),
('FRESA',5), ('FRITO',5), ('FRUTA',5), ('FUEGO',5), ('FUERA',5),
('FURIA',5), ('FUSIL',5), ('FUSTA',5), ('FIBRA',5),

-- G (40 palabras)
('GAFAS',5), ('GALAN',5), ('GALES',5), ('GALGO',5), ('GALLO',5),
('GAMBA',5), ('GANAS',5), ('GANAR',5), ('GANGA',5), ('GARZA',5),
('GASES',5), ('GASTA',5), ('GASTO',5), ('GATAS',5), ('GEMIR',5),
('GENIO',5), ('GENTE',5), ('GIRAR',5), ('GIRAS',5), ('GLOBO',5),
('GOLES',5), ('GOLPE',5), ('GORDO',5), ('GORRA',5), ('GOZAR',5),
('GRADO',5), ('GRAMA',5), ('GRANO',5), ('GRASA',5), ('GRAVE',5),
('GRIPE',5), ('GRITO',5), ('GRUPO',5), ('GUAPA',5), ('GUAPO',5),
('GUIAR',5), ('GUION',5), ('GUISO',5), ('GUSTA',5), ('GUSTO',5),

-- H (30 palabras)
('HABER',5), ('HABIL',5), ('HACER',5), ('HACIA',5), ('HACHA',5),
('HADAS',5), ('HARTO',5), ('HASTA',5), ('HELAR',5), ('HEROE',5),
('HOGAR',5), ('HOJAS',5), ('HONDO',5), ('HONOR',5), ('HONRA',5),
('HORAS',5), ('HORNO',5), ('HOTEL',5), ('HUECO',5), ('HUESO',5),
('HUEVO',5), ('HUIDA',5), ('HUMOR',5), ('HONGO',5), ('HORMA',5),
('HOSCO',5), ('HURTO',5), ('HUCHA',5),

-- I (15 palabras)
('IDEAL',5), ('IDOLO',5), ('IGUAL',5), ('INDIO',5), ('ISTMO',5),
('ICONO',5), ('IMPAR',5), ('ISLAS',5), ('ITALO',5), ('IMPIO',5),
('LOBOS',5), ('LOCAL',5), ('LUCHA',5), ('LUCIR',5), ('LUEGO',5),
('LUGAR',5), ('LUNAR',5), ('LUNES',5), ('LUCES',5),

-- M (60 palabras)
('MACHO',5), ('MADRE',5), ('MAGIA',5), ('MAGNO',5), ('MALTA',5),
('MANCO',5), ('MANDO',5), ('MANGA',5), ('MANGO',5), ('MANIA',5),
('MANOS',5), ('MANTA',5), ('MANTO',5), ('MAPAS',5), ('MARCA',5),
('MARCO',5), ('MAREA',5), ('MARES',5), ('MARZO',5), ('MASAS',5),
('MATAR',5), ('MATIZ',5), ('MAYOR',5), ('MEDIR',5), ('MEDIO',5),
('MEJOR',5), ('MELON',5), ('MENOR',5), ('MENOS',5), ('MENTE',5),
('MESAS',5), ('MESON',5), ('METAL',5), ('METER',5), ('METRO',5),
('MIEDO',5), ('MIGAS',5), ('MINAR',5), ('MIOPE',5), ('MIRAR',5),
('MISMO',5), ('MITAD',5), ('MIXTO',5), ('MOJAR',5), ('MOLDE',5),
('MOLER',5), ('MONJA',5), ('MONTE',5), ('MONTO',5), ('MORAL',5),

-- N (35 palabras)
('NACER',5), ('NADAR',5), ('NADIE',5), ('NARIZ',5), ('NATAL',5),
('NAVAL',5), ('NEGAR',5), ('NEGRO',5), ('NEVAR',5), ('NICHO',5),
('NIETO',5), ('NIEVE',5), ('NIVEL',5), ('NOBLE',5), ('NOCHE',5),
('NORMA',5), ('NORTE',5), ('NOTAR',5), ('NOVIA',5), ('NOVIO',5),
('NUERA',5), ('NUEVE',5), ('NUEVO',5), ('NUNCA',5),

-- O (35 palabras)
('OASIS',5), ('OBESO',5), ('OBRAR',5), ('OBVIO',5), ('OCASO',5),
('OCUPA',5), ('ODIAR',5), ('OESTE',5), ('OIDOS',5), ('OLIVA',5),
('OLIVO',5), ('ONDAS',5), ('OPACO',5), ('OPERA',5), ('OPTAR',5),
('ORDEN',5), ('OREJA',5), ('OSADO',5), ('OSTIA',5), ('OVEJA',5),
('OXIDO',5),

-- P (80 palabras)
('PACTO',5), ('PADRE',5), ('PAGAR',5), ('PALCO',5), ('PALMA',5),
('PALMO',5), ('PANAL',5), ('PANEL',5), ('PAPAL',5), ('PAPEL',5),
('PARAR',5), ('PARDO',5), ('PARED',5), ('PARTE',5), ('PARTO',5),
('PASAR',5), ('PASEO',5), ('PASOS',5), ('PASTA',5), ('PASTO',5),
('PATIO',5), ('PAUSA',5), ('PAUTA',5), ('PECAR',5), ('PECHO',5),
('PEDIR',5), ('PEGAR',5), ('PELAR',5), ('PELEA',5), ('PERLA',5),
('PERRO',5), ('PESAR',5), ('PESCA',5), ('PESTE',5), ('PIANO',5),
('PICOS',5), ('PICAR',5), ('PIEZA',5), ('PILAR',5), ('PINTA',5),
('PINTO',5), ('PINZA',5), ('PIOJO',5), ('PISAR',5), ('PISTA',5),
('PITAR',5), ('PLAGA',5), ('PLANA',5), ('PLANO',5), ('PLATA',5),
('PLATO',5), ('PLAYA',5), ('PLAZO',5), ('PLOMO',5), ('PLUMA',5),
('POBRE',5), ('POCOS',5), ('PODER',5), ('POEMA',5), ('POETA',5),
('POLAR',5), ('POLEN',5), ('POLIO',5), ('POLLO',5), ('POLVO',5),
('PONER',5), ('PORTE',5), ('POSAR',5), ('POSTE',5), ('POTRO',5),
('PRADO',5), ('PRESA',5), ('PRIMO',5), ('PRISA',5), ('PUEDA',5),
('PUEDO',5), ('PULGA',5), ('PULIR',5), ('PULPA',5), ('PULPO',5),
('PULSO',5), ('PUNTA',5), ('PUNTO',5), ('PUÑAL',5),

-- Q (5 palabras)
('QUEMA',5), ('QUESO',5), ('QUIEN',5), ('QUIZA',5),

-- R (50 palabras)
('RABIA',5), ('RACHA',5), ('RADAR',5), ('RADIO',5), ('RAJAR',5),
('RAMAL',5), ('RAMAS',5), ('RANAS',5), ('RANGO',5), ('RAPAR',5),
('RAPAZ',5), ('RAPTO',5), ('RASAR',5), ('RASGO',5), ('RATAS',5),
('RATON',5), ('RAYAS',5), ('RAYOS',5), ('RAZAS',5), ('RAZON',5),
('RECIO',5), ('REDIL',5), ('REDOR',5), ('REGAR',5), ('REGIR',5),
('REGLA',5), ('REHÉN',5), ('REINA',5), ('REINO',5), ('REJAS',5),
('RELOJ',5), ('REMAR',5), ('REMOS',5), ('RENTA',5), ('REÑIR',5),
('RESOL',5), ('RESTA',5), ('RESTO',5), ('RETAL',5), ('RETEN',5),
('REVER',5), ('REVES',5), ('REYES',5), ('REZAR',5), ('RIEGO',5),
('RIFAR',5), ('RIFLE',5), ('RIGOR',5), ('RIMAR',5), ('RINAR',5),
('RIÑÓN',5), ('RISAS',5), ('RISCO',5), ('RITMO',5), ('RITOS',5),
('RIVAL',5), ('RIZAR',5), ('RIZOS',5), ('ROBAR',5), ('ROBLE',5),
('ROBOT',5), ('ROCAS',5), ('ROCIN',5), ('ROCÍO',5), ('RODAR',5),
('RODEO',5), ('ROGAR',5), ('ROMBO',5), ('RONCA',5), ('RONCO',5),
('RONDA',5), ('RONDY',5), ('ROSAL',5), ('ROSAS',5), ('ROSCA',5),
('ROSCO',5), ('ROTAR',5), ('ROTOS',5), ('ROZAR',5), ('RUBIA',5),
('RUBIO',5), ('RUBOR',5), ('RUCIO',5), ('RUEDA',5), ('RUEDO',5),
('RUEGO',5),

-- S (35 palabras)
('SABER',5), ('SABIO',5), ('SABOR',5), ('SABRA',5), ('SABRA',5),
('SALIR',5), ('SALON',5), ('SALTO',5), ('SALUD',5), ('SALVA',5),
('SALVO',5), ('SANTO',5), ('SAPOS',5), ('SAQUE',5), ('SATIN',5),
('SAUNA',5), ('SAVIA',5), ('SEGUI',5), ('SELLO',5), ('SENDA',5),
('SENOR',5), ('SERIO',5), ('SERVI',5), ('SESOS',5), ('SETAS',5),
('SEÑAL',5), ('SIDRA',5), ('SIETE',5), ('SIGLO',5), ('SIGUE',5),
('SILLA',5), ('SILOS',5), ('SITIO',5), ('SOBRE',5), ('SOCIO',5),
('SOLAR',5), ('SOLDO',5), ('SOLER',5), ('SOLTA',5), ('SOLTO',5),
('SOMOS',5), ('SONAR',5), ('SONDA',5), ('SONRE',5), ('SOPLO',5),
('SORBO',5), ('SORDO',5), ('SORNA',5), ('SORRY',5), ('SORTA',5),
('SORTE',5), ('SORTE',5), ('SOSAS',5), ('SUELO',5), ('SUEÑO',5),
('SUEÑA',5), ('SUEÑO',5), ('SUITE',5), ('SUJER',5), ('SULTO',5),
('SUMAR',5), ('SUMAS',5), ('SUPER',5), ('SURCO',5), ('SURTE',5),

-- T (30 palabras)
('TABLA',5), ('TACOS',5), ('TALON',5), ('TALPA',5), ('TALLO',5),
('TANGO',5), ('TANTO',5), ('TAPAR',5), ('TARDE',5), ('TARRO',5),
('TARTA',5), ('TASAR',5), ('TATUA',5), ('TECHO',5), ('TECLA',5),
('TEJER',5), ('TELAS',5), ('TELON',5), ('TEMAS',5), ('TEMOR',5),
('TENAZ',5), ('TENER',5), ('TENIS',5), ('TENOR',5), ('TEXTO',5),
('TIARA',5), ('TIBIO',5), ('TIGRE',5), ('TIMON',5), ('TINTO',5),
('TIRAR',5), ('TITAN',5), ('TIZAS',5), ('TOMAR',5), ('TONEL',5),
('TONOS',5), ('TORAX',5), ('TOROS',5), ('TORPE',5), ('TORRE',5),
('TORZO',5), ('TOSTO',5), ('TOTAL',5), ('TOZAR',5), ('TRABA',5),
('TRAMO',5), ('TRAZO',5), ('TREBO',5), ('TRETA',5), ('TRIGO',5),
('TRIPA',5), ('TRONO',5), ('TROPA',5), ('TROZO',5), ('TRUCO',5),
('TRUFA',5), ('TUBOS',5), ('TUMBA',5), ('TUNEL',5), ('TURNO',5),

-- U (10 palabras)
('UNICO',5), ('UNION',5), ('UNTAR',5), ('URDIR',5), ('URGIR',5),
('USADO',5), ('USUAL',5), ('UTERO',5), ('UVAS',5), ('UZUEL',5),

-- V (30 palabras)
('VACAS',5), ('VAGAR',5), ('VAGON',5), ('VALER',5), ('VALLE',5),
('VALOR',5), ('VAPOR',5), ('VARON',5), ('VASOS',5), ('VASTO',5),
('VELAS',5), ('VELAR',5), ('VELLO',5), ('VENAS',5), ('VENCE',5),
('VENDA',5), ('VENDO',5), ('VENIR',5), ('VENTA',5), ('VERDE',5),
('VERJA',5), ('VERSO',5), ('VESTA',5), ('VIAJE',5), ('VICIO',5),
('VIDEO',5), ('VIEJO',5), ('VIGOR',5), ('VILLA',5), ('VINOS',5),
('VIRUS',5), ('VISTA',5), ('VIVIR',5), ('VOLAR',5), ('VOLTO',5),
('VOTAR',5), ('VOTOS',5),

-- Y (5 palabras)
('YACER',5), ('YATES',5), ('YEGUA',5), ('YERBA',5), ('YERNO',5),

-- Z (10 palabras)
('ZAFAR',5), ('ZAHOR',5), ('ZANJA',5), ('ZARPA',5), ('ZOCAL',5),
('ZOCOS',5), ('ZOMOS',5), ('ZORRA',5), ('ZORRO',5), ('ZURDO',5),
('ZURZO',5), ('ZARZA',5);


-- Insertar usuario de prueba (contraseña: test123)
INSERT INTO usuarios (username, email, password) VALUES
('testuser', 'test@lingo.local', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi');

-- Insertar configuración por defecto para el usuario de prueba
INSERT INTO configuraciones (usuario_id, tema, tamano_fuente, sonido_activo) VALUES
(1, 'claro', 'normal', TRUE);