import { config } from 'dotenv';
config();

import './parts/prisma';
import './parts/ws';
import './parts/express';

// Temporary stuff right here
import { prisma } from './parts/prisma';
import { storageSystemId } from './conf';

await prisma.storageSystem.upsert({
	where: { id: storageSystemId },
	create: { id: storageSystemId, name: 'Jip Lizzy' },
	update: {},
});
