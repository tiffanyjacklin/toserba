<script>
	// @ts-nocheck
	import Menu from '$lib/Menu.svelte';
	import Navbar from '$lib/Navbar.svelte';
	import { currentDate} from '$lib/monthyear';

</script>

<Navbar title="Calendar">
	<Menu title="Home" href="/"></Menu>
	<Menu title="Monthly"  href="/monthly/{currentDate.getFullYear()}/{currentDate.getMonth() + 1}"></Menu>
</Navbar>

<div class="p-4">
	<slot />
</div>
