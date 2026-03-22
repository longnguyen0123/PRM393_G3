import express from 'express';
import {
  getBranches,
  getBranchDetailHandler,
  createBranchHandler,
  updateBranchHandler,
  deleteBranchHandler,
} from '../controllers/branchController.js';

const router = express.Router();

router.get('/', getBranches);
router.get('/:id/detail', getBranchDetailHandler);
router.post('/', createBranchHandler);
router.put('/:id', updateBranchHandler);
router.delete('/:id', deleteBranchHandler);

export default router;