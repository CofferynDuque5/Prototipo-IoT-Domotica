// Punto de entrada del backend: crea el servidor HTTP, monta el WebSocket,
// verifica la base de datos y arranca el servicio.
import http from 'http';

import { config } from './config.js';
import { assertConnection } from './db.js';
import { app } from './app.js';
import { initWebSocket } from './ws.js';

const server = http.createServer(app);
initWebSocket(server);

async function start() {
  try {
    const now = await assertConnection();
    console.log('[db] Conectado a PostgreSQL:', now);
  } catch (err) {
    console.error('[db] No se pudo conectar a PostgreSQL:', err.message);
    console.error('     Verifica DATABASE_URL y que la base de datos esté activa.');
    process.exit(1);
  }

  server.listen(config.port, () => {
    console.log(`[http] API escuchando en http://localhost:${config.port}`);
    console.log(`[ws]   WebSocket en ws://localhost:${config.port}/ws`);
  });
}

start();
