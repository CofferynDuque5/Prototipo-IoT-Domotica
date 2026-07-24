import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';
import {
  register,
  login,
  me,
  updateProfile,
  forgotPassword,
} from '../controllers/authController.js';
import { asyncHandler } from '../utils/asyncHandler.js';

const router = Router();

router.post('/register', asyncHandler(register));
router.post('/login', asyncHandler(login));
router.post('/forgot-password', asyncHandler(forgotPassword));
router.get('/me', requireAuth, asyncHandler(me));
router.patch('/me', requireAuth, asyncHandler(updateProfile));

export default router;
