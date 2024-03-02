import { randomUUID } from 'crypto';
import { prisma } from '../..';

export async function setContainers(body: string, storageSystemId: string) {
	// Parse message
	const instructions = body
		.split('\n')
		.map((line) => {
			const [id, type, slots, slotsUsed] = line.split('/');
			return {
				id: id || '',
				type: type || '',
				slots: Number(slots) || 0,
				slotsUsed: Number(slotsUsed) || 0,
			};
		})
		.filter((ap) => ap.id !== '' && ap.type !== '' && ap.slots !== 0);

	console.log(
		await prisma.container.deleteMany({
			where: {
				storageSystemId,
				inGameId: {
					notIn: instructions.map((ap) => ap.id),
				},
			},
		}),
	);

	for (const ap of instructions) {
		await prisma.container.upsert({
			where: { storageSystemId_inGameId: { inGameId: ap.id, storageSystemId } },
			update: { slots: ap.slots, slotsUsed: ap.slotsUsed },
			create: {
				id: randomUUID(),
				storageSystemId,
				inGameId: ap.id,
				type: ap.type,
				slots: ap.slots,
				slotsUsed: ap.slotsUsed,
			},
		});
	}
}
