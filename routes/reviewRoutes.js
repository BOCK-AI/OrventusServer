// routes/reviewRoutes.js
import express from 'express';
import { getAllReviews } from '../controllers/reviewController.js';
import { authenticateUser } from '../middleware/authentication.js';

const router = express.Router();

router.route('/').get(authenticateUser, getAllReviews);

export default router;