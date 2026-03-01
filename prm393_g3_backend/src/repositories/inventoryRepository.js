import Inventory from '../models/inventory.js';

export const getTotalStockByBranch = async () => {
  return await Inventory.aggregate([
    {
      $group: {
        _id: "$branchId",
        totalItemsInStock: { $sum: "$quantity" }
      }
    }
  ]);
};