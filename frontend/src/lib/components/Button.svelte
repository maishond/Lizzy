<script lang="ts">
	import { createEventDispatcher } from 'svelte';
	const dispatch = createEventDispatcher();

	export let className: string = '';
</script>

<button
	on:click={(evt) => dispatch('click', evt)}
	class={[
		'text-shadow relative w-full border-l-2 border-t-2 border-gray-100 border-opacity-50 py-2 text-white outline outline-2 outline-black hover:outline-white active:outline-black',
		className
	].join(' ')}
>
	<slot />
</button>

<style lang="scss">
	button {
		background-image: url('/button.png');
		image-rendering: pixelated;
		image-rendering: -moz-crisp-edges;
		image-rendering: crisp-edges;

		&:active {
			background-image: url('/button-active.png');
			@apply text-[#ffffa0];
		}

		&::after {
			content: '';
			@apply absolute -left-0.5 -top-0.5 box-content block h-[calc(100%-2px)] w-full border-b-4 border-r-2 border-black border-opacity-20;
		}
	}
</style>
