import express from 'express';
import { createRide, updateRideStatus, acceptRide, getMyRides } from '../controllers/rideController.js';
import { authenticateUser } from '../middleware/authentication.js';
const router = express.Router();

router.use((req, res, next) => {
  req.io = req.app.get('io');
  next();
});

router.post('/create', authenticateUser, createRide);
router.patch('/accept/:rideId', authenticateUser, acceptRide);
router.patch('/update/:rideId', authenticateUser, updateRideStatus);
router.get('/rides', authenticateUser, getMyRides);

export default router;
