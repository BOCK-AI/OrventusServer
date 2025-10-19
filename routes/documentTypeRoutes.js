import express from 'express';
import { 
  getAllDocumentTypes, 
  createDocumentType, 
  updateDocumentType, 
  deleteDocumentType 
} from '../controllers/documentTypeController.js';
import { authenticateUser } from '../middleware/authentication.js';

const router = express.Router();

router.route('/')
  .get(authenticateUser, getAllDocumentTypes)
  .post(authenticateUser, createDocumentType);

router.route('/:id')
  .patch(authenticateUser, updateDocumentType)
  .delete(authenticateUser, deleteDocumentType);

export default router;