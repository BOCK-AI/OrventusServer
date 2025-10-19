// routes/statsRoutes.js

import express from 'express';
import { getDashboardStats, getEarningsReport } from '../controllers/statsController.js';

// --- THIS IS THE MISSING IMPORT ---
import { authenticateUser } from '../middleware/authentication.js';
// --- END FIX ---

const router = express.Router();

// Both routes now correctly use the imported middleware
router.route('/dashboard').get(authenticateUser, getDashboardStats);
router.route('/earnings').get(authenticateUser, getEarningsReport);

export default router;