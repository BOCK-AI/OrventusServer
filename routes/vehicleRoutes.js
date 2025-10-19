import express from 'express';
import { 
  getAllVehicles, 
  createVehicle, 
  updateVehicle, 
  deleteVehicle 
} from '../controllers/vehicleController.js';
import { authenticateUser } from '../middleware/authentication.js';
// We will add authorizePermissions('admin') to these routes later for security

const router = express.Router();

router.route('/')
  .get(authenticateUser, getAllVehicles)
  .post(authenticateUser, createVehicle);

router.route('/:id')
  .patch(authenticateUser, updateVehicle)
  .delete(authenticateUser, deleteVehicle);

export default router;