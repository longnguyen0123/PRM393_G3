import { ProductModel } from '../models/productModel.js';

const productRepository = {
  findAll: async () => ProductModel.find().lean().exec(),

  findById: async (id, session = null) =>
    ProductModel.findById(id).session(session).lean().exec(),

  create: async ({ name, price, stock, storeId }, session = null) => {
    const doc = new ProductModel({ name, price, stock, storeId });
    const saved = await doc.save({ session });
    return saved.toObject();
  },

  updateStock: async (id, delta, session = null) => {
    const updated = await ProductModel.findByIdAndUpdate(
      id,
      { $inc: { stock: delta } },
      { new: true }
    )
      .session(session)
      .lean()
      .exec();
    return updated;
  },
};

export default productRepository;
