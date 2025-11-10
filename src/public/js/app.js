/**
 * Aplicación LINGOverse - Single Page Application
 * Gestiona toda la lógica del juego en el cliente
 */

// Estado global de la aplicación
const AppState = {
    currentUser: null,
    currentPartida: null,
    currentAttempt: 0,
    currentRow: [],
    gameActive: false,
    timer: null,
    timeRemaining: 60,
    totalTime: 0,
    secretWord: '',
    keyboardState: {}
};

// Configuración
const CONFIG = {
    MAX_ATTEMPTS: 5,
    WORD_LENGTH: 5,
    TIME_PER_ATTEMPT: 60,
    API_BASE: '/api'
};

// Letras del teclado español
const KEYBOARD_LAYOUT = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'Ñ'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫']
];

// ============ UTILIDADES ============

/**
 * Realiza una petición fetch con manejo de errores
 */
async function fetchAPI(url, options = {}) {
    try {
        const response = await fetch(CONFIG.API_BASE + url, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            }
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || 'Error en la petición');
        }
        
        return data;
    } catch (error) {
        console.error('Error en fetchAPI:', error);
        throw error;
    }
}

/**
 * Muestra un mensaje de error
 */
function showError(elementId, message) {
    const element = document.getElementById(elementId);
    if (element) {
        element.textContent = message;
        element.classList.add('show');
        setTimeout(() => {
            element.classList.remove('show');
        }, 5000);
    }
}

/**
 * Muestra un mensaje de éxito
 */
function showSuccess(elementId, message) {
    const element = document.getElementById(elementId);
    if (element) {
        element.textContent = message;
        element.classList.add('show');
        setTimeout(() => {
            element.classList.remove('show');
        }, 3000);
    }
}

/**
 * Cambia entre pantallas
 */
function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.remove('active');
    });
    document.getElementById(screenId).classList.add('active');
}

// ============ AUTENTICACIÓN ============

/**
 * Inicializa los event listeners de autenticación
 */
function initAuthListeners() {
    // Cambio de tabs
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const tab = btn.dataset.tab;
            
            // Actualizar tabs
            document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            // Mostrar formulario correspondiente
            document.querySelectorAll('.auth-form').forEach(form => form.classList.remove('active'));
            document.getElementById(tab + '-form').classList.add('active');
        });
    });
    
    // Login
    document.getElementById('login-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const username = document.getElementById('login-username').value;
        const password = document.getElementById('login-password').value;
        
        try {
            const data = await fetchAPI('/login', {
                method: 'POST',
                body: JSON.stringify({ username, password })
            });
            
            AppState.currentUser = data.user;
            document.getElementById('current-username').textContent = data.user.username;
            await loadUserConfig();
            showScreen('menu-screen');
        } catch (error) {
            showError('login-error', error.message);
        }
    });
    
    // Registro
    document.getElementById('register-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const username = document.getElementById('register-username').value;
        const email = document.getElementById('register-email').value;
        const password = document.getElementById('register-password').value;
        
        try {
            const data = await fetchAPI('/register', {
                method: 'POST',
                body: JSON.stringify({ username, email, password })
            });
            
            AppState.currentUser = data.user;
            document.getElementById('current-username').textContent = data.user.username;
            await loadUserConfig();
            showScreen('menu-screen');
        } catch (error) {
            showError('register-error', error.message);
        }
    });
    
    // Logout
    document.getElementById('logout-btn').addEventListener('click', async () => {
        try {
            await fetchAPI('/logout', { method: 'POST' });
            AppState.currentUser = null;
            showScreen('auth-screen');
        } catch (error) {
            console.error('Error al cerrar sesión:', error);
        }
    });
}

// ============ MENÚ PRINCIPAL ============

/**
 * Inicializa los event listeners del menú
 */
function initMenuListeners() {
    document.getElementById('start-game-btn').addEventListener('click', startNewGame);
    document.getElementById('show-ranking-btn').addEventListener('click', () => {
        loadRanking();
        showScreen('ranking-screen');
    });
    document.getElementById('show-config-btn').addEventListener('click', () => {
        showScreen('config-screen');
    });
}

// ============ JUEGO ============

/**
 * Inicia una nueva partida
 */
async function startNewGame() {
    try {
        const data = await fetchAPI('/game/start');
        
        AppState.currentPartida = data.partida_id;
        AppState.currentAttempt = 0;
        AppState.currentRow = [];
        AppState.gameActive = true;
        AppState.totalTime = 0;
        AppState.keyboardState = {};
        
        // Inicializar tablero
        initGameBoard();
        initKeyboard();
        
        // Iniciar temporizador
        startTimer();
        
        showScreen('game-screen');
    } catch (error) {
        alert('Error al iniciar partida: ' + error.message);
    }
}

