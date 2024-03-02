import type { Item } from '$lib/types';

interface Result {
	transcript: string;
}

const triggerWords = [
	'zee',
	'busy',
	'lancy',
	'lindsay',
	'lucy',
	'lazy',
	'lizzy',
	'lizzie',
	'placing',
	'turtle',
	'turn on'
];
// "turtle" apparently sounds like "turn on" sometimes

function fixNumberWords(string: string) {
	const map = {
		one: '1',
		two: '2',
		three: '3',
		four: '4',
		five: '5',
		six: '6',
		seven: '7',
		eight: '8',
		nine: '9',
		ten: '10',
		a: '1',
		an: '1',
		free: '3'
	} as Record<string, string>;

	let str = string.toLowerCase().trim();

	for (const word in map) {
		str = str.replace(new RegExp(`(^|\\W)${word}(^|\\W)`, 'g'), ` ${map[word]} `);
	}

	return str;
}

function cleanItemName(str: string) {
	const t = str.split(':');
	return t[t.length - 1]
		.replace(/_/g, ' ')
		.replace(/[^a-zA-Z0-9 ]/g, '')
		.trim();
}

export function getItemToGetFromVoice(results: Result[], allItems: Item[]) {
	let resFound: Item | null = null;

	for (let i = 0; i < results.length; i++) {
		console.log(`%c Checking possibility: ${results[i].transcript}`, 'color: yellow');
		const transcript = results[i].transcript.toLowerCase();
		const triggerWord = triggerWords.find((word) => transcript.includes(word));

		if (!triggerWord) continue;

		const query = transcript.split(triggerWord)[1].trim();
		console.log(`%c Found query: ${query}`, 'color: lime');

		const numberifiedQuery = fixNumberWords(query);
		console.log(`%c Numberified query: ${numberifiedQuery}`, 'color: lime');
		const count = numberifiedQuery.match(/\d+/g)?.map(Number)[0] || 64;
		const itemQueries = numberifiedQuery.split(/\d/).slice(1);
		if (itemQueries.length === 0) itemQueries.push(numberifiedQuery);

		for (const q of itemQueries) {
			const desiredItem = q.trim();

			if (desiredItem === '') continue;

			const possibleNames = generateNamesFromWord(desiredItem).map(cleanItemName);
			const item = allItems.find((item) => possibleNames.includes(cleanItemName(item.id)));
			if (item) {
				resFound = {
					id: item.id,
					count
				};
			} else {
				console.log(`%c Could not find item: ${desiredItem}`, 'color: red');
			}
		}
	}

	return resFound;
}

function generateNamesFromWord(word: string) {
	const possibleNames = [word];

	possibleNames.push(word + 'es');
	possibleNames.push(word.replace('ies', 'y'));
	if (!word.endsWith('s')) possibleNames.push(word + 's');
	if (word.endsWith('s')) possibleNames.push(word.slice(0, -1));
	if (word.endsWith('es')) possibleNames.push(word.slice(0, -2));

	// Similar-sounding words
	possibleNames.push(word.replace(/[^g]low/, 'glow'));
	possibleNames.push(word.replace(/weeks?/, 'wheat'));
	possibleNames.push(word.replace(/under/, 'ender'));
	possibleNames.push(word.replace(/and/, 'end'));
	possibleNames.push(word.replace(/carat/, 'carrot'));

	// "Drop some cobblestone" -> "some cobblestone" -> "cobblestone"
	const words = word.split(' ');
	for (let i = 1; i <= words.length - 1; i++) {
		possibleNames.push(words.slice(i).join(' '));
	}

	return [...new Set(possibleNames)];
}
