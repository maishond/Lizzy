import { storageSystemId } from '../../../../conf';
import { prisma } from '../../../prisma';
import type { MoveableEntry } from '../../types';

export function generateMoveItemsBetweenContainers(
	entries: MoveableEntry[],
	dropWhenMove = false,
) {
	const lines: string[] = [];

	for (const entry of entries) {
		lines.push(
			[
				entry.fromContainer,
				entry.fromSlot,
				entry.toContainer,
				entry.toSlot,
				entry.quantity,
			].join('/'),
		);
	}

	const msg = `MOVE_ITEMS${dropWhenMove ? '_DROP' : ''}\n${lines.join('\n')}`;
	return msg;
}

export async function getItemStoragePossibilities(itemName: string) {
	const containers = await prisma.container.findMany({
		where: {
			storageSystemId,
			type: 'minecraft:chest',
		},
		include: {
			Item: true,
		},
	});

	containers.sort(() => Math.random() - 0.5);

	const possibilities: { slot?: number; container: string }[] = [];
	const maxPossibilities = 10;
	let possibilitiesFound = 0;

	for (const container of containers) {
		if (possibilitiesFound > maxPossibilities) break;
		const nonStackedItem = container.Item.find(
			(i) => i.inGameId === itemName && i.quantity < 64,
		);
		if (nonStackedItem) {
			possibilities.push({
				slot: nonStackedItem.slot,
				container: container.inGameId,
			});
			possibilitiesFound++;
		}
	}

	for (const container of containers) {
		if (possibilitiesFound > maxPossibilities) break;
		if (container.slotsUsed < container.slots) {
			possibilities.push({
				slot: undefined,
				container: container.inGameId,
			});
			possibilitiesFound++;
		}
	}

	return possibilities;
}
