import { Router } from 'express';
import { requireAuth, requireDeviceKey } from '../middleware/auth.js';
import { getEsp, postTelemetry } from '../controllers/espController.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

// App: consulta el estado del ESP.
router.get('/', requireAuth, asyncHandler(getEsp));

// ESP8266: publica su telemetría.
router.post('/telemetry', requireDeviceKey, asyncHandler(postTelemetry));

export default router;
