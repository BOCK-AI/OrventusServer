// routes/authRoutes.js

import express from 'express';
// Import our new verifyOtp controller
import { loginOrRegister, verifyOtp } from '../controllers/authController.js';
import { body } from 'express-validator';

const router = express.Router();

// --- Validation Middleware ---
const validateLogin = [
  body('phone').notEmpty().withMessage('Phone number is required'),
  body('role').notEmpty().withMessage('Role is required'),
];

const validateVerify = [
  body('phone').notEmpty().withMessage('Phone number is required'),
  body('otp').isLength({ min: 4, max: 4 }).withMessage('OTP must be 4 digits'),
];


// --- API ROUTES ---
router.route('/login').post(validateLogin, loginOrRegister);

// --- NEW VERIFY ROUTE ---
router.route('/verify').post(validateVerify, verifyOtp);


export default router;