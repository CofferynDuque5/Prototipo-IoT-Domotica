// Carga y validación de la configuración desde variables de entorno.
import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  databaseUrl:
    process.env.DATABASE_URL ||
    'postgres://iot_user:iot_password@localhost:5432/iot_domotica',
  jwtSecret: process.env.JWT_SECRET || 'dev_secret_change_me',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
  deviceApiKey: process.env.DEVICE_API_KEY || 'dev_device_key_change_me',
  espOfflineThresholdSeconds: parseInt(
    process.env.ESP_OFFLINE_THRESHOLD_SECONDS || '30',
    10,
  ),
};

// Advertencias en caso de usar valores por defecto inseguros en producción.
if (config.jwtSecret === 'dev_secret_change_me') {
  console.warn('[config] ⚠️  JWT_SECRET usa el valor por defecto. Cámbialo.');
}
if (config.deviceApiKey === 'dev_device_key_change_me') {
  console.warn('[config] ⚠️  DEVICE_API_KEY usa el valor por defecto. Cámbialo.');
}
