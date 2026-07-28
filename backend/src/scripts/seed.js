// Carga los datos iniciales (seed) en la base de datos.
import { readFile } from 'fs/promises';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { pool } from '../db.js';

const __dirname = dirname(fileURLToPath(import.meta.url));

async function run() {
  const seedPath = join(__dirname, '..', '..', 'db', 'seed.sql');
  const sql = await readFile(seedPath, 'utf8');
  console.log('[seed] Insertando datos iniciales...');
  await pool.query(sql);
  console.log('[seed] Datos iniciales cargados.');
  await pool.end();
}

run().catch((err) => {
  console.error('[seed] Error:', err.message);
  process.exit(1);
});
