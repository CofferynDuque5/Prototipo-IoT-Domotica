// Construcción de la aplicación Express (sin arrancar el servidor).
//
// Separar la creación de la app del arranque del servidor permite probarla con
// Supertest sin abrir un puerto real.
import express from 'express';
import cors from 'cors';
import morgan from 'morgan';

import authRoutes from './routes/auth.js';
import deviceRoutes from './routes/devices.js';
import eventRoutes from './routes/events.js';
import espRoutes from './routes/esp.js';
import estadoRoutes from './routes/estado.js';

export function createApp() {
  const app = express();

  app.use(cors());
  app.use(express.json());
  // Silencia el log de peticiones durante las pruebas.
  if (process.env.NODE_ENV !== 'test') {
    app.use(morgan('dev'));
  }

  // Comprobación de salud.
  app.get('/health', (req, res) => res.json({ status: 'ok', ts: Date.now() }));

  // Rutas de la API.
  app.use('/api/auth', authRoutes);
  app.use('/api/devices', deviceRoutes);
  app.use('/api/events', eventRoutes);
  app.use('/api/esp', espRoutes);
  app.use('/api/estado', estadoRoutes);

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

  return app;
}

export const app = createApp();
