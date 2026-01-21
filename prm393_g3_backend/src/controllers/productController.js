import productService from '../services/productService.js';
import { parseObjectIdParam, validateRequiredFields } from '../utils/validators.js';

const productController = {
  getAll: async (_req, res, next) => {
    try {
      const products = await productService.getAll();
      res.json(products);
    } catch (err) {
      next(err);
    }
  },

  getById: async (req, res, next) => {
    try {
      const id = parseObjectIdParam(req.params.id);
      const product = await productService.getById(id);
      if (!product) return res.status(404).json({ message: 'Product not found' });
      res.json(product);
    } catch (err) {
      next(err);
    }
  },

  create: async (req, res, next) => {
    try {
      validateRequiredFields(req.body, ['name', 'price', 'stock', 'storeId']);
      parseObjectIdParam(req.body.storeId);
      const created = await productService.create(req.body);
      res.status(201).json(created);
    } catch (err) {
      next(err);
    }
  },

  updateStock: async (req, res, next) => {
    try {
      const id = parseObjectIdParam(req.params.id);
      validateRequiredFields(req.body, ['delta']);
      const updated = await productService.updateStock(id, Number(req.body.delta));
      res.json(updated);
    } catch (err) {
      next(err);
    }
  },
};

export default productController;
