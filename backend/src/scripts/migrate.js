// Ejecuta el esquema SQL contra la base de datos configurada.
import { readFile } from 'fs/promises';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { pool } from '../db.js';

const __dirname = dirname(fileURLToPath(import.meta.url));

async function run() {
  const schemaPath = join(__dirname, '..', '..', 'db', 'schema.sql');
  const sql = await readFile(schemaPath, 'utf8');
  console.log('[migrate] Aplicando esquema...');
  await pool.query(sql);
  console.log('[migrate] Esquema aplicado correctamente.');
  await pool.end();
}

run().catch((err) => {
  console.error('[migrate] Error:', err.message);
  process.exit(1);
});
