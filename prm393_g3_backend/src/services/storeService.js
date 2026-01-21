import storeRepository from '../repositories/storeRepository.js';

const storeService = {
  getAll: () => storeRepository.findAll(),
  getById: (id) => storeRepository.findById(id),
};

export default storeService;
