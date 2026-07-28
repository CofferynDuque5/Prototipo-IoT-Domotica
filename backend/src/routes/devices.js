import { Router } from 'express';
import { requireAuth, requireDeviceKey } from '../middleware/auth.js';
import {
  listDevices,
  getDevice,
  setDeviceState,
  confirmDeviceState,
} from '../controllers/deviceController.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

// App (usuarios autenticados).
router.get('/', requireAuth, asyncHandler(listDevices));
router.get('/:id', requireAuth, asyncHandler(getDevice));
router.post('/:id/state', requireAuth, asyncHandler(setDeviceState));

// ESP8266 (clave de dispositivo). Puede leer la lista para sincronizar relés.
router.get('/device/list', requireDeviceKey, asyncHandler(listDevices));
router.post('/:id/confirm', requireDeviceKey, asyncHandler(confirmDeviceState));

export default router;