/**
 * Inicializa el tablero de juego
 */
function initGameBoard() {
    const board = document.querySelector('.game-board');
    board.innerHTML = '';
    
    for (let i = 0; i < CONFIG.MAX_ATTEMPTS; i++) {
        const row = document.createElement('div');
        row.className = 'row';
        row.dataset.row = i;
        
        for (let j = 0; j < CONFIG.WORD_LENGTH; j++) {
            const tile = document.createElement('div');
            tile.className = 'tile';
            tile.dataset.index = j;
            row.appendChild(tile);
        }
        
        board.appendChild(row);
    }
}

/**
 * Inicializa el teclado en pantalla
 */
function initKeyboard() {
    const keyboard = document.querySelector('.keyboard');
    keyboard.innerHTML = '';
    
    KEYBOARD_LAYOUT.forEach(row => {
        const keyboardRow = document.createElement('div');
        keyboardRow.className = 'keyboard-row';
        
        row.forEach(key => {
            const keyBtn = document.createElement('button');
            keyBtn.className = 'key';
            keyBtn.textContent = key;
            keyBtn.dataset.key = key;
            
            if (key === 'ENTER' || key === '⌫') {
                keyBtn.classList.add('wide');
            }
            
            keyBtn.addEventListener('click', () => handleKeyPress(key));
            keyboardRow.appendChild(keyBtn);
        });
        
        keyboard.appendChild(keyboardRow);
    });
}

/**
 * Maneja la pulsación de teclas
 */
function handleKeyPress(key) {
    if (!AppState.gameActive) return;
    
    if (key === '⌫') {
        // Borrar última letra
        if (AppState.currentRow.length > 0) {
            AppState.currentRow.pop();
            updateCurrentRow();
        }
    } else if (key === 'ENTER') {
        // Enviar intento
        if (AppState.currentRow.length === CONFIG.WORD_LENGTH) {
            submitAttempt();
        }
    } else {
        // Añadir letra
        if (AppState.currentRow.length < CONFIG.WORD_LENGTH) {
            AppState.currentRow.push(key);
            updateCurrentRow();
        }
    }
}

/**
 * Actualiza la fila actual con las letras escritas
 */
function updateCurrentRow() {
    const row = document.querySelector(`[data-row="${AppState.currentAttempt}"]`);
    const tiles = row.querySelectorAll('.tile');
    
    tiles.forEach((tile, index) => {
        if (index < AppState.currentRow.length) {
            tile.textContent = AppState.currentRow[index];
            tile.classList.add('filled');
        } else {
            tile.textContent = '';
            tile.classList.remove('filled');
        }
    });
}

/**
 * Envía un intento al servidor
 */
async function submitAttempt() {
    const word = AppState.currentRow.join('');
    const timeUsed = CONFIG.TIME_PER_ATTEMPT - AppState.timeRemaining;
    
    // Bloquear la fila
    AppState.gameActive = false;
    stopTimer();
    
    try {
        const data = await fetchAPI('/game/validate', {
            method: 'POST',
            body: JSON.stringify({
                palabra: word,
                partida_id: AppState.currentPartida,
                numero_intento: AppState.currentAttempt + 1,
                tiempo_usado: timeUsed
            })
        });
        
        if (!data.valida) {
            // Palabra no válida
            alert(data.error);
            AppState.gameActive = true;
            startTimer();
            return;
        }
        
        // Colorear las letras
        await colorTiles(data.resultado);
        
        // Actualizar estado del teclado
        updateKeyboardState(word, data.resultado);
        
        // Incrementar tiempo total
        AppState.totalTime += timeUsed;
        
        if (data.ganado) {
            // Victoria
            await finishGame(true, AppState.currentAttempt + 1);
        } else {
            // Siguiente intento
            AppState.currentAttempt++;
            AppState.currentRow = [];
            
            if (AppState.currentAttempt >= CONFIG.MAX_ATTEMPTS) {
                // Derrota
                await finishGame(false, CONFIG.MAX_ATTEMPTS);
            } else {
                // Continuar jugando
                AppState.gameActive = true;
                updateAttemptCounter();
                startTimer();
            }
        }
    } catch (error) {
        console.error('Error al validar intento:', error);
        AppState.gameActive = true;
        startTimer();
    }
}

/**
 * Colorea las fichas según el resultado
 */
