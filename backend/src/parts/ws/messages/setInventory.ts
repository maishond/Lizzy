import chalk from 'chalk';
import { prisma } from '../..';
import { compressables, craft } from '../functions/craft';
import { deposit } from '../functions/deposit';

const itemCompressionMap: Record<string, string> = Object.fromEntries(
	Object.entries(compressables).map(([k, v]) => [v, k]),
);

export async function setInventory(body: string, storageSystemId: string) {
	// Parse message
	const instructions = body
		.split('\n')
		.map((line) => {
			const [inGameContainerId, slot, count, itemName] = line.split('/');
			return {
				inGameContainerId: inGameContainerId || 'unknown',
				slot: Number(slot) || 0,
				count: Number(count) || 0,
				itemName: itemName || '',
			};
		})
		.filter(
			(t) =>
				t.inGameContainerId !== 'unknown' &&
				t.slot !== 0 &&
				t.count !== 0 &&
				t.itemName !== '',
		);

	// Count for each item
	const newItemCount: Record<string, number> = {};
	for (const instruction of instructions) {
		if (!newItemCount[instruction.itemName])
			newItemCount[instruction.itemName] = 0;
		newItemCount[instruction.itemName] += instruction.count;
	}

	// ! Find differences between DB and new items
	const currentItems = await prisma.item.findMany({
		where: {
			container: {
				storageSystemId,
			},
		},
	});
	const currentItemCount: Record<string, number> = {};
	for (const item of currentItems) {
		if (!currentItemCount[item.inGameId]) currentItemCount[item.inGameId] = 0;
		currentItemCount[item.inGameId] += item.quantity;
	}

	// Find differences in item count, store in db
	const diffs: { itemId: string; diff: number }[] = [];

	const keys = new Set([
		...Object.keys(newItemCount),
		...Object.keys(currentItemCount),
	]);
	await Promise.all(Array.from(keys).map(async (itemName) => {

		const allDiffEntriesForItem = await prisma.itemDiff.findMany({
			where: {
				storageSystemId,
				itemId: itemName
			}
		})

		let diffTotal = 0
		for(const diffEntry of allDiffEntriesForItem) {
			diffTotal += diffEntry.diff
		}

		const diff = (newItemCount[itemName] || 0) - diffTotal

		if (diff !== 0) {
			diffs.push({
				itemId: itemName,
				diff,
			});
		}
	}))

	await prisma.itemDiff.createMany({
		data: diffs.map((diff) => ({
			...diff,
			storageSystemId,
		})),
	});

	// ! Container logic
	const uniqueContainers = Array.from(
		new Set(instructions.map((instruction) => instruction.inGameContainerId)),
	);

	// Find container IDs from DB (inGameId -> DB ID)
	const containersInSystem = await prisma.container.findMany({
		where: {
			storageSystemId,
			inGameId: {
				in: uniqueContainers,
			},
		},
	});
	const containerIdMap: Record<string, string> = {};
	for (const container of containersInSystem) {
		containerIdMap[container.inGameId] = container.id;
	}

	// ! Create all items

	// Add all items
	const create: {
		containerId: string;
		slot: number;
		quantity: number;
		inGameId: string;
	}[] = [];
	instructions.forEach((instruction) => {
		const containerDbId = containerIdMap[instruction.inGameContainerId];
		if (!containerDbId)
			throw new Error(
				`Container ID not found (${instruction.inGameContainerId})`,
			);

		create.push({
			containerId: containerDbId,
			slot: instruction.slot,
			quantity: instruction.count,
			inGameId: instruction.itemName,
		});
	});

	console.time('Transaction');
	await prisma.$transaction([
		prisma.item.deleteMany({
			where: {
				container: {
					storageSystemId,
				},
			},
		}),
		prisma.item.createMany({
			data: create,
		}),
	]);
	console.timeEnd('Transaction');

	console.info(chalk.cyan('Inventory updated, compressing'));

	// Compress items like diamonds, iron, etc.
	let canCraft = true;
	for (const compressableItemName in itemCompressionMap) {
		const compressed = itemCompressionMap[compressableItemName];
		if (!compressed || !canCraft) continue;
		let quantity = await getItemQuantity(compressableItemName);
		while (quantity >= 9 && canCraft) {
			console.info(chalk.cyan(`Compressing ${compressed}`));
			const maxQuantity =
				compressableItemName === 'minecraft:ender_pearl' ? 16 : 64;

			const res = await craft(
				compressed,
				Math.min(Math.floor(quantity / 9), maxQuantity),
			);

			if (!res) {
				canCraft = false;
				break;
			}
			quantity = await getItemQuantity(compressableItemName);
		}
	}

	console.info(chalk.cyan('Inventory updated, depositing'));

	// Deposit barrels
	await deposit();
}

async function getItemQuantity(itemName: string) {
	const itemsInDb = await prisma.item.findMany({
		where: {
			inGameId: itemName,
		},
	});

	return itemsInDb.reduce((acc, item) => acc + item.quantity, 0);
}
