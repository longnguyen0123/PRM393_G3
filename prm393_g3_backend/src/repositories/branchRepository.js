import Branch from '../models/branches.js';

export const getAllBranches = async () => {
  return await Branch.find().lean();
};

export const createBranch = async (data) => {
  return await Branch.create(data);
};