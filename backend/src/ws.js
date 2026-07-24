// Hub de WebSocket: mantiene los clientes conectados (apps) y les difunde
// actualizaciones en tiempo real (dispositivos, telemetría, eventos).
import { WebSocketServer } from 'ws';
import jwt from 'jsonwebtoken';
import { config } from './config.js';
import { getAllDevices } from './controllers/deviceController.js';
import { getEspStatus } from './controllers/espController.js';
import { getRecentEvents } from './controllers/eventController.js';

let wss = null;

// Log silencioso durante las pruebas para no ensuciar la salida ni registrar
// mensajes después de que un test termine.
const log = (...args) => {
  if (process.env.NODE_ENV !== 'test') console.log(...args);
};

/**
 * Inicializa el servidor WebSocket sobre el servidor HTTP existente.
 * Los clientes se conectan a ws://host/ws?token=JWT.
 */
export function initWebSocket(server) {
  wss = new WebSocketServer({ server, path: '/ws' });

  wss.on('connection', async (socket, request) => {
    // Autenticación por token en la query string.
    try {
      const url = new URL(request.url, 'http://localhost');
      const token = url.searchParams.get('token');
      const payload = jwt.verify(token, config.jwtSecret);
      socket.userId = payload.sub;
    } catch (_) {
      socket.close(4001, 'No autorizado');
      return;
    }

    log('[ws] Cliente conectado. Total:', wss.clients.size);

    // Al conectar, envía una instantánea completa del estado actual.
    try {
      send(socket, 'devices', await getAllDevices());
      send(socket, 'esp', await getEspStatus());
      send(socket, 'events', await getRecentEvents());
    } catch (err) {
      console.error('[ws] Error enviando snapshot inicial:', err.message);
    }

    socket.on('close', () => {
      log('[ws] Cliente desconectado. Total:', wss.clients.size);
    });
  });

  log('[ws] Servidor WebSocket listo en /ws');
}

/** Envía un mensaje tipado a un socket concreto. */
function send(socket, type, payload) {
  if (socket.readyState === socket.OPEN) {
    socket.send(JSON.stringify({ type, payload }));
  }
}

/** Difunde un mensaje tipado a todos los clientes conectados. */
export function broadcast(type, payload) {
  if (!wss) return;
  const message = JSON.stringify({ type, payload });
  for (const client of wss.clients) {
    if (client.readyState === client.OPEN) {
      client.send(message);
    }
  }
}
