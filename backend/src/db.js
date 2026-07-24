// Pool de conexiones a PostgreSQL y helpers de acceso a datos.
import pg from 'pg';
import { config } from './config.js';

const { Pool } = pg;

export const pool = new Pool({ connectionString: config.databaseUrl });

pool.on('error', (err) => {
  console.error('[db] Error inesperado en el pool de PostgreSQL:', err.message);
});

/**
 * Ejecuta una consulta parametrizada.
 * @param {string} text SQL con placeholders $1, $2, ...
 * @param {Array} params Valores para los placeholders.
 */
export function query(text, params) {
  return pool.query(text, params);
}

/** Verifica la conectividad con la base de datos (usado al arrancar). */
export async function assertConnection() {
  const { rows } = await pool.query('SELECT NOW() AS now');
  return rows[0].now;
}
