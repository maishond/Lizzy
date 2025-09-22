import { randomUUID } from 'crypto';
import type { WebSocket } from 'ws';
import type { ApMessage } from './types';
import chalk from 'chalk';

export const aps: {
	[storageSystemId: string]: {
		[inGameId: string]: WebSocket | null;
	};
} = {};

export function setAccessPoint(
	storageSystemId: string,
	inGameId: string,
	ws: WebSocket | null,
) {
	if (!aps[storageSystemId]) aps[storageSystemId] = {};
	if (aps[storageSystemId]) aps[storageSystemId]![inGameId] = ws;
}

export let pendingMessages: ApMessage[] = [];
let globalInterval: NodeJS.Timeout;

function checkInterval() {
	if (globalInterval) return;

	pendingMessages = pendingMessages.filter((m) => !m.acknowledged);

	const message = pendingMessages[0];
	if (!message) return;
	const ws = aps[message.storageSystemId]?.[message.receiver];
	if (!ws) {
		console.error(
			'No websocket found for',
			message.storageSystemId,
			message.receiver,
		);
		return;
	}
	ws.send(message.message);

	globalInterval = setInterval(() => {
		const message = pendingMessages[0];
		if (!message) {
			clearInterval(globalInterval);
			globalInterval = undefined!;
		}
		if (!message) return;
		message.retries++;
		if (message.retries > 10) {
			console.error(
				chalk.red('Unable to send message to AP: ' + message.message),
			);
			message.acknowledge('Failed to reach AP');
		} else {
			console.warn(
				chalk.bgYellow('Retrying'),
				`Retrying message ${chalk.bgYellow(
					message.message.split('\n')[1],
				)} to ${message.receiver}`,
				chalk.red(`(${message.retries})`),
			);
			ws.send(message.message);
		}
	}, 1500);
}

export function sendMessageToAp(
	storageSystemId: string,
	inGameId: string,
	message: string,
) {
	return new Promise<string>((resolve, reject) => {
		const id = randomUUID();
		const ws = aps[storageSystemId]?.[inGameId];
		if (ws) {
			const msg = `${id}\n${message}`;

			pendingMessages.push({
				acknowledged: false,
				message: msg,
				id,
				receiver: inGameId,
				retries: 0,
				storageSystemId,
				acknowledge: (msg: string) => {
					const inArray = pendingMessages.find((m) => m.id === id);
					inArray!.acknowledged = true;

					pendingMessages = pendingMessages.filter((m) => m.id !== id);

					clearInterval(globalInterval);
					globalInterval = undefined!;

					checkInterval();
					resolve(msg);
				},
			});

			checkInterval();
		} else {
			console.error('No websocket found for', storageSystemId, inGameId);
			reject();
		}
	});
}
