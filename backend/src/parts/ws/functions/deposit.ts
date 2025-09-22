import ws from 'ws';
import { prisma } from '../../prisma';
import { aps, sendMessageToAp } from '../ap';
import chalk from 'chalk';
import {
	generateMoveItemsBetweenContainers,
	getItemStoragePossibilities,
} from './utils/storage';
import { storageSystemId } from '../../../conf';
import type { MoveableEntry } from '../types';

export let isDepositing = false;

export function setIsDepositing(v: boolean) {
	isDepositing = v;
}

export async function deposit() {
	if (isDepositing) return;
	isDepositing = true;
	console.info(chalk.green('Depositing'));
	const start = Date.now();

	// Order all APs in network to deposit self first
	const depositSelves = [];
	for (const apName in aps[storageSystemId]) {
		if (!apName.includes('turtle')) continue;
		depositSelves.push(
			sendMessageToAp(storageSystemId, apName, 'DEPOSIT_SELF'),
		);
	}
	await Promise.all(depositSelves);

	// Find all barrels in storage system
	const barrelsWithItems = await prisma.container.findMany({
		where: {
			storageSystemId,
			type: 'minecraft:barrel',
		},
		include: {
			Item: true,
		},
	});

	// Find a websocket from the storage system
	const systemAps = aps[storageSystemId] || {};
	const apName = Object.keys(systemAps).find(
		(key) => systemAps[key]?.readyState === ws.OPEN && key.includes('turtle'),
	);

	if (!apName) {
		console.error(chalk.red('No connected clients, unable to deposit'));
		isDepositing = false;
		return;
	}

	const moveables: MoveableEntry[] = [];

	await Promise.all(
		barrelsWithItems.map(async (barrel) => {
			for (const item of barrel.Item) {
				if (!apName) continue;

				console.log('Finding storage possibilities for', item.inGameId);
				const storagePossibilities = await getItemStoragePossibilities(
					item.inGameId,
				);

				// ! This returns a list of contains the item can (maybe?) be moved to
				// ! It can't now for certain, since the DB might not 100% be up-to-date
				// ! In the future, it might not be a bad idea to return the containers items have been moved to
				// ! ^ in order to attempt reflecting that in the DB.
				// But not now. I don't feel like it.

				moveables.push(
					...storagePossibilities.map((possibility) => ({
						fromContainer: barrel.inGameId,
						fromSlot: item.slot,
						toContainer: possibility.container,
						toSlot: possibility.slot,
						quantity: item.quantity,
					})),
				);
			}
		}),
	);

	console.info(chalk.green('Depositing'), `${moveables.length} items`);

	const msg = await sendMessageToAp(
		storageSystemId,
		apName,
		generateMoveItemsBetweenContainers(moveables),
	);
	console.info(msg);

	const end = Date.now();

	let [confirmation, count] = msg.split(' ') as any[];
	if (confirmation === 'TRANSFERRED') count = Number(count);

	console.info(chalk.green('Deposit'), `${count} items in ${end - start}ms`);
	isDepositing = false;
}
