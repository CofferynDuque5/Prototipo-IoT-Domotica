// Base de datos PostgreSQL en memoria (pg-mem) para las pruebas.
//
// Carga el esquema real (db/schema.sql) y expone un adaptador compatible con el
// paquete `pg`, de modo que el backend funcione idéntico pero sin necesitar una
// base de datos externa. Así los tests corren en cualquier máquina y en CI.
import { newDb, DataType } from 'pg-mem';
import { randomUUID } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const dbDir = join(__dirname, '..', '..', 'db');

const schemaSql = readFileSync(join(dbDir, 'schema.sql'), 'utf8');
const seedSql = readFileSync(join(dbDir, 'seed.sql'), 'utf8');

export const mem = newDb();

// pgcrypto + gen_random_uuid() (usado por la columna users.id).
mem.registerExtension('pgcrypto', (schema) => {
  schema.registerFunction({
    name: 'gen_random_uuid',
    returns: DataType.uuid,
    implementation: () => randomUUID(),
    impure: true,
  });
});

// Aplica el esquema real una sola vez.
mem.public.none(schemaSql);

// Adaptador compatible con el paquete `pg` (lo consume src/db.js vía mock).
export const pgAdapter = mem.adapters.createPg();

/// Restaura la base de datos a su estado inicial (con el seed) entre pruebas.
export function resetDb() {
  mem.public.none(
    'DELETE FROM events; DELETE FROM users; DELETE FROM devices; DELETE FROM esp_status;',
  );
  mem.public.none(seedSql);
}
