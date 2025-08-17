// routes/authRoutes.js
import express from 'express';
import { refreshToken, auth, logout } from '../controllers/userController.js';


const router = express.Router();

router.post('/refresh-token', refreshToken);
router.post('/signin', auth);
router.post('/logout', logout); // <-- ADD THIS NEW LINE


export default router;