<script>
	// @ts-nocheck
	import '../app.css';
	let uris = 'localhost';

	import { navigating } from '$app/stores';
	import { loading } from '$lib/loading';
	import Loading from '$lib/Loading.svelte';

	$: $loading = false;
</script>

<!-- <svelte:head>
	<title>Toserba</title>
</svelte:head> -->

<Loading />
<slot />



