import mongoose from 'mongoose';

export const parseObjectIdParam = (value) => {
  if (!mongoose.Types.ObjectId.isValid(value)) {
    const error = new Error('Invalid id parameter');
    error.status = 400;
    throw error;
  }
  return value;
};

export const validateRequiredFields = (body, requiredKeys) => {
  const missing = requiredKeys.filter((key) => body[key] === undefined || body[key] === null);
  if (missing.length > 0) {
    const error = new Error(`Missing fields: ${missing.join(', ')}`);
    error.status = 400;
    throw error;
  }
};
