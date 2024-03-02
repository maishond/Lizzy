import type { ParsedWebsocketMessage } from './types';

export function parseWebsocketMessage(message: string): ParsedWebsocketMessage {
	const lines = message.split('\n');

	// ! Turtle / computer identifier
	const idLine = lines[0];
	if (!idLine) throw new Error('No id line found');
	if (!idLine.startsWith('IDENTIFY'))
		throw new Error(`Invalid message: no identification: \n${message}`);

	const [, computer, storageSystemId, x, y, z] = idLine.split(' ');
	if (!computer || !storageSystemId || !x || !y || !z)
		throw new Error(
			`Invalid message: no computer, position, or storage system ID: \n${message}`,
		);

	// ! Batch
	const batchLine = lines[1];
	if (!batchLine) throw new Error('No batch line found');
	if (!batchLine.startsWith('BATCH'))
		throw new Error(`Invalid message: no batch: \n${message}`);

	const batch = batchLine.split(' ').slice(1).join(' ');

	// ! Text
	const text = lines.slice(2).join('\n');

	return {
		computer,
		batch,
		storageSystemId,
		position: { x: Number(x), y: Number(y), z: Number(z) },
		batchIdentifier: `${computer}/${batch}/${storageSystemId}`,
		content: text,
	};
}
