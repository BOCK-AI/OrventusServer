// routes/promoCodeRoutes.js
import express from 'express';
import { 
  getAllPromoCodes, 
  createPromoCode, 
  updatePromoCode, 
  deletePromoCode 
} from '../controllers/promoCodeController.js';
import { authenticateUser } from '../middleware/authentication.js';

const router = express.Router();

router.route('/')
  .get(authenticateUser, getAllPromoCodes)
  .post(authenticateUser, createPromoCode);

router.route('/:id')
  .patch(authenticateUser, updatePromoCode)
  .delete(authenticateUser, deletePromoCode);

export default router;