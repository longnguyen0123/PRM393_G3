import productRepository from '../repositories/productRepository.js';
import storeRepository from '../repositories/storeRepository.js';

const productService = {
  getAll: () => productRepository.findAll(),

  getById: (id) => productRepository.findById(id),

  create: async (payload) => {
    const store = await storeRepository.findById(payload.storeId);
    if (!store) {
      const error = new Error('Store not found for product');
      error.status = 400;
      throw error;
    }
    return productRepository.create({
      name: payload.name,
      price: Number(payload.price),
      stock: Number(payload.stock),
      storeId: payload.storeId,
    });
  },

  updateStock: async (id, delta) => {
    const product = await productRepository.findById(id);
    if (!product) {
      const error = new Error('Product not found');
      error.status = 404;
      throw error;
    }
    if (product.stock + delta < 0) {
      const error = new Error('Stock cannot be negative');
      error.status = 400;
      throw error;
    }
    return productRepository.updateStock(id, delta);
  },
};

export default productService;
