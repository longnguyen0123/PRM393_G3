import { StoreModel } from '../models/storeModel.js';

const storeRepository = {
  findAll: async () => StoreModel.find().lean().exec(),

  findById: async (id, session = null) =>
    StoreModel.findById(id).session(session).lean().exec(),
};

export default storeRepository;
