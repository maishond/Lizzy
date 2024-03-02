<script>
	import '../app.pcss';
</script>

<svelte:head>
	<link
		rel="preload"
		as="font"
		href="/fonts/Minecraft.woff"
		type="font/woff"
		crossorigin="anonymous"
	/>
</svelte:head>

<!-- Watch out for subpixel rendering -->
<main class="mx-auto flex w-4/5 max-w-[1000px] justify-center">
	<slot />
</main>

<style>
	@import '../app.scss';
</style>
