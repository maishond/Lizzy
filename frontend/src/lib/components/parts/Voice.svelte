<script lang="ts">
	import { browser } from '$app/environment';
	import { TMP_SYSTEM_ID } from '$lib/config';

	import type { Item as ItemType } from '$lib/types';
	import { dropItem, toName } from '$lib/utils/util';
	import { getItemToGetFromVoice } from '$lib/utils/voice';
	import Button from '../Button.svelte';
	import Card from '../Card.svelte';
	import Title from '../Title.svelte';

	let active = false;
	let shouldStop = false;
	let history: {
		success: boolean;
		data: any;
	}[] = [];

	export let items: ItemType[];

	let recognition: any;
	let error: string | null = null;
	if (browser) {
		// @ts-ignore
		const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
		if (SpeechRecognition) {
			recognition = new SpeechRecognition({});

			recognition.continuous = true;
			recognition.lang = 'en-US';
			recognition.interimResults = false;
			recognition.maxAlternatives = 1;

			recognition.addEventListener('audiostart', () => {
				active = true;
			});

			recognition.addEventListener('audioend', (evt: any) => {
				if (shouldStop) {
					shouldStop = false;
					active = false;
					return;
				}

				try {
					recognition.start();
				} catch (err) {
					active = false;
				}
			});

			recognition.addEventListener('result', (evt: any) => {
				const item = getItemToGetFromVoice(evt.results[evt.results.length - 1] as any[], items);
				console.log(item, 'pushing');
				history = [
					{
						success: !!item,
						data: item || evt.results[evt.results.length - 1][0]?.transcript
					},
					...history.slice(0, 2)
				];

				if (item) {
					dropItem(TMP_SYSTEM_ID, { id: item.id, count: item.count });
				}
			});

			recognition.addEventListener('error', (evt: any) => {
				error = evt.error;
			});
		}
	}

	function toggleListening() {
		if (!active) {
			recognition.start();
		} else {
			console.log('Stopping');
			shouldStop = true;
			recognition.stop();
		}
	}
</script>

<Card>
	<div class="flex items-center justify-between">
		<Title>Voice commands</Title>
		<Button
			on:click={toggleListening}
			className="!w-auto h-10 aspect-square flex justify-center items-center"
		>
			<img
				class="-ml-0.5 -mt-0.5 h-6 w-6"
				src={active ? '/mic.png' : 'mic-disabled.png'}
				alt={`Microphone (${active ? 'enabled' : 'not enabled'})`}
			/>
		</Button>
	</div>
	{#if error}
		<p class="text-red-600">Error: {error} {error === 'network' ? '(Arc moment)' : ''}</p>
	{/if}
	{#each history as historyItem}
		<p class={historyItem.success ? 'text-green-700' : 'text-red-900'}>
			{historyItem.success
				? `Requested ${historyItem.data?.count || 1} ${toName(historyItem.data?.id)}`
				: historyItem.data}
		</p>
	{/each}
</Card>
