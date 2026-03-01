import { getAllBranches } from '../repositories/branchRepository.js';
import { getTotalStockByBranch } from '../repositories/inventoryRepository.js';

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