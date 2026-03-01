import express from 'express';
import {
  getBranches,
  createBranchHandler
} from '../controllers/branchController.js';

const router = express.Router();

router.get('/', getBranches);
router.post('/', createBranchHandler);

export default router;