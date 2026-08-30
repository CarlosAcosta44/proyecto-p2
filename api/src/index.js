import express from 'express';
import cors from 'cors';
import rondasRouter from './rutas/rondas.js';
import puntosRouter from './rutas/puntos.js';
import { errorMiddleware } from './middlewares/error.js';
import { authMiddleware } from './middlewares/auth.js';

const app = express();

app.use(cors());
app.use(express.json());

// Rutas protegidas (en este proyecto usamos un authMiddleware mock)
app.use('/api/rondas', authMiddleware, rondasRouter);
app.use('/api/puntos', authMiddleware, puntosRouter);

app.use(errorMiddleware);

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`API escuchando en el puerto ${PORT}`);
});
