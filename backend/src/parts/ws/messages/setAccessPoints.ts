import { randomUUID } from 'crypto';
import { prisma } from '../..';

export async function setAccessPoints(body: string, storageSystemId: string) {
	// Parse message
	const instructions = body
		.split('\n')
		.map((line) => {
			const [id, name] = line.split('/');
			return {
				id: id || '',
				name: name || '',
			};
		})
		.filter((ap) => ap.id !== '');

	const apIdMap: Record<string, string> = {};

	await prisma.accessPoint.deleteMany({
		where: {
			storageSystemId,
			NOT: {
				inGameId: {
					in: instructions.map((i) => i.id),
				},
			},
		},
	});

	const upserts = [];
	for (const ap of instructions) {
		const id = randomUUID();
		apIdMap[ap.id] = id;
		upserts.push(
			prisma.accessPoint.upsert({
				where: {
					storageSystemId_inGameId: {
						storageSystemId,
						inGameId: ap.id,
					},
				},
				create: {
					id,
					storageSystemId,
					inGameId: ap.id,
					name: ap.name,
				},
				update: {
					name: ap.name,
				},
			}),
		);
	}
	await Promise.all(upserts);
}
