import type WebSocket from 'ws';

export interface ParsedWebsocketMessage {
	computer: string;
	batchIdentifier: string;
	batch: string;
	content: string;
	storageSystemId: string;
	position: {
		x: number;
		y: number;
		z: number;
	};
}

export interface ApMessage {
	acknowledged: boolean;
	message: string;
	id: string;
	receiver: string;
	acknowledge: (msg: string) => void;
	retries: number;
	storageSystemId: string;
}

export type Batch = ParsedWebsocketMessage[];

export interface MoveableEntry {
	fromContainer: string;
	fromSlot: number;
	toContainer: string;
	toSlot?: number;
	quantity: number;
}
