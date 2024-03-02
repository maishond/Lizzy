import { server } from './ws';
import { router as systemRouter } from '../routes/system';
import express from 'express';
import cors from 'cors';

const app = express();

app.use(cors());
app.use(express.static('../computercraft-client'));

app.use('/system', systemRouter);

server.on('request', app);
