import mongoose from 'mongoose';
import {
  getAllBranches,
  getBranchById,
  createBranch as createBranchRepository,
  updateBranchById,
  deleteBranchById,
} from '../repositories/branchRepository.js';

import {
  getTotalStockByBranch,
  getInventoryLinesWithProductsForBranch,
} from '../repositories/inventoryRepository.js';
import { findBranchManagerByBranchId } from '../repositories/userRepository.js';

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

export const getBranchDetail = async (id) => {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    const error = new Error('Invalid branch id');
    error.status = 400;
    throw error;
  }

  const branch = await getBranchById(id);
  if (!branch) {
    const error = new Error('Branch not found');
    error.status = 404;
    throw error;
  }

  const stockData = await getTotalStockByBranch();
  const stockMap = {};
  stockData.forEach((item) => {
    stockMap[String(item._id)] = item.totalItemsInStock;
  });

  const [branchManager, inventoryLines] = await Promise.all([
    findBranchManagerByBranchId(id),
    getInventoryLinesWithProductsForBranch(id),
  ]);

  return {
    branch: {
      ...branch,
      totalItemsInStock: stockMap[String(branch._id)] || 0,
    },
    branchManager,
    inventoryLines,
  };
};