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
let token;

beforeEach(async () => {
  resetDb();
  ({ token } = await registerAndLogin(app));
});

describe('Devices API', () => {
  test('GET /api/devices requiere autenticación', async () => {
    const res = await request(app).get('/api/devices');
    expect(res.status).toBe(401);
  });

  test('GET /api/devices devuelve los 4 dispositivos del seed', async () => {
    const res = await request(app)
      .get('/api/devices')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(4);
    const luz = res.body.find((d) => d.id === 'dev_luz_sala');
    expect(luz).toMatchObject({ nombre: 'Luz Sala', gpio: 5, estado: false });
  });

  test('POST /:id/state enciende el dispositivo y registra un evento', async () => {
    const res = await request(app)
      .post('/api/devices/dev_luz_sala/state')
      .set('Authorization', `Bearer ${token}`)
      .send({ estado: true });

    expect(res.status).toBe(200);
    expect(res.body.estado).toBe(true);
    expect(res.body.ultimaActualizacion).toBeGreaterThan(0);

    const events = await request(app)
      .get('/api/events')
      .set('Authorization', `Bearer ${token}`);
    expect(events.body).toHaveLength(1);
    expect(events.body[0]).toMatchObject({
      deviceId: 'dev_luz_sala',
      deviceName: 'Luz Sala',
      action: 'encendido',
    });
  });

  test('POST /:id/state con estado no booleano responde 400', async () => {
    const res = await request(app)
      .post('/api/devices/dev_luz_sala/state')
      .set('Authorization', `Bearer ${token}`)
      .send({ estado: 'on' });
    expect(res.status).toBe(400);
  });

  test('POST /:id/state sobre dispositivo inexistente responde 404', async () => {
    const res = await request(app)
      .post('/api/devices/no_existe/state')
      .set('Authorization', `Bearer ${token}`)
      .send({ estado: true });
    expect(res.status).toBe(404);
  });

  test('GET /device/list con clave de dispositivo funciona; sin ella 401', async () => {
    const ok = await request(app)
      .get('/api/devices/device/list')
      .set('x-device-key', DEVICE_KEY);
    expect(ok.status).toBe(200);
    expect(ok.body).toHaveLength(4);

    const bad = await request(app)
      .get('/api/devices/device/list')
      .set('x-device-key', 'clave-incorrecta');
    expect(bad.status).toBe(401);
  });

  test('POST /:id/confirm (ESP) marca el dispositivo online', async () => {
    const res = await request(app)
      .post('/api/devices/dev_ventilador/confirm')
      .set('x-device-key', DEVICE_KEY)
      .send({ estado: true });

    expect(res.status).toBe(200);
    expect(res.body.online).toBe(true);
    expect(res.body.estado).toBe(true);
  });

  test('POST /:id/confirm sin clave de dispositivo responde 401', async () => {
    const res = await request(app)
      .post('/api/devices/dev_ventilador/confirm')
      .send({ estado: true });
    expect(res.status).toBe(401);
  });
});
