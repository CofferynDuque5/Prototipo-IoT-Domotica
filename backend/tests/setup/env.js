// Variables de entorno para el entorno de pruebas. Se cargan antes de que los
// módulos de la aplicación lean su configuración.
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_jwt_secret';
process.env.JWT_EXPIRES_IN = '1h';
process.env.DEVICE_API_KEY = 'test_device_key';
process.env.ESP_OFFLINE_THRESHOLD_SECONDS = '30';
// DATABASE_URL no se usa en tests: `pg` se sustituye por pg-mem (en memoria).
process.env.DATABASE_URL = 'postgres://test:test@localhost:5432/test';
