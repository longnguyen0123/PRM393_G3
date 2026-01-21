## Retail Chain Management System (demo)

Skeleton project for PRM393 demo with layered Node.js backend and Flutter (Clean Architecture + BLoC) frontend.

### Backend (Node.js + Express)
- Layered Controller → Service → Repository using in-memory data.
- API base: `http://localhost:3000/api`
- Routes:
  - `GET /products` list products
  - `GET /products/:id`
  - `POST /products` `{ name, price, stock, storeId }`
  - `PATCH /products/:id/stock` `{ delta }`
  - `GET /stores`, `GET /stores/:id`
  - `GET /orders`, `POST /orders` `{ storeId, items: [{ productId, quantity }] }`
- Business example: creating an order checks stock, deducts inventory, applies 5% discount if subtotal > 1,000,000.

Run backend:
```bash
cd prm393_g3_backend
npm install
npm run dev
# server on http://localhost:3000
```

MongoDB config:
- Set `MONGO_URI` (and optional `MONGO_DB_NAME`) then backend will connect on start.
- File: `prm393_g3_backend/src/config/db.js`
- Env template: `prm393_g3_backend/env.example`
Example (PowerShell):
```bash
$env:MONGO_URI="mongodb://localhost:27017"
$env:MONGO_DB_NAME="retail_chain"
npm run dev
```

Seed data (for mongoimport):
- Folder `prm393_g3_backend/src/data/`
  - `stores.sample.json`
  - `products.sample.json`
  - `orders.sample.json`
```bash
mongoimport --uri "mongodb://localhost:27017/retail_chain" --collection stores --file src/data/stores.sample.json --jsonArray
mongoimport --uri "mongodb://localhost:27017/retail_chain" --collection products --file src/data/products.sample.json --jsonArray
mongoimport --uri "mongodb://localhost:27017/retail_chain" --collection orders --file src/data/orders.sample.json --jsonArray
```

### Frontend (Flutter)
- Clean Architecture: `presentation` (BLoC), `domain` (entities, repositories, use cases), `data` (data sources, models).
- Uses `dio` for HTTP, `flutter_bloc` for state, `get_it` for DI.
- Screen: `ProductListPage` fetches products from `/products` and renders cards.

Run frontend:
```bash
cd prm393_g3_frontend
flutter pub get
flutter run
```

> If running on Android emulator, replace backend base URL in `lib/core/di/service_locator.dart` with `http://10.0.2.2:3000/api` (or the machine IP for real devices).

### Suggested flow
1) Start backend (`npm run dev`).
2) Start Flutter app; initial load triggers product fetch.
3) Hit refresh in the UI to re-fetch; test order creation via Postman/Thunder Client if needed.
