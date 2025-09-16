import ws from 'ws';
import { prisma } from './parts';
import { aps } from './parts/ws/ap';

export interface AccessPoint {
	id: string;
	storageSystemId: string;
	name: string;
	online: boolean;
	inGameId: string;
	ws?: ws;
	position: {
		x: number;
		y: number;
		z: number;
	};
}

export async function getAps(storageSystemId: string) {
	const apsInDb = await prisma.accessPoint.findMany({
		where: { storageSystemId },
	});

	const accessPoints: AccessPoint[] = [];
	for (const ap of apsInDb) {
		accessPoints.push({
			id: ap.id,
			storageSystemId: ap.storageSystemId,
			name: ap.name,
			inGameId: ap.inGameId,
			online:
				aps[storageSystemId]?.[ap.inGameId]?.readyState === ws.OPEN,
			ws: aps[storageSystemId]?.[ap.inGameId],
			position: {
				x: ap.x,
				y: ap.y,
				z: ap.z,
			},
		});
	}

	return accessPoints;
}
