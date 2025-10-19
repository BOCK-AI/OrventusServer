import express from 'express';
import { getAllNotifications, createNotification } from '../controllers/notificationController.js';
import { authenticateUser } from '../middleware/authentication.js';

const router = express.Router();

router.route('/')
  .get(authenticateUser, getAllNotifications)
  .post(authenticateUser, createNotification);

export default router;