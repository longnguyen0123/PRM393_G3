import {
  getAllBranchesWithStock,
  createBranch
} from '../services/branchService.js';

export const getBranches = async (req, res, next) => {
  try {
    const branches = await getAllBranchesWithStock();
    res.json({
      success: true,
      data: branches,
      message: 'Branches fetched successfully'
    });
  } catch (err) {
    next(err);
  }
};

export const createBranchHandler = async (req, res, next) => {
  try {
    const branch = await createBranch(req.body);
    res.status(201).json({
      success: true,
      data: branch,
      message: 'Branch created successfully'
    });
  } catch (err) {
    next(err);
  }
};