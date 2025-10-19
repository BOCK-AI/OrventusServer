// In routes/userRoutes.js

import express from 'express';
import { authenticateUser } from '../middleware/authentication.js';
import { body } from 'express-validator'; // For validation
import { getMyProfile, updateMyProfile, getAllUsers, updateUserStatus } from '../controllers/userController.js';
const router = express.Router();

const validateUpdate = [body('name').notEmpty().withMessage('Name cannot be empty')];

router.route('/').get(authenticateUser, getAllUsers);
router.route('/:id/status').patch(authenticateUser, updateUserStatus);

// Chain the GET and PUT methods for the '/me' route
router.route('/me')
  .get(authenticateUser, getMyProfile)
  .put(authenticateUser, validateUpdate, updateMyProfile); // <-- ADD THIS

export default router;