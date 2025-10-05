// routes/miscRoutes.js
import express from 'express';
import { getGooglePlaces, getGooglePlaceDetails } from '../controllers/miscController.js';
import { authenticateUser } from '../middleware/authentication.js';

const router = express.Router();

router.route('/places').get(authenticateUser, getGooglePlaces);
router.route('/place-details').get(authenticateUser, getGooglePlaceDetails);

export default router;