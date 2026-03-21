import Branch from '../models/branches.js';

export const getAllBranches = async () => {
  return await Branch.find().lean();
};

export const createBranch = async (data) => {
  return await Branch.create(data);
};

export const updateBranchById = async (id, data) => {
  return await Branch.findByIdAndUpdate(id, data, {
    new: true,
    runValidators: true,
  }).lean();
};

export const deleteBranchById = async (id) => {
  return await Branch.findByIdAndDelete(id).lean();
};