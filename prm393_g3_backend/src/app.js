import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import router from './routes/index.js';

const app = express();

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

app.get('/', (_req, res) => {
  res.json({
    message: 'Retail Chain Management API - healthy',
  });
});

app.use('/api', router);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(err.status || 500).json({ message: err.message || 'Internal server error' });
});

export default app;
