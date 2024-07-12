<script>

</script>

<svelte:head>
	<title>Home</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<div class="outerbox">
	<div class="col-span-2">
		<div class="">
		</div>
		<div class="">
		</div>

	</div>
	<div class="col-span-2">
		<div class="title-login">LOGIN</div>
		<div class="sm:col-span-4">
			<select id="country" name="country" autocomplete="country-name" class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:max-w-xs sm:text-sm sm:leading-6">
			<option>Cashier</option>
			<option>Store Employee</option>
			<option>Warehouse Employee</option>
			<option>Warehouse Operational</option>
			<option>Admin</option>
			<option>Owner</option>
			</select>
		</div>
		<div class="sm:col-span-4 relative">
  			<label for="username" class="block text-sm font-medium leading-6 text-gray-900">Username</label>
			<div class="mt-2 relative">
				<span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
				<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="h-5 w-5 text-gray-400">
					<path strokeLinecap="round" strokeLinejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
				</svg>
				</span>
				<input type="text" name="username" id="username" autocomplete="username" class="block w-full rounded-md border-0 py-1.5 pl-10 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6">
			</div>
			</div>

			<div class="sm:col-span-4 relative">
			<label for="password" class="block text-sm font-medium leading-6 text-gray-900">Password</label>
			<div class="mt-2 relative">
				<span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
				<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="h-5 w-5 text-gray-400">
					<path strokeLinecap="round" strokeLinejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
				</svg>
				</span>
				<input type="password" name="password" id="password" autocomplete="current-password" class="block w-full rounded-md border-0 py-1.5 pl-10 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6">
			</div>
			<div class="">
				<a href="/forgot-password">Forgot Password?</a>
				
			</div>
			</div>
			<button type="submit" class="inline-flex items-center rounded-md bg-f2b082 px-3 py-2 text-sm font-semibold text-black shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600">
				<a href="/about">Login</a>
				 
				<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6">
					<path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15M12 9l3 3m0 0-3 3m3-3H2.25" />
				</svg>
			</button>

	</div>
</div>
<div class="">
</div>


<style lang="postcss">
	.title-login{

	}
	.outerbox {
		border-radius: 10px;
		background-color: #3d4c52;
		display: flex;
		justify-content: center;
		align-items: center;
		width: 90% !important;
		height: 90% !important;
		flex: 1;
		
	}

	section {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
		flex: 0.9;
		background-color: #3d4c52;
		border-radius: 10px;
	}

	h1 {
		width: 100%;
	}

	.welcome {
		display: block;
		position: relative;
		width: 100%;
		height: 0;
		padding: 0 0 calc(100% * 495 / 2048) 0;
	}

	.welcome img {
		position: absolute;
		width: 100%;
		height: 100%;
		top: 0;
		display: block;
	}
</style>
