<script>
	// @ts-nocheck
	import Menu from '$lib/Menu.svelte';
	import Navbar from '$lib/Navbar.svelte';

</script>

<Navbar title="Toserba" href="/">
	<!-- <Menu title="Home" href="/"></Menu> -->
</Navbar>

<div class="p-4">
	<slot />
</div>
