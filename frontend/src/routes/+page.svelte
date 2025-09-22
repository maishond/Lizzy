<script lang="ts">
	import chartjs from 'chart.js';
	import type { Item as ItemType } from '$lib/types';

	import Card from '$lib/components/Card.svelte';
	import Grid from '$lib/components/Grid.svelte';
	import Item from '$lib/components/Item.svelte';
	import Slot from '$lib/components/Slot.svelte';
	import Title from '$lib/components/Title.svelte';
	import Input from '$lib/components/Input.svelte';
	import Paragraph from '$lib/components/Paragraph.svelte';
	import ParagraphWithItem from '$lib/components/ParagraphWithItem.svelte';
	import Voice from '$lib/components/parts/Voice.svelte';

	import { filterItems } from '../lib/utils/util';
	import { onMount } from 'svelte';
	import { API_BASE_URL, TMP_SYSTEM_ID } from '$lib/config';

	let itemsRes: { [key: string]: number } = {};
	let diffsRes: { at: string; item: string; diff: number }[] = [];
	let storageName = 'Loading...';
	let chartCanvas: HTMLCanvasElement | null;

	let error = '';
	let enabledDiffs = ['minecraft:gold_block', 'minecraft:iron_block'];

	function doFetch() {
		fetch(API_BASE_URL + '/system/' + TMP_SYSTEM_ID)
			.then((d) => d.json())
			.then((res) => {
				storageName = res.name;
				itemsRes = res.items;
			})
			.catch((err) => {
				console.error(err);
				error = 'Failed to load inventory';
			});

		fetch(API_BASE_URL + '/system/' + TMP_SYSTEM_ID + '/diffs')
			.then((d) => d.json())
			.then((res) => {
				storageName = res.name;
				diffsRes = res.diffs;
				doChart();
			})
			.catch((err) => {
				console.error(err);
				error = 'Failed to load diffs';
			});
	}

	function getTexture(item: { id: string }) {
		const [namespace, itemName] = item.id.split(':');
		return `/items/${namespace}/items/${itemName}.png`;
	}

	function doChart() {
		if (!chartCanvas) return;
		let ctx = chartCanvas.getContext('2d');
		let datasets = enabledDiffs.map((itemId) => {
			let v = 0;
			let data = diffsRes
				.filter((entry) => entry.item === itemId)
				// np
				.map((entry) => {
					v += entry.diff;
					return {
						x: Math.floor(new Date(entry.at).getTime() / 1e3),
						y: v
					};
				})
				.sort((a, b) => b.x - a.x);

			const img = document.createElement('img');
			img.src = getTexture({ id: itemId });
			img.width = 24;
			img.height = 24;
			img.style = 'border: 1px solid orange';

			return {
				label: itemId,
				data,
				backgroundColor: 'transparent',
				showLine: false,
				pointStyle: img
			};
		});
		let chart = new chartjs(ctx, {
			type: 'scatter',
			data: {
				datasets
			},
			options: {
				legend: {
					display: false
				}
			}
		});
	}

	onMount(() => {
		doFetch();
	});

	// ! Base logic
	$: items = Object.entries(itemsRes).map(([id, count]) => ({ id, count }));
	$: itemsSorted = items.sort((a, b) => a.id.localeCompare(b.id));
	$: itemCount = items.reduce((acc, item) => acc + (item.count || 0), 0);

	// ! Search / filter
	let searchValue = '';
	let filteredItems: ItemType[] = [];
	function searchItems() {
		filteredItems = filterItems(itemsSorted, searchValue);
	}

	$: (searchValue, searchItems());
	$: (items, searchItems());
</script>

<div class="my-16 grid w-full grid-cols-[1fr,300px] gap-8">
	<div class="space-y-4">
		<Card>
			<canvas bind:this={chartCanvas} id="myChart"></canvas>
		</Card>
		<Card>
			<Title>Inventory</Title>
			{#if error}
				<p class="text-red-600">{error}</p>
			{/if}

			<Grid>
				{#each filteredItems as item}
					<Slot>
						<Item {item} />
					</Slot>
				{/each}
			</Grid>
		</Card>
	</div>
	<div class="space-y-8">
		<Voice {items} />
		<Card>
			<Title>Search</Title>
			<Input bind:value={searchValue} placeholder="Search..." />
		</Card>
		<Card>
			<Title>{storageName}</Title>
			<Paragraph>Total items: {itemCount}</Paragraph>
			<ParagraphWithItem>
				<Item tooltip={false} item={{ id: 'computercraft:turtle_normal' }} />
				Access points: 9
			</ParagraphWithItem>
			<ParagraphWithItem>
				<Item tooltip={false} item={{ id: 'minecraft:barrel' }} />
				Deposit points: 12
			</ParagraphWithItem>
			<ParagraphWithItem>
				<Item tooltip={false} item={{ id: 'minecraft:chest' }} />
				Chests: 182
			</ParagraphWithItem>
			<ParagraphWithItem>
				<Item tooltip={false} item={{ id: 'minecraft:trapped_chest' }} />
				Get-only chests: 12
			</ParagraphWithItem>
		</Card>
	</div>
</div>
