<script lang="ts">
	import Paragraph from './Paragraph.svelte';

	export let left: number;
	export let top: number;
	export let title: string;
</script>

<div
	style={`left: ${left}px; top: ${top}px;`}
	class="pointer-events-none fixed z-50 rounded border-2 border-[#3c0064] bg-[rgba(0,0,0,.8)] p-1 text-white [box-shadow:0_0_0_2px_black]"
>
	<Paragraph>{title}</Paragraph>
</div>