function colorTiles(resultado) {
    return new Promise(resolve => {
        const row = document.querySelector(`[data-row="${AppState.currentAttempt}"]`);
        const tiles = row.querySelectorAll('.tile');
        
        tiles.forEach((tile, index) => {
            setTimeout(() => {
                if (resultado[index] === 2) {
                    tile.classList.add('correct');
                } else if (resultado[index] === 1) {
                    tile.classList.add('present');
                } else {
                    tile.classList.add('absent');
                }
                
                if (index === tiles.length - 1) {
                    setTimeout(resolve, 300);
                }
            }, index * 200);
        });
    });
}

/**
 * Actualiza el estado del teclado
 */
function updateKeyboardState(word, resultado) {
    for (let i = 0; i < word.length; i++) {
        const letter = word[i];
        const state = resultado[i];
        
        // Solo actualizar si es mejor que el estado actual
        if (!AppState.keyboardState[letter] || AppState.keyboardState[letter] < state) {
            AppState.keyboardState[letter] = state;
        }
    }
    
    // Aplicar colores al teclado
    Object.keys(AppState.keyboardState).forEach(letter => {
        const key = document.querySelector(`[data-key="${letter}"]`);
        if (key) {
            key.classList.remove('correct', 'present', 'absent');
            if (AppState.keyboardState[letter] === 2) {
                key.classList.add('correct');
            } else if (AppState.keyboardState[letter] === 1) {
                key.classList.add('present');
            } else {
                key.classList.add('absent');
            }
        }
    });
}

/**
 * Actualiza el contador de intentos
 */
function updateAttemptCounter() {
    document.getElementById('current-attempt').textContent = 
        `Intento: ${AppState.currentAttempt + 1}/${CONFIG.MAX_ATTEMPTS}`;
}

/**
 * Inicia el temporizador
 */
function startTimer() {
    AppState.timeRemaining = CONFIG.TIME_PER_ATTEMPT;
    updateTimerDisplay();
    
    AppState.timer = setInterval(() => {
        AppState.timeRemaining--;
        updateTimerDisplay();
        
        if (AppState.timeRemaining <= 0) {
            stopTimer();
            handleTimeOut();
        }
    }, 1000);
}

/**
 * Detiene el temporizador
 */
function stopTimer() {
    if (AppState.timer) {
        clearInterval(AppState.timer);
        AppState.timer = null;
    }
}

/**
 * Actualiza la visualización del temporizador
 */
function updateTimerDisplay() {
    document.getElementById('timer').textContent = `⏱️ ${AppState.timeRemaining}s`;
}

/**
 * Maneja el agotamiento del tiempo
 */
function handleTimeOut() {
    AppState.currentAttempt++;
    AppState.currentRow = [];
    
    if (AppState.currentAttempt >= CONFIG.MAX_ATTEMPTS) {
        finishGame(false, CONFIG.MAX_ATTEMPTS);
    } else {
        alert('¡Tiempo agotado! Pierdes este intento.');
        updateAttemptCounter();
        AppState.gameActive = true;
        startTimer();
    }
}

/**
 * Finaliza la partida
 */
async function finishGame(won, attempts) {
    stopTimer();
    AppState.gameActive = false;
    
    try {
        const data = await fetchAPI('/game/finish', {
            method: 'POST',
            body: JSON.stringify({
                partida_id: AppState.currentPartida,
                intentos_usados: attempts,
                ganado: won,
                tiempo_total: AppState.totalTime
            })
        });
        
        // Mostrar pantalla de resultado
        showResultScreen(won, attempts, data.puntuacion);
    } catch (error) {
        console.error('Error al finalizar partida:', error);
    }
}

/**
 * Muestra la pantalla de resultado
 */
function showResultScreen(won, attempts, score) {
    const title = document.getElementById('result-title');
    const message = document.getElementById('result-message');
    
    if (won) {
        title.textContent = '🎉 ¡Felicidades!';
        message.textContent = '¡Has adivinado la palabra!';
    } else {
        title.textContent = '😔 Has perdido';
        message.textContent = 'No has conseguido adivinar la palabra';
    }
    
    document.getElementById('final-score').textContent = score;
    document.getElementById('final-attempts').textContent = `${attempts}/${CONFIG.MAX_ATTEMPTS}`;
    document.getElementById('final-time').textContent = `${AppState.totalTime}s`;
    
    showScreen('result-screen');
}

/**
 * Inicializa listeners del juego
 */
