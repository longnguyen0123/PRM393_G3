import mongoose from 'mongoose';
import Branch from '../models/branches.js';

export const getAllBranches = async () => {
  return await Branch.find().lean();
};

export const getBranchById = async (id) => {
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return null;
  }
  return await Branch.findById(id).lean();
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