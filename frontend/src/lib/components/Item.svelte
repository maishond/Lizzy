<script script lang="ts">
	import type { Item as ItemType } from '$lib/types';

	import { onDestroy, onMount } from 'svelte';
	import Tooltip from './Tooltip.svelte';
	import { browser } from '$app/environment';
	import { dropItem, toName } from '$lib/utils/util';
	import { TMP_SYSTEM_ID } from '$lib/config';

	export let tooltip: boolean = true;
	export let item: ItemType;

	const mousePosRelativeToItem = { x: 0, y: 0 };

	function getTexture(item: { id: string }) {
		const [namespace, itemName] = item.id.split(':');
		return `/items/${namespace}/items/${itemName}.png`;
	}

	$: texture = getTexture(item);
	let visible = false;

	function onMouseMove(evt: MouseEvent) {
		mousePosRelativeToItem.x = evt.clientX;
		mousePosRelativeToItem.y = evt.clientY;
	}

	onMount(() => {
		if (tooltip && browser) window.addEventListener('mousemove', onMouseMove);
	});

	onDestroy(() => {
		if (tooltip && browser) window.removeEventListener('mousemove', onMouseMove);
	});
</script>

{#if visible && tooltip}
	<Tooltip left={mousePosRelativeToItem.x} top={mousePosRelativeToItem.y} title={toName(item.id)} />
{/if}

<!-- svelte-ignore a11y-no-static-element-interactions -->
<button
	class="relative -m-0.5 block p-0.5"
	on:mouseenter={() => (visible = true)}
	on:mouseleave={() => (visible = false)}
	on:click={() => {
		dropItem(TMP_SYSTEM_ID, { id: item.id, count: Number(prompt('How much pls')) });
	}}
>
	<img src={texture} class="h-full w-full" alt="" loading="lazy" />
	{#if (item.count || 0) > 1}
		<span class="text-shadow pointer-events-none absolute bottom-0 right-0 z-20 -mb-1 text-white">
			{#if (item.count || 0) > 1000}
				{Math.floor((item.count || 0) / 1000)}K
			{:else}
				{item.count}
			{/if}
		</span>
	{/if}
	<span></span>
</button>

<style lang="scss">
	img {
		image-rendering: pixelated;
	}
</style>