function initGameListeners() {
    document.getElementById('back-to-menu').addEventListener('click', () => {
        stopTimer();
        AppState.gameActive = false;
        showScreen('menu-screen');
    });
    
    document.getElementById('play-again-btn').addEventListener('click', startNewGame);
    document.getElementById('view-ranking-btn').addEventListener('click', () => {
        loadRanking();
        showScreen('ranking-screen');
    });
    
    // Soporte para teclado físico
    document.addEventListener('keydown', (e) => {
        if (!AppState.gameActive) return;
        
        const key = e.key.toUpperCase();
        
        if (key === 'BACKSPACE') {
            handleKeyPress('⌫');
        } else if (key === 'ENTER') {
            handleKeyPress('ENTER');
        } else if (/^[A-ZÑ]$/.test(key)) {
            handleKeyPress(key);
        }
    });
}

// ============ RANKING ============

/**
 * Carga y muestra el ranking
 */
async function loadRanking() {
    try {
        const data = await fetchAPI('/ranking');
        displayRanking(data.ranking);
    } catch (error) {
        console.error('Error al cargar ranking:', error);
    }
}

/**
 * Muestra el ranking en pantalla
 */
function displayRanking(ranking) {
    const list = document.querySelector('.ranking-list');
    list.innerHTML = '';
    
    if (ranking.length === 0) {
        list.innerHTML = '<p style="text-align: center; padding: 20px;">No hay datos en el ranking todavía</p>';
        return;
    }
    
    ranking.forEach(item => {
        const div = document.createElement('div');
        div.className = 'ranking-item';
        
        const positionClass = item.posicion === 1 ? 'first' : 
                            item.posicion === 2 ? 'second' : 
                            item.posicion === 3 ? 'third' : '';
        
        div.innerHTML = `
            <div class="ranking-position ${positionClass}">${item.posicion}</div>
            <div class="ranking-details">
                <div class="ranking-username">${item.username}</div>
                <div class="ranking-stats">${item.intentos} intentos • ${item.tiempo}s</div>
            </div>
            <div class="ranking-score">${item.puntuacion}</div>
        `;
        
        list.appendChild(div);
    });
}

/**
 * Inicializa listeners del ranking
 */
function initRankingListeners() {
    document.getElementById('back-from-ranking').addEventListener('click', () => {
        showScreen('menu-screen');
    });
}

// ============ CONFIGURACIÓN ============

/**
 * Carga la configuración del usuario
 */
async function loadUserConfig() {
    try {
        const data = await fetchAPI('/config');
        applyConfig(data.config);
        updateConfigForm(data.config);
    } catch (error) {
        console.error('Error al cargar configuración:', error);
    }
}

/**
 * Aplica la configuración al DOM
 */
function applyConfig(config) {
    // Aplicar tema
    document.body.className = '';
    if (config.tema === 'oscuro') {
        document.body.classList.add('tema-oscuro');
    }
    
    // Aplicar tamaño de fuente
    document.body.classList.add(`tamano-${config.tamano_fuente}`);
}

/**
 * Actualiza el formulario con la configuración
 */
function updateConfigForm(config) {
    document.querySelector(`input[name="tema"][value="${config.tema}"]`).checked = true;
    document.querySelector(`input[name="tamano_fuente"][value="${config.tamano_fuente}"]`).checked = true;
    document.querySelector('input[name="sonido_activo"]').checked = config.sonido_activo;
}

/**
 * Inicializa listeners de configuración
 */
function initConfigListeners() {
    document.getElementById('back-from-config').addEventListener('click', () => {
        showScreen('menu-screen');
    });
    
    document.getElementById('config-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const tema = document.querySelector('input[name="tema"]:checked').value;
        const tamanoFuente = document.querySelector('input[name="tamano_fuente"]:checked').value;
        const sonidoActivo = document.querySelector('input[name="sonido_activo"]').checked;
        
        try {
            const data = await fetchAPI('/config', {
                method: 'POST',
                body: JSON.stringify({
                    tema,
                    tamano_fuente: tamanoFuente,
                    sonido_activo: sonidoActivo
                })
            });
            
            applyConfig(data.config);
            showSuccess('config-success', 'Configuración guardada exitosamente');
        } catch (error) {
            alert('Error al guardar configuración: ' + error.message);
        }
    });
}

// ============ INICIALIZACIÓN ============

/**
 * Inicializa la aplicación
 */
async function initApp() {
    // Verificar si hay sesión activa
    try {
        const data = await fetchAPI('/user');
        AppState.currentUser = data.user;
        document.getElementById('current-username').textContent = data.user.username;
        await loadUserConfig();
        showScreen('menu-screen');
    } catch (error) {
        // No hay sesión activa, mostrar login
        showScreen('auth-screen');
    }
    
    // Inicializar event listeners
    initAuthListeners();
    initMenuListeners();
    initGameListeners();
    initRankingListeners();
    initConfigListeners();
}

// Iniciar la aplicación cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', initApp);