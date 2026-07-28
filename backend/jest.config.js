// Configuración de Jest para un backend en ES Modules.
//
// Los tests se ejecutan con `node --experimental-vm-modules` (ver el script
// "test" en package.json) para soportar `import`/`export` sin transpilar.
export default {
  testEnvironment: 'node',
  // No se transforma código: se usan ESM nativos.
  transform: {},
  testMatch: ['**/tests/**/*.test.js'],
  setupFiles: ['<rootDir>/tests/setup/env.js'],
  clearMocks: true,
  verbose: true,
};
