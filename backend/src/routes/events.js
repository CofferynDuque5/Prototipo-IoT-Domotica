import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import { listEvents } from '../controllers/eventController.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

router.get('/', requireAuth, asyncHandler(listEvents));

export default router;
