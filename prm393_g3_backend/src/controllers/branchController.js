import { getAllBranchesWithStock } from '../services/branchService.js';

export const getBranches = async (req, res) => {
  try {
    const branches = await getAllBranchesWithStock();

    return res.status(200).json({
      success: true,
      data: branches,
      message: "Branches fetched successfully"
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message
    });
  }
};