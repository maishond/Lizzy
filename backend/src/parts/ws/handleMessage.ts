import type { Batch } from './types';

import { setInventory } from './messages/setInventory';
import { setAccessPoints } from './messages/setAccessPoints';
import { setContainers } from './messages/setContainers';

import chalk from 'chalk';

const commands: Record<
	string,
	(body: string, storageSystemId: string) => Promise<void>
> = {
	SET_INVENTORY: setInventory,
	SET_ACCESS_POINTS: setAccessPoints,
	SET_CONTAINERS: setContainers,
};

export async function handleMessage(batch: Batch) {
	const message = batch.map((message) => message.content).join('\n');
	const lines = message.split('\n');
	const instruction = lines[0] || '';
	const body = lines.slice(1).join('\n');

	const storageSystemId = batch[0]?.storageSystemId;
	if (!storageSystemId) {
		console.error('No storage system ID found');
		return;
	}

	console.info(chalk.bgGreen(batch[0]?.computer), instruction);

	const command = commands[instruction];
	if (!command) {
		console.error('Unknown command: ' + instruction);
		return;
	}

	try {
		await command(body, storageSystemId);
	} catch (err) {
		console.error('Error handling message', message, err);
	}
}
