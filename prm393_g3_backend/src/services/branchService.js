import {
  getAllBranches,
  createBranch as createBranchRepository,
  updateBranchById,
  deleteBranchById,
} from '../repositories/branchRepository.js';

import { getTotalStockByBranch }
  from '../repositories/inventoryRepository.js';

export const getAllBranchesWithStock = async () => {
  const branches = await getAllBranches();
  const stockData = await getTotalStockByBranch();

  const stockMap = {};
  stockData.forEach(item => {
    stockMap[item._id] = item.totalItemsInStock;
  });

  return branches.map(branch => ({
    ...branch,
    totalItemsInStock: stockMap[branch._id] || 0
  }));
};

export const createBranch = async (data) => {
  return await createBranchRepository(data);
};

export const updateBranch = async (id, data) => {
  const updated = await updateBranchById(id, data);

  if (!updated) {
    const error = new Error('Branch not found');
    error.status = 404;
    throw error;
  }

  return updated;
};

export const deleteBranch = async (id) => {
  const deleted = await deleteBranchById(id);

  if (!deleted) {
    const error = new Error('Branch not found');
    error.status = 404;
    throw error;
  }

  return deleted;
};