import { Router } from 'express';
import { authenticate } from '../middleware/authMiddleware.js';
import {
  createTransferRequestHandler,
  listTransfersHandler,
  getTransferByIdHandler,
  updatePendingTransferHandler,
  approveTransferHandler,
  rejectTransferHandler,
} from '../controllers/stockMovementController.js';

const router = Router();

router.post('/transfers', authenticate, createTransferRequestHandler);
router.get('/transfers', authenticate, listTransfersHandler);
router.get('/transfers/:id', authenticate, getTransferByIdHandler);
router.patch('/transfers/:id', authenticate, updatePendingTransferHandler);
router.post('/transfers/:id/approve', authenticate, approveTransferHandler);
router.post('/transfers/:id/reject', authenticate, rejectTransferHandler);

export default router;
