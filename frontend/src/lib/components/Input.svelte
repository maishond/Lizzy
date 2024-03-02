<script lang="ts">
	export let value: string;
	export let placeholder: string = '';
</script>

<input
	class="w-full bg-black p-2 text-white outline outline-2 outline-[#969696] focus:outline-white"
	bind:value
	{placeholder}
/>
