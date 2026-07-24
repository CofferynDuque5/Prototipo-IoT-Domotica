// Lógica de autenticación: registro, login y perfil.
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from '../db.js';
import { config } from '../config.js';
import { mapUser } from '../mappers.js';

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function signToken(user) {
  return jwt.sign(
    { sub: user.id, email: user.email },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn },
  );
}

export async function register(req, res) {
  const { nombre, email, password } = req.body || {};

  if (!nombre || !email || !password) {
    return res.status(400).json({ error: 'Nombre, correo y contraseña son obligatorios' });
  }
  if (!EMAIL_REGEX.test(email)) {
    return res.status(400).json({ error: 'Correo electrónico no válido' });
  }
  if (password.length < 6) {
    return res.status(400).json({ error: 'La contraseña debe tener al menos 6 caracteres' });
  }

  const existing = await query('SELECT id FROM users WHERE email = $1', [
    email.toLowerCase(),
  ]);
  if (existing.rows.length) {
    return res.status(409).json({ error: 'Ya existe una cuenta con este correo' });
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const now = Date.now();

  const { rows } = await query(
    `INSERT INTO users (nombre, email, password_hash, created_at)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [nombre.trim(), email.toLowerCase(), passwordHash, now],
  );

  const row = rows[0];
  const token = signToken(row);
  res.status(201).json({ token, user: mapUser(row) });
}

export async function login(req, res) {
  const { email, password } = req.body || {};

  if (!email || !password) {
    return res.status(400).json({ error: 'Correo y contraseña son obligatorios' });
  }

  const { rows } = await query('SELECT * FROM users WHERE email = $1', [
    email.toLowerCase(),
  ]);
  if (!rows.length) {
    return res.status(401).json({ error: 'Correo o contraseña incorrectos' });
  }

  const row = rows[0];
  const ok = await bcrypt.compare(password, row.password_hash);
  if (!ok) {
    return res.status(401).json({ error: 'Correo o contraseña incorrectos' });
  }

  const token = signToken(row);
  res.json({ token, user: mapUser(row) });
}

/**
 * Solicitud de recuperación de contraseña.
 *
 * Responde siempre 200 (sin revelar si el correo existe, para evitar la
 * enumeración de usuarios). El envío real del correo requiere configurar un
 * proveedor SMTP; en este prototipo se registra la solicitud en el log.
 * Consulta backend/README.md → "Recuperación de contraseña".
 */
export async function forgotPassword(req, res) {
  const { email } = req.body || {};
  if (!email || !EMAIL_REGEX.test(email)) {
    return res.status(400).json({ error: 'Correo electrónico no válido' });
  }

  const { rows } = await query('SELECT id FROM users WHERE email = $1', [
    email.toLowerCase(),
  ]);
  if (rows.length && process.env.NODE_ENV !== 'test') {
    console.log(`[auth] Solicitud de recuperación para ${email} (pendiente SMTP)`);
    // TODO: generar token de restablecimiento y enviarlo por correo (SMTP).
  }

  res.json({
    message:
      'Si existe una cuenta con ese correo, se enviarán instrucciones de recuperación.',
  });
}

export async function me(req, res) {
  const { rows } = await query('SELECT * FROM users WHERE id = $1', [
    req.userId,
  ]);
  if (!rows.length) {
    return res.status(404).json({ error: 'Usuario no encontrado' });
  }
  res.json(mapUser(rows[0]));
}

export async function updateProfile(req, res) {
  const { nombre } = req.body || {};
  if (!nombre || nombre.trim().length < 2) {
    return res.status(400).json({ error: 'Nombre no válido' });
  }
  const { rows } = await query(
    'UPDATE users SET nombre = $1 WHERE id = $2 RETURNING *',
    [nombre.trim(), req.userId],
  );
  res.json(mapUser(rows[0]));
}
