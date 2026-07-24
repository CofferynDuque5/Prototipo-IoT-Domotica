import { jest } from '@jest/globals';
import http from 'node:http';
import request from 'supertest';
import { WebSocket } from 'ws';
import { pgAdapter, resetDb } from './helpers/memoryDb.js';
import { registerAndLogin } from './helpers/auth.js';

jest.unstable_mockModule('pg', () => ({
  default: pgAdapter,
  Pool: pgAdapter.Pool,
  Client: pgAdapter.Client,
}));

const { app } = await import('../src/app.js');
const { initWebSocket } = await import('../src/ws.js');

let server;
let port;
let token;

beforeAll(async () => {
  server = http.createServer(app);
  initWebSocket(server);
  await new Promise((resolve) => server.listen(0, resolve));
  port = server.address().port;
});

afterAll(async () => {
  await new Promise((resolve) => server.close(resolve));
});

beforeEach(async () => {
  resetDb();
  ({ token } = await registerAndLogin(app));
});

/// Espera hasta que `predicate` sea verdadero o se agote el tiempo.
function waitFor(predicate, timeout = 2000) {
  return new Promise((resolve, reject) => {
    const start = Date.now();
    const timer = setInterval(() => {
      if (predicate()) {
        clearInterval(timer);
        resolve();
      } else if (Date.now() - start > timeout) {
        clearInterval(timer);
        reject(new Error('waitFor: tiempo agotado'));
      }
    }, 20);
  });
}

function openSocket(tk) {
  const ws = new WebSocket(`ws://localhost:${port}/ws?token=${tk}`);
  const messages = [];
  ws.on('message', (raw) => messages.push(JSON.parse(raw.toString())));
  return { ws, messages };
}

describe('WebSocket en tiempo real', () => {
  test('rechaza la conexión con token inválido', async () => {
    const ws = new WebSocket(`ws://localhost:${port}/ws?token=invalido`);
    const code = await new Promise((resolve) => ws.on('close', resolve));
    expect(code).toBe(4001);
  });

  test('al conectar envía una instantánea (devices, esp, events)', async () => {
    const { ws, messages } = openSocket(token);
    await waitFor(() => {
      const types = messages.map((m) => m.type);
      return (
        types.includes('devices') &&
        types.includes('esp') &&
        types.includes('events')
      );
    });
    const devicesMsg = messages.find((m) => m.type === 'devices');
    expect(devicesMsg.payload).toHaveLength(4);
    ws.close();
  });

  test('difunde el cambio cuando se enciende un dispositivo por REST', async () => {
    const { ws, messages } = openSocket(token);

    // Espera la instantánea inicial.
    await waitFor(() => messages.some((m) => m.type === 'devices'));
    const initialDevicesCount = messages.filter((m) => m.type === 'devices').length;

    // Cambia el estado por REST -> el backend debe difundir por WebSocket.
    await request(app)
      .post('/api/devices/dev_luz_sala/state')
      .set('Authorization', `Bearer ${token}`)
      .send({ estado: true });

    await waitFor(
      () =>
        messages.filter((m) => m.type === 'devices').length >
        initialDevicesCount,
    );

    const lastDevices = [...messages]
      .reverse()
      .find((m) => m.type === 'devices');
    const luz = lastDevices.payload.find((d) => d.id === 'dev_luz_sala');
    expect(luz.estado).toBe(true);

    // También se difunde el nuevo evento.
    await waitFor(() => messages.some((m) => m.type === 'events'));
    ws.close();
  });
});
