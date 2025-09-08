// routes/rideRoutes.js

import express from 'express';
import {
  createRide,
  getAllRides,
  acceptRide,
  getAvailableRides,
  updateRideStatus,
  getMyRides,
  getRideEstimates, // <-- NEW IMPORT
} from '../controllers/rideController.js';

import { authenticateUser } from '../middleware/authentication.js';
import { authorizePermissions } from '../middleware/authorization.js';
import { validateCreateRide, validateRideEstimate } from '../middleware/validation.js'; // <-- NEW IMPORT

const router = express.Router();

// --- NEW ROUTE FOR GETTING FARE ESTIMATES ---
// Any authenticated user can get an estimate.
router.route('/estimate').post(authenticateUser, validateRideEstimate, getRideEstimates);


// --- EXISTING ROUTES ---
router.route('/my-history').get(authenticateUser, getMyRides);
router.route('/')
  .post(authenticateUser, validateCreateRide, createRide)
  .get(getAllRides);
router.route('/available').get(authenticateUser, authorizePermissions('rider'), getAvailableRides);
router.route('/:id/status').put(authenticateUser, authorizePermissions('rider'), updateRideStatus);
router.route('/:id/accept').put(authenticateUser, authorizePermissions('rider'), acceptRide);

export default router;