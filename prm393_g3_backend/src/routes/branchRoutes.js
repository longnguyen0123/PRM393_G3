import express from 'express';
import {
  getBranches,
  getBranchDetailHandler,
  getBranchManagerCandidatesHandler,
  assignBranchManagerHandler,
  createBranchHandler,
  updateBranchHandler,
  listInventoryStaffHandler,
  createInventoryStaffHandler,
  deactivateInventoryStaffHandler,
} from '../controllers/branchController.js';
import {
  authenticate,
  requireAdmin,
  requireAdminOrManagerOfBranch,
  requireBranchManagerInventoryStaffRead,
  requireDelegatedBranchManagerInventoryWrite,
} from '../middleware/authMiddleware.js';

const router = express.Router();

const adminOnly = [authenticate, requireAdmin];
const branchManagerInventoryRead = [
  authenticate,
  requireBranchManagerInventoryStaffRead,
];
const branchManagerInventoryWrite = [
  authenticate,
  requireDelegatedBranchManagerInventoryWrite,
];

router.get('/', authenticate, getBranches);
router.get(
  '/:id/detail',
  authenticate,
  requireAdminOrManagerOfBranch,
  getBranchDetailHandler,
);
router.get(
  '/:id/inventory-staff',
  ...branchManagerInventoryRead,
  listInventoryStaffHandler,
);
router.post(
  '/:id/inventory-staff',
  ...branchManagerInventoryWrite,
  createInventoryStaffHandler,
);
router.delete(
  '/:id/inventory-staff/:userId',
  ...branchManagerInventoryWrite,
  deactivateInventoryStaffHandler,
);
router.get('/:id/manager-candidates', ...adminOnly, getBranchManagerCandidatesHandler);
router.patch('/:id/branch-manager', ...adminOnly, assignBranchManagerHandler);
router.post('/', ...adminOnly, createBranchHandler);
router.put('/:id', ...adminOnly, updateBranchHandler);

export default router;
