import { jest } from '@jest/globals';
import request from 'supertest';
import { pgAdapter, resetDb } from './helpers/memoryDb.js';

// Sustituye el paquete `pg` por el adaptador de pg-mem (Postgres en memoria).
jest.unstable_mockModule('pg', () => ({
  default: pgAdapter,
  Pool: pgAdapter.Pool,
  Client: pgAdapter.Client,
}));

const { app } = await import('../src/app.js');

beforeEach(() => resetDb());

describe('Auth API', () => {
  const user = {
    nombre: 'Ana Pérez',
    email: 'ana@test.com',
    password: 'secret123',
  };

  test('POST /register crea un usuario y devuelve token', async () => {
    const res = await request(app).post('/api/auth/register').send(user);
    expect(res.status).toBe(201);
    expect(typeof res.body.token).toBe('string');
    expect(res.body.user).toMatchObject({
      nombre: user.nombre,
      email: user.email,
    });
    expect(res.body.user.uid).toBeDefined();
  });

  test('POST /register rechaza email duplicado con 409', async () => {
    await request(app).post('/api/auth/register').send(user);
    const res = await request(app).post('/api/auth/register').send(user);
    expect(res.status).toBe(409);
  });

  test('POST /register valida email y contraseña', async () => {
    const badEmail = await request(app)
      .post('/api/auth/register')
      .send({ ...user, email: 'no-es-email' });
    expect(badEmail.status).toBe(400);

    const shortPass = await request(app)
      .post('/api/auth/register')
      .send({ ...user, password: '123' });
    expect(shortPass.status).toBe(400);
  });

  test('POST /login con credenciales correctas devuelve token', async () => {
    await request(app).post('/api/auth/register').send(user);
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: user.email, password: user.password });
    expect(res.status).toBe(200);
    expect(res.body.token).toBeDefined();
  });

  test('POST /login con contraseña incorrecta responde 401', async () => {
    await request(app).post('/api/auth/register').send(user);
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: user.email, password: 'incorrecta' });
    expect(res.status).toBe(401);
  });

  test('GET /me devuelve el perfil con token válido y 401 sin token', async () => {
    const reg = await request(app).post('/api/auth/register').send(user);
    const token = reg.body.token;

    const ok = await request(app)
      .get('/api/auth/me')
      .set('Authorization', `Bearer ${token}`);
    expect(ok.status).toBe(200);
    expect(ok.body.email).toBe(user.email);

    const noToken = await request(app).get('/api/auth/me');
    expect(noToken.status).toBe(401);
  });

  test('PATCH /me actualiza el nombre', async () => {
    const reg = await request(app).post('/api/auth/register').send(user);
    const res = await request(app)
      .patch('/api/auth/me')
      .set('Authorization', `Bearer ${reg.body.token}`)
      .send({ nombre: 'Ana María' });
    expect(res.status).toBe(200);
    expect(res.body.nombre).toBe('Ana María');
  });

  test('POST /forgot-password responde 200 (existente y no existente)', async () => {
    await request(app).post('/api/auth/register').send(user);

    const existing = await request(app)
      .post('/api/auth/forgot-password')
      .send({ email: user.email });
    expect(existing.status).toBe(200);

    const unknown = await request(app)
      .post('/api/auth/forgot-password')
      .send({ email: 'nadie@test.com' });
    expect(unknown.status).toBe(200);

    const invalid = await request(app)
      .post('/api/auth/forgot-password')
      .send({ email: 'malo' });
    expect(invalid.status).toBe(400);
  });
});
