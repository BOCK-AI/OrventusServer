// In routes/userRoutes.js

import express from 'express';
import { getMyProfile, updateMyProfile } from '../controllers/userController.js'; // Add import
import { authenticateUser } from '../middleware/authentication.js';
import { body } from 'express-validator'; // For validation

const router = express.Router();

const validateUpdate = [body('name').notEmpty().withMessage('Name cannot be empty')];

// Chain the GET and PUT methods for the '/me' route
router.route('/me')
  .get(authenticateUser, getMyProfile)
  .put(authenticateUser, validateUpdate, updateMyProfile); // <-- ADD THIS

export default router;