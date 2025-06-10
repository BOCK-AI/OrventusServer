import express from 'express';
import { createRide, updateRideStatus, acceptRide, getMyRides } from '../controllers/rideController.js';
import auth from '../middleware/authentication.js';

const router = express.Router();

router.use((req, res, next) => {
  req.io = req.app.get('io');
  next();
});

router.post('/create', auth, createRide);
router.patch('/accept/:rideId', auth, acceptRide);
router.patch('/update/:rideId', auth, updateRideStatus);
router.get('/rides', auth, getMyRides);

export default router;
