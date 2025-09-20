import { Router } from 'express';
import { prisma } from '../parts/index';
import { getAps } from '../utils';
import type { MoveableEntry } from '../parts/ws/types';
import { generateMoveItemsBetweenContainers } from '../parts/ws/functions/utils/storage';
import { sendMessageToAp } from '../parts/ws/ap';

const router = Router();

router.get('/:id', async (req, res) => {
	const id = req.params.id;

	const system = await prisma.storageSystem.findUnique({
		where: { id },
	});

	// Get items
	const query = await prisma.item.findMany({
		where: { container: { storageSystemId: id } },
	});

	const items: Record<string, number> = {};
	for (let item of query) {
		if (!items[item.inGameId]) items[item.inGameId] = 0;
		items[item.inGameId] += item.quantity;
	}

	// Get access points
	const aps = await getAps(id);

	// Return all
	const apsWithoutWs = aps.map((t) => {
		const { ws: undefined, ...rest } = t;
		return rest;
	});
	res.send({ ...system, items, accessPoints: apsWithoutWs });
});

router.get('/:id/diffs', async (req, res) => {
	const id = req.params.id;

	const system = await prisma.storageSystem.findUnique({
		where: { id },
	});

	// Get items
	const diffsQuery = await prisma.itemDiff.findMany({
		where: { storageSystemId: id },
	});

	const diffs = diffsQuery.map((entry) => {
		return {
			at: entry.created_at,
			item: entry.itemId,
			diff: entry.diff
		}
	})

	res.send({ ...system, diffs });
});

router.get('/:id/drop-item/:item/:count/:ap', async (req, res) => {
	let storageSystemId = req.params.id;
	let itemId = req.params.item;
	let requiredQuantity = Number(req.params.count);
	let apInGameId = req.params.ap;
	console.log(itemId, requiredQuantity, apInGameId);

	// ComputerCraft doesn't like when you do non-200 responses
	if (!itemId || !requiredQuantity || !apInGameId) {
		return res.send('Invalid request');
	}

	// Get access point
	const aps = await getAps(storageSystemId);
	const ap = aps.find((t) => t.inGameId === apInGameId);
	if (!ap) return res.send('Invalid access point');
	if (!ap.online) return res.send('Access point is offline');

	// Get items
	const items = await prisma.item.findMany({
		where: { inGameId: itemId, container: { storageSystemId } },
		include: { container: true },
	});

	// Find item with enough quantity
	let foundCount = 0;
	const moveables: MoveableEntry[] = [];
	for (let item of items) {
		if (item.quantity > 0) {
			let toDrop = Math.min(item.quantity, requiredQuantity - foundCount);
			foundCount += toDrop;
			await prisma.item.update({
				where: { id: item.id },
				data: { quantity: item.quantity - toDrop },
			});
			moveables.push({
				fromContainer: item.container.inGameId,
				fromSlot: item.slot,
				toContainer: ap.inGameId,
				quantity: toDrop,
			});
			if (foundCount === requiredQuantity) break;
		}
	}

	// Send moveables
	const message = generateMoveItemsBetweenContainers(moveables, true);
	const apRes = await sendMessageToAp(storageSystemId, ap.inGameId, message);

	res.send(apRes);
});

export { router };
