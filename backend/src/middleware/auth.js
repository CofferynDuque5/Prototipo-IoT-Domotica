// Middlewares de autorización.
import jwt from 'jsonwebtoken';
import { config } from '../config.js';

/**
 * Exige un JWT válido (usuarios de la app). Adjunta `req.userId`.
 */
export function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;

  if (!token) {
    return res.status(401).json({ error: 'Token no proporcionado' });
  }

  try {
    const payload = jwt.verify(token, config.jwtSecret);
    req.userId = payload.sub;
    req.userEmail = payload.email;
    next();
  } catch (_) {
    return res.status(401).json({ error: 'Token inválido o expirado' });
  }
}

/**
 * Exige la clave de API del dispositivo (ESP8266) en la cabecera x-device-key.
 */
export function requireDeviceKey(req, res, next) {
  const key = req.headers['x-device-key'];
  if (!key || key !== config.deviceApiKey) {
    return res.status(401).json({ error: 'Clave de dispositivo inválida' });
  }
  next();
}
