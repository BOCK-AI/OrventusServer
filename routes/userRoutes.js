// routes/userRoutes.js
import express from 'express';
import { getMe } from '../controllers/userController.js';
// Import the newly named middleware
import { authenticateUser } from '../middleware/authentication.js';

const router = express.Router();

// Use the new middleware name
router.get('/me', authenticateUser, getMe);

export default router;