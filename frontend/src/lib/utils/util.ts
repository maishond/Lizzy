import { API_BASE_URL } from '$lib/config';
import type { Item } from '$lib/types';

export function toName(id: string) {
	return (
		id
			.split(':')
			.pop()
			?.replace(/_/g, ' ')
			.split(' ')
			.map((s) => s.slice(0, 1).toUpperCase() + s.slice(1))
			.join(' ') || id
	);
}

export function cleanString(str: string) {
	return str
		.toLowerCase()
		.replace(/[^a-zA-Z0-9@ ]/g, '')
		.trim();
}

export function filterItems(items: Item[], searchValue: string) {
	const words = searchValue.trim().split(' ').map(cleanString);

	const namespaces = words.filter((word) => word.startsWith('@'));
	const query = words.filter((word) => !namespaces.includes(word)).join(' ');

	const data = items.filter((item) => {
		const [namespace, name] = item.id.split(':');

		let isInNamespace = namespaces.length === 0;
		for (const ns of namespaces) {
			if (namespace.includes(ns.slice(1))) {
				isInNamespace = true;
				break;
			}
		}

		return isInNamespace && cleanString(name).includes(query);
	});

	return data;
}

export function dropItem(systemId: string, item: Item) {
	// http://localhost:8080/system/dc917eba-9107-4835-8427-bcc60ff1a495/drop-item/minecraft:stone/1
	// http://localhost:8080/system/dc917eba-9107-4835-8427-bcc60ff1a495/drop-item/minecraft:cobblestone/60
	fetch(API_BASE_URL + `/system/${systemId}/drop-item/${item.id}/${item.count}`)
		.then((d) => d.json())
		.then((res) => {
			console.log(res);
		})
		.catch((err) => {
			console.error(err);
		});
}
