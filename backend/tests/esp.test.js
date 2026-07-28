import { jest } from '@jest/globals';
import request from 'supertest';
import { pgAdapter, resetDb, mem } from './helpers/memoryDb.js';
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

describe('ESP telemetry API', () => {
  const telemetry = {
    ip: '192.168.1.50',
    ssid: 'MiRedWiFi',
    rssi: -55,
    uptime: 3600,
    firmware: '1.0.0',
    freeHeap: 41000,
  };

  test('POST /telemetry sin clave de dispositivo responde 401', async () => {
    const res = await request(app).post('/api/esp/telemetry').send(telemetry);
    expect(res.status).toBe(401);
  });

  test('POST /telemetry con clave guarda los datos y marca online', async () => {
    const res = await request(app)
      .post('/api/esp/telemetry')
      .set('x-device-key', DEVICE_KEY)
      .send(telemetry);

    expect(res.status).toBe(200);
    expect(res.body).toMatchObject({
      online: true,
      ip: telemetry.ip,
      ssid: telemetry.ssid,
      rssi: telemetry.rssi,
    });
  });

  test('GET /api/esp requiere autenticación', async () => {
    const res = await request(app).get('/api/esp');
    expect(res.status).toBe(401);
  });

  test('GET /api/esp refleja la última telemetría (online)', async () => {
    await request(app)
      .post('/api/esp/telemetry')
      .set('x-device-key', DEVICE_KEY)
      .send(telemetry);

    const res = await request(app)
      .get('/api/esp')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.online).toBe(true);
    expect(res.body.ip).toBe(telemetry.ip);
  });

  test('El ESP se considera offline si el heartbeat es antiguo', async () => {
    // Publica telemetría (online) y luego envejece el último heartbeat.
    await request(app)
      .post('/api/esp/telemetry')
      .set('x-device-key', DEVICE_KEY)
      .send(telemetry);

    // last_seen muy antiguo (epoch = 1000 ms) → supera el umbral offline.
    mem.public.none('UPDATE esp_status SET last_seen = 1000 WHERE id = 1');

    const res = await request(app)
      .get('/api/esp')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.online).toBe(false);
  });
});
