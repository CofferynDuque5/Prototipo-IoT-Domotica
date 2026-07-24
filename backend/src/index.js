// Punto de entrada del backend: configura Express, las rutas, el WebSocket y
// arranca el servidor HTTP.
import http from 'http';
import express from 'express';
import cors from 'cors';
import morgan from 'morgan';

import { config } from './config.js';
import { assertConnection } from './db.js';
import { initWebSocket } from './ws.js';

import authRoutes from './routes/auth.js';
import deviceRoutes from './routes/devices.js';
import eventRoutes from './routes/events.js';
import espRoutes from './routes/esp.js';

const app = express();

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Comprobación de salud.
app.get('/health', (req, res) => res.json({ status: 'ok', ts: Date.now() }));

// Rutas de la API.
app.use('/api/auth', authRoutes);
app.use('/api/devices', deviceRoutes);
app.use('/api/events', eventRoutes);
app.use('/api/esp', espRoutes);

// 404.
app.use((req, res) => {
  res.status(404).json({ error: 'Recurso no encontrado' });
});

// Manejo centralizado de errores.
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error('[error]', err.message);
  res.status(err.status || 500).json({
    error: err.publicMessage || 'Error interno del servidor',
  });
});

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
