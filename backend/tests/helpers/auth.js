// Utilidad compartida por los tests: registra un usuario y devuelve su token.
import request from 'supertest';

export async function registerAndLogin(app, overrides = {}) {
  const user = {
    nombre: 'Usuario Test',
    email: 'user@test.com',
    password: 'secret123',
    ...overrides,
  };
  const res = await request(app).post('/api/auth/register').send(user);
  return { token: res.body.token, user: res.body.user };
}
