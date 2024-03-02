<section class="card w-full space-y-2 rounded border-[2px] p-4 pt-[0.8rem]">
	<slot />
</section>

<style lang="scss">
	.card {
		// I could have used JIT for this, but that would have been a lot of JIT.
		background-color: #c6c6c6;
		border-color: #fff #555 #555 #fff;
		box-shadow: 0 0 0 2px black;
	}
</style>
