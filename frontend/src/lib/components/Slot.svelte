<div class="slot aspect-square border-2 w-full h-full">
	<slot />
</div>

<style lang="scss">
	.slot {
		background-color: #8b8b8b;
		border-color: #2a2a2a #fff #fff #2a2a2a;
		@apply relative;

		&:hover {
			background-color: #c5c5c5;
		}

		&:before,
		&:after {
			content: '';
			@apply block absolute w-0.5 h-0.5 bg-[#8c8c8c];
		}

		&:before {
			top: -2px;
			right: -2px;
		}

		&:after {
			bottom: -2px;
			left: -2px;
		}
	}
</style>
