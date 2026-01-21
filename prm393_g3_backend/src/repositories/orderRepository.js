import { OrderModel } from '../models/orderModel.js';

const orderRepository = {
  findAll: async () => OrderModel.find().lean().exec(),

  create: async ({ storeId, items, subtotal, discount, total }, session = null) => {
    const doc = new OrderModel({ storeId, items, subtotal, discount, total });
    const saved = await doc.save({ session });
    return saved.toObject();
  },
};

export default orderRepository;
