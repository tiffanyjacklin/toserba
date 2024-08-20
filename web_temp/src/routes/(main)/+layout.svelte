<script>
	// @ts-nocheck
	import Menu from '$lib/Menu.svelte';
	import Navbar from '$lib/Navbar.svelte';
	import Sidebar from '$lib/Sidebar.svelte';
	import { page } from '$app/stores';

	$: hide = $page.url.pathname.startsWith('/session_main') ||  $page.url.pathname.startsWith('/payment');

	export let data;
	let userId = data.userId;
	let roleId = data.roleId;
	
	if (hide){
		console.log("ini main")
	}

</script>

<svelte:head>
    <title>Toserba | Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A==" crossorigin="anonymous" referrerpolicy="no-referrer" />  
</svelte:head>

{#if !hide}
	<Navbar title="Toserba" href="/">
		<!-- <Menu title="Home" href="/"></Menu> -->
	</Navbar>

	<Sidebar userId={userId} roleId={roleId}>
	</Sidebar>

	<div class="ml-64 mt-16">
		<slot />
	</div>
	{:else if hide}
	<slot />
{/if}



<style>
	
</style>
