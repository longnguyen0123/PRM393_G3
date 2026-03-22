import express from 'express';
import {
  createUserAdminHandler,
  listBranchManagersAdminHandler,
  listInventoryStaffAdminHandler,
  patchUserStatusAdminHandler,
} from '../controllers/adminUserController.js';
import { authenticate, requireAdmin } from '../middleware/authMiddleware.js';

const router = express.Router();

router.use(authenticate, requireAdmin);

router.get('/branch-managers', listBranchManagersAdminHandler);
router.get('/inventory-staff', listInventoryStaffAdminHandler);
router.post('/', createUserAdminHandler);
router.patch('/:id/status', patchUserStatusAdminHandler);

export default router;
