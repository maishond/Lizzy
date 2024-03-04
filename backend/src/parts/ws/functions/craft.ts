import chalk from 'chalk';
import { prisma } from '../..';
import { storageSystemId } from '../../../conf';
import { aps, sendMessageToAp } from '../ap';
import { generateMoveItemsBetweenContainers } from './utils/storage';
import type { MoveableEntry } from '../types';

type RecipeItem = string | undefined;
type Recipe = [RecipeItem, RecipeItem, RecipeItem][];

function blockRecipe(item: string): Recipe {
	return toRecipe([
		[item, item, item],
		[item, item, item],
		[item, item, item],
	]);
}

function twoByTwoRecipe(item: string): Recipe {
	return toRecipe([
		[item, item, undefined],
		[item, item, undefined],
		[undefined, undefined, undefined],
	]);
}

function toRecipe(recipe: Recipe) {
	return recipe;
}

export const compressables: Record<string, string> = {
	'minecraft:diamond_block': 'minecraft:diamond',
	'minecraft:iron_ingot': 'minecraft:iron_nugget',
	'minecraft:iron_block': 'minecraft:iron_ingot',
	'minecraft:gold_ingot': 'minecraft:gold_nugget',
	'minecraft:gold_block': 'minecraft:gold_ingot',
	'minecraft:emerald_block': 'minecraft:emerald',
	'minecraft:lapis_block': 'minecraft:lapis_lazuli',
	'minecraft:redstone_block': 'minecraft:redstone',
	'minecraft:copper_ingot': 'create:copper_nugget',
	'minecraft:copper_block': 'minecraft:copper_ingot',
	'minecraft:coal_block': 'minecraft:coal',
	'farmersdelight:onion_crate': 'farmersdelight:onion',
	'minecraft:bamboo_block': 'minecraft:bamboo',
	'farmersdelight:tomato_crate': 'farmersdelight:tomato',
	'farmersdelight:carrot_crate': 'minecraft:carrot',
	'farmersdelight:potato_crate': 'minecraft:potato',
	'farmersdelight:cabbage_crate': 'farmersdelight:cabbage',
	'farmersdelight:beetroot_crate': 'minecraft:beetroot',
	'farmersdelight:rice_bag': 'farmersdelight:rice',
	'farmersdelight:rice_bale': 'farmersdelight:rice_panicle',
	'farmersdelight:straw_bale': 'farmersdelight:straw',
	'supplementaries:flax_block': 'supplementaries:flax',
	'create:zinc_ingot': 'create:zinc_nugget',
	'create:zinc_block': 'create:zinc_ingot',
	'create:brass_block': 'create:brass_ingot',
	'betterend:charcoal_block': 'minecraft:charcoal',
	'betterend:thallasium_block': 'betterend:thallasium_ingot',
	'minecraft:hay_block': 'minecraft:wheat',
	'minecraft:bone_block': 'minecraft:bone_meal',
	'betterend:ender_block': 'minecraft:ender_pearl',
	'minecraft:glowstone': 'minecraft:glowstone_dust',
	'minecraft:slime_block': 'minecraft:slime_ball',
};

const knownRecipes: Record<string, Recipe> = {
	'betterend:ender_block': twoByTwoRecipe('minecraft:ender_pearl'),
	'minecraft:glowstone': twoByTwoRecipe('minecraft:glowstone_dust'),
};

for (const item in compressables) {
	const ingredient = compressables[item];
	if (ingredient) {
		if (!knownRecipes[item]) knownRecipes[item] = blockRecipe(ingredient);
	}
}

const canCraftCache: {
	[storageSystemId: string]: {
		apName: string;
		lastCheck: number;
	};
} = {};

export async function craft(itemName: string, perSlot = 1) {
	// Find turtle that can craft
	let crafterName;
	if (canCraftCache[storageSystemId]) {
		const cache = canCraftCache[storageSystemId];
		if (Date.now() - cache.lastCheck < 1e6 * 60 * 5) {
			// 5 minutes
			crafterName = cache.apName;
		}
	} else {
		for (const apName in aps[storageSystemId]) {
			if (!apName.includes('turtle')) continue;
			const canCraft = await sendMessageToAp(
				storageSystemId,
				apName,
				'CAN_CRAFT',
			);
			if (canCraft == 'true') {
				crafterName = apName;
				break;
			}
		}
	}

	if (!crafterName) {
		console.error('No turtle can craft');
		return;
	}

	await sendMessageToAp(storageSystemId, crafterName, 'DEPOSIT_SELF');

	canCraftCache[storageSystemId] = {
		apName: crafterName,
		lastCheck: Date.now(),
	};

	// Order turtle to craft
	const recipe = knownRecipes[itemName];
	if (!recipe) {
		console.error('Recipe not found for', itemName);
		return;
	}

	const moveables: MoveableEntry[] = [];

	for (let x = 0; x < 3; x++) {
		for (let y = 0; y < 3; y++) {
			let itemsFilled = 0;
			let attempts = 0;
			while (itemsFilled < perSlot && attempts < 10) {
				attempts++;
				const itemName = recipe[x]?.[y];
				if (!itemName) {
					attempts = Infinity;
					continue;
				}

				const itemsInDb = await prisma.item.findMany({
					where: {
						inGameId: itemName,
					},
					include: {
						container: true,
					},
				});

				const itemInDb = itemsInDb.find((t) => t.quantity > 0);

				if (!itemInDb) {
					console.error('Item not found in database', itemName);
					itemsFilled = perSlot;
					return;
				}

				const toTake = Math.min(itemInDb.quantity, perSlot - itemsFilled);

				await prisma.item.update({
					where: {
						id: itemInDb.id,
					},
					data: {
						quantity: itemInDb.quantity - toTake,
					},
				});

				itemsFilled += toTake;
				attempts++;

				moveables.push({
					fromContainer: itemInDb.container.inGameId,
					fromSlot: itemInDb.slot,
					toContainer: crafterName,
					toSlot: y * 4 + (x + 1),
					quantity: toTake,
				});
			}
		}
	}

	const message = generateMoveItemsBetweenContainers(moveables);
	await sendMessageToAp(storageSystemId, crafterName, message);
	const crafted = await sendMessageToAp(storageSystemId, crafterName, 'CRAFT');
	console.info(chalk.cyan(`${crafterName} crafted ${crafted}`));
	return crafted;
}
