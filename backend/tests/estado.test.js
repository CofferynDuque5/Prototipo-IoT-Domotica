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

const DEVICE_KEY = 'test_device_key';

beforeEach(() => resetDb());

describe('API /estado (puente serial)', () => {
  test('GET /api/estado sin clave de dispositivo responde 401', async () => {
    const res = await request(app).get('/api/estado');
    expect(res.status).toBe(401);
  });

  test('GET /api/estado con clave devuelve el estado del relé (false inicial)', async () => {
    const res = await request(app)
      .get('/api/estado')
      .set('x-device-key', DEVICE_KEY);
    expect(res.status).toBe(200);
    expect(res.body).toMatchObject({
      estado: false,
      deviceId: 'dev_luz_sala',
    });
  });

  test('POST /api/estado enciende el relé y GET lo refleja', async () => {
    const post = await request(app)
      .post('/api/estado')
      .set('x-device-key', DEVICE_KEY)
      .send({ estado: true });
    expect(post.status).toBe(200);
    expect(post.body.estado).toBe(true);

    const get = await request(app)
      .get('/api/estado')
      .set('x-device-key', DEVICE_KEY);
    expect(get.body.estado).toBe(true);
  });

  test('POST /api/estado registra un evento visible por la app', async () => {
    const { token } = await registerAndLogin(app);
    await request(app)
      .post('/api/estado')
      .set('x-device-key', DEVICE_KEY)
      .send({ estado: true });

    const events = await request(app)
      .get('/api/events')
      .set('Authorization', `Bearer ${token}`);
    expect(events.body).toHaveLength(1);
    expect(events.body[0]).toMatchObject({
      deviceId: 'dev_luz_sala',
      action: 'encendido',
    });
  });

  test('POST /api/estado con estado no booleano responde 400', async () => {
    const res = await request(app)
      .post('/api/estado')
      .set('x-device-key', DEVICE_KEY)
      .send({ estado: 1 });
    expect(res.status).toBe(400);
  });
});
