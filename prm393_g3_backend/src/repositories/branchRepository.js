import Branch from '../models/branches.js';

export const getAllBranches = async () => {
  return await Branch.find().lean();
};