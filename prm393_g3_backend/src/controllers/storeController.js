import storeService from '../services/storeService.js';
import { parseObjectIdParam } from '../utils/validators.js';

const storeController = {
  getAll: async (_req, res, next) => {
    try {
      const stores = await storeService.getAll();
      res.json(stores);
    } catch (err) {
      next(err);
    }
  },

  getById: async (req, res, next) => {
    try {
      const id = parseObjectIdParam(req.params.id);
      const store = await storeService.getById(id);
      if (!store) return res.status(404).json({ message: 'Store not found' });
      res.json(store);
    } catch (err) {
      next(err);
    }
  },
};

export default storeController;
