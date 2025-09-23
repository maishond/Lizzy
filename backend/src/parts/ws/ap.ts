import { randomUUID } from 'crypto';
import type { WebSocket } from 'ws';
import type { ApMessage } from './types';
import chalk from 'chalk';

export const aps: {
	[storageSystemId: string]: {
		[inGameId: string]: WebSocket | null;
	};
} = {};

type QueueEntry = {
	queue: ApMessage[];
	interval?: NodeJS.Timeout;
};

export const apQueues: {
	[storageSystemId: string]: {
		[inGameId: string]: QueueEntry;
	};
} = {};

export function setAccessPoint(
	storageSystemId: string,
	inGameId: string,
	ws: WebSocket | null,
) {
	if (!aps[storageSystemId]) aps[storageSystemId] = {};
	aps[storageSystemId][inGameId] = ws;
}

function processQueue(storageSystemId: string, inGameId: string) {
	const queueEntry = apQueues[storageSystemId]?.[inGameId];
	if (!queueEntry) return;

	const ws = aps[storageSystemId]?.[inGameId];
	if (!ws) {
		console.error('No websocket found for', storageSystemId, inGameId);
		return;
	}

	const sendNext = () => {
		const message = queueEntry.queue[0];
		if (!message) {
			clearInterval(queueEntry.interval);
			queueEntry.interval = undefined;
			return;
		}
		if (message.acknowledged) {
			queueEntry.queue.shift();
			sendNext();
			return;
		}
		if (message.retries > 10) {
			console.error(
				chalk.red('Unable to send message to AP: ' + message.message),
			);
			message.acknowledge('Failed to reach AP');
			queueEntry.queue.shift();
			sendNext();
			return;
		}
		if (message.retries > 0) {
			console.warn(
				chalk.bgYellow('Retrying'),
				`Retrying message ${chalk.bgYellow(
					message.message.split('\n')[1],
				)} to ${message.receiver}`,
				chalk.red(`(${message.retries})`),
			);
		}
		ws.send(message.message);
		message.retries++;
	};

	if (!queueEntry.interval) {
		sendNext();
		queueEntry.interval = setInterval(sendNext, 1500);
	}
}

export function sendMessageToAp(
	storageSystemId: string,
	inGameId: string,
	message: string,
) {
	return new Promise<string>((resolve, reject) => {
		const id = randomUUID();
		const ws = aps[storageSystemId]?.[inGameId];
		if (!ws) {
			console.error('No websocket found for', storageSystemId, inGameId);
			reject();
			return;
		}

		if (!apQueues[storageSystemId]) apQueues[storageSystemId] = {};
		if (!apQueues[storageSystemId][inGameId]) {
			apQueues[storageSystemId][inGameId] = { queue: [] };
		}
		const queueEntry = apQueues[storageSystemId][inGameId];

		const msg = `${id}\n${message}`;
		const apMsg: ApMessage = {
			acknowledged: false,
			message: msg,
			id,
			receiver: inGameId,
			retries: 0,
			storageSystemId,
			acknowledge: (msg: string) => {
				const idx = queueEntry.queue.findIndex((m) => m.id === id);
				if (idx !== -1) {
					queueEntry.queue[idx].acknowledged = true;
					queueEntry.queue.splice(idx, 1);
				}
				if (queueEntry.queue.length === 0 && queueEntry.interval) {
					clearInterval(queueEntry.interval);
					queueEntry.interval = undefined;
				}
				resolve(msg);
			},
		};

		queueEntry.queue.push(apMsg);
		processQueue(storageSystemId, inGameId);
	});
}
