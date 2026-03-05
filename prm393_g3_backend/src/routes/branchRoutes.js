import express from 'express';
import {
  getBranches,
  createBranchHandler,
  updateBranchHandler,
  deleteBranchHandler,
} from '../controllers/branchController.js';

const router = express.Router();

router.get('/', getBranches);
router.post('/', createBranchHandler);
router.put('/:id', updateBranchHandler);
router.delete('/:id', deleteBranchHandler);

export default router;