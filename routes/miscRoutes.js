// routes/miscRoutes.js
import express from 'express';
import { getGooglePlaces } from '../controllers/miscController.js';
import { authenticateUser } from '../middleware/authentication.js';

const router = express.Router();

// Any authenticated user can use the places search
router.route('/places').get(authenticateUser, getGooglePlaces);

export default router;