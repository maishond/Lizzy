import type { Batch } from './ws/types';

import { createServer } from 'http';
import { WebSocketServer } from 'ws';
import { parseWebsocketMessage } from './ws/utils';
import { handleMessage } from './ws/handleMessage';
import { pendingMessages, setAccessPoint } from './ws/ap';
import { prisma } from '.';
import { randomUUID } from 'crypto';
import chalk from 'chalk';

let server = createServer();

let wss = new WebSocketServer({
	server,
	perMessageDeflate: false,
	path: '/ws',
});

const batches: Record<string, Batch> = {};

wss.on('connection', (ws) => {
	ws.on('error', console.error);

	ws.on('message', async (data) => {
		// Parse message
		const message = data.toString();

		try {
			const parsed = parseWebsocketMessage(message);

			// Add close event if not already added
			if (!ws.listeners('close').length) {
				ws.on('close', () => {
					// Remove access point
					console.info(chalk.red(`Access point ${parsed.computer} is offline`));
					setAccessPoint(parsed.storageSystemId, parsed.computer, null);
				});
			}

			// Batch logic
			if (parsed.content === 'END_BATCH') {
				const batch = batches[parsed.batchIdentifier];
				ws.send('Acknowledged END_BATCH');

				if (!batch)
					throw new Error('END_BATCH on nonexistent batch: ' + parsed.batch);

				// Store websocket on startup
				if (
					batch[0]?.content === 'STARTUP' ||
					batch[0]?.content === 'LISTENING'
				) {
					if (batch[0]?.content === 'STARTUP') {
						console.info(
							chalk.green(`Access point ${parsed.computer} is online`),
						);
					}
					setAccessPoint(parsed.storageSystemId, parsed.computer, ws);

					await prisma.accessPoint.upsert({
						where: {
							storageSystemId_inGameId: {
								storageSystemId: parsed.storageSystemId,
								inGameId: parsed.computer,
							},
						},
						update: {
							x: Number(parsed.position.x),
							y: Number(parsed.position.y),
							z: Number(parsed.position.z),
						},
						create: {
							storageSystemId: parsed.storageSystemId,
							inGameId: parsed.computer,
							id: randomUUID(),
							name: 'unknown',
							x: Number(parsed.position.x),
							y: Number(parsed.position.y),
							z: Number(parsed.position.z),
						},
					});
				} else if (batch[0]?.content.startsWith('ACK_MESSAGE')) {
					const content = batch[0].content;
					const lines = content.split('\n').map((s) => s.trim());

					const id = lines[0]?.split(' ')[1]?.trim();
					const message = lines.slice(1).join('\n');
					const pendingMsg = pendingMessages.find((m) => m.id === id);
					console.warn(
						chalk.bgGreenBright('Message acknowleged: '),
						message,
						'\n',
						(pendingMsg?.message || '').split('\n').slice(0, 3),
					);

					pendingMsg?.acknowledge(message);
				} else {
					// Handle message
					handleMessage(batch);
				}

				// Clean up
				delete batches[parsed.batchIdentifier];
				return;
			}

			if (!batches[parsed.batchIdentifier])
				batches[parsed.batchIdentifier] = [];

			batches[parsed.batchIdentifier]?.push(parsed);
		} catch (err) {
			console.error(err);
		}
	});
});

server.listen(8081, () => {
	console.info('listening on localhost:8081');
});

export { wss, server };
