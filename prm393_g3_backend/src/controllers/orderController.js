import orderService from '../services/orderService.js';
import { parseObjectIdParam, validateRequiredFields } from '../utils/validators.js';

const orderController = {
  getAll: async (_req, res, next) => {
    try {
      const orders = await orderService.getAll();
      res.json(orders);
    } catch (err) {
      next(err);
    }
  },

  create: async (req, res, next) => {
    try {
      validateRequiredFields(req.body, ['storeId', 'items']);
      parseObjectIdParam(req.body.storeId);
      const created = await orderService.create(req.body);
      res.status(201).json(created);
    } catch (err) {
      next(err);
    }
  },
};

export default orderController;
