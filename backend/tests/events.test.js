import { jest } from '@jest/globals';
import request from 'supertest';
import { pgAdapter, resetDb } from './helpers/memoryDb.js';
import { registerAndLogin } from './helpers/auth.js';

jest.unstable_mockModule('pg', () => ({
  default: pgAdapter,
  Pool: pgAdapter.Pool,
  Client: pgAdapter.Client,
}));

const { app } = await import('../src/app.js');

let token;

beforeEach(async () => {
  resetDb();
  ({ token } = await registerAndLogin(app));
});

async function toggle(id, estado) {
  return request(app)
    .post(`/api/devices/${id}/state`)
    .set('Authorization', `Bearer ${token}`)
    .send({ estado });
}

describe('Events API', () => {
  test('GET /api/events requiere autenticación', async () => {
    const res = await request(app).get('/api/events');
    expect(res.status).toBe(401);
  });

  test('El historial empieza vacío', async () => {
    const res = await request(app)
      .get('/api/events')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });

  test('Cada cambio de estado genera un evento con la acción correcta', async () => {
    await toggle('dev_luz_sala', true);
    await toggle('dev_luz_sala', false);

    const res = await request(app)
      .get('/api/events')
      .set('Authorization', `Bearer ${token}`);

    expect(res.body).toHaveLength(2);
    // Orden: más reciente primero.
    expect(res.body[0].action).toBe('apagado');
    expect(res.body[1].action).toBe('encendido');
    expect(res.body[0].timestamp).toBeGreaterThanOrEqual(res.body[1].timestamp);
  });
});
