import mongoose from 'mongoose';
import orderRepository from '../repositories/orderRepository.js';
import productRepository from '../repositories/productRepository.js';
import storeRepository from '../repositories/storeRepository.js';

const orderService = {
  getAll: () => orderRepository.findAll(),

  create: async ({ storeId, items }) => {
    const session = await mongoose.startSession();
    session.startTransaction();
    try {
      const store = await storeRepository.findById(storeId, session);
      if (!store) {
        const error = new Error('Store not found for order');
        error.status = 400;
        throw error;
      }

      let total = 0;
      const normalizedItems = [];

      for (const item of items) {
        const product = await productRepository.findById(item.productId, session);
        if (!product) {
          const error = new Error(`Product ${item.productId} not found`);
          error.status = 400;
          throw error;
        }
        if (product.stock < item.quantity) {
          const error = new Error(`Insufficient stock for ${product.name}`);
          error.status = 400;
          throw error;
        }

        total += product.price * item.quantity;
        await productRepository.updateStock(product._id, -item.quantity, session);

        normalizedItems.push({
          productId: product._id,
          quantity: Number(item.quantity),
          price: product.price,
        });
      }

      const discount = total > 1000000 ? total * 0.05 : 0;
      const finalTotal = total - discount;

      const created = await orderRepository.create(
        {
          storeId: store._id,
          items: normalizedItems,
          subtotal: total,
          discount,
          total: finalTotal,
        },
        session
      );

      await session.commitTransaction();
      session.endSession();
      return created;
    } catch (err) {
      await session.abortTransaction();
      session.endSession();
      throw err;
    }
  },
};

export default orderService;
