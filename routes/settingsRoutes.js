import express from 'express';
import { getAllSettings, updateSettings } from '../controllers/settingsController.js';
import { authenticateUser } from '../middleware/authentication.js';

const router = express.Router();

router.route('/')
  .get(authenticateUser, getAllSettings)
  .patch(authenticateUser, updateSettings);

export default router;