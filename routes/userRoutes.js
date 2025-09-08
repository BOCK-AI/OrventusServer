// In routes/userRoutes.js

import express from 'express';
import { getMe, updateMe } from '../controllers/userController.js';
import { authenticateUser } from '../middleware/authentication.js';
// Import our new validation middleware
import { validateUpdateUser } from '../middleware/validation.js';

const router = express.Router();

router.route('/me')
  .get(authenticateUser, getMe)
  // Add the validation middleware to the PUT route
  .put(validateUpdateUser, authenticateUser, updateMe);

export default router;