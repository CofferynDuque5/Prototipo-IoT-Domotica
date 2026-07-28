import { Router } from 'express';
import { requireDeviceKey } from '../middleware/auth.js';
import { getEstado, setEstado } from '../controllers/estadoController.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

// Endpoints consumidos por el puente serial (autenticados con x-device-key).
router.get('/', requireDeviceKey, asyncHandler(getEstado));
router.post('/', requireDeviceKey, asyncHandler(setEstado));

export default router;
