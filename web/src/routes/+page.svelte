<script>
    import { onMount } from 'svelte';

    let json;
    let roles = [];
    let selectedRole = '';

    async function fetchJson() {
        const response = await fetch('/data_dummy.json');
        if (response.ok) {
            const jsonData = await response.json();
            return jsonData;
        } else {
            throw new Error('Failed to fetch JSON');
        }
    }

	onMount(async () => {
        try {
            json = await fetchJson();
            roles = json.toserba.roles || []; 
            console.log('Roles:', roles); 
            selectedRole = 'Select Your Role'; 
        } catch (error) {
            console.error('Error fetching JSON:', error);
        }
    });

    function checkCredentials(username, password, selectedRole) {
        const user = json.toserba.users.find(user => user.username === username && user.user_password === password);
        if (user) {
			const userRole = json.toserba.user_roles.find(ur => ur.user_id === user.user_id && ur.roles_id === selectedRole)
            return !!userRole;
        }
        return false;
    }

	function handleSubmit(event) {
		event.preventDefault();

		const username = event.target.username.value;
		const password = event.target.password.value;

		const user = json.toserba.users.find(user => 
			user.username === username && 
			user.user_password === password
		);

		if (user && checkCredentials(username, password, selectedRole)) {
			const userId = user.user_id;
			const user_fullname = user.user_fullname;
			const user_photo_profile = user.user_photo_profile;
			const user_role = selectedRole;

			// alert("SUKSES");
			window.location.href = '/dashboard';

			localStorage.setItem('userId', userId);
			localStorage.setItem('user_fullname', user_fullname);
			localStorage.setItem('user_photo_profile', user_photo_profile);
			localStorage.setItem('user_role', user_role);
		} else {
			alert('Invalid username, password, or role');
		}
	}
	function handleUsernameKeyDown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            const passwordInput = event.target.form.elements.password;
            passwordInput.focus();
        }
    }

    function handlePasswordKeyDown(event) {
        if (event.key === 'Enter') {
            event.preventDefault();
            handleSubmit(event);
        }
    }
</script>

<svelte:head>
	<title>Home</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<figure class="shadow-xl container bg-slate-100 rounded-xl p-4 sm:p-8 dark:bg-slate-800">
    <div class="flex flex-col sm:flex-row">
        <div class="welkombek flex-none w-full sm:w-1/2 relative hidden sm:block">
			<div class="flex flex-col h-full w-full">
				<div class="package-top h-1/2 w-full relative">
					<div class="seal h-4/5 w-1/6 absolute top-0 left-0"></div>
					<div class="welcome-text text-6xl tracking-wider absolute bottom-0 left-0">Welcome</div>
				</div>
				<div class="package-bottom h-1/2 w-full text-8xl">Back.</div>
			</div>
		</div>
		<form on:submit={handleSubmit} class="flex-auto p-4 sm:p-6 w-full sm:w-1/2 flex flex-col space-y-1">
            <div>
                <h1 class="login-text text-6xl uppercase text-shadow-inner font-semibold text-slate-900 mb-6">Login</h1>
            </div>
			<div class="relative">
				<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" class="icon absolute h-5 w-5 left-3 top-1/2 transform -translate-y-1/2 pointer-events-none text-gray-400">
					<path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7" />
				</svg>
				<select id="role" autocomplete="Select Your Role" name="role" bind:value={selectedRole} class="capitalize focus:ring-2 focus:ring-blue-500 focus:outline-none appearance-none w-full pl-10 pr-8 text-sm leading-6 text-slate-900 placeholder-slate-400 rounded-md py-2 ring-1 ring-slate-200 shadow-sm">
					<option disabled selected >Select Your Role</option>
					{#each roles as role, index}
						<option class="capitalize" value={role.roles_id}>{role.roles_name}</option>
					{/each}
				</select>
			</div>
			
            <div class="w-full">
                <label for="username" class="forgot-text block text-sm font-medium leading-6 text-gray-900">Username</label>
                <div class="relative">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="icon absolute h-5 w-5 top-2 left-3 text-gray-400">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
                    </svg>
                    <input id="username" name="username" type="text" placeholder="Username" class="focus:ring-2 focus:ring-blue-500 focus:outline-none appearance-none block w-full px-10 py-2 text-sm leading-6 text-slate-900 placeholder-slate-400 rounded-md ring-1 ring-slate-200 shadow-sm" required>
                </div>
            </div>
            <div class="w-full">
                <label for="password" class="forgot-text block text-sm font-medium leading-6 text-gray-900">Password</label>
                <div class="relative">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="icon absolute h-5 w-5 top-2 left-3 text-gray-400">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
                    </svg>
                    <input id="password" name="password" type="password" placeholder="Password" class="focus:ring-2 focus:ring-blue-500 focus:outline-none appearance-none block w-full px-10 py-2 text-sm leading-6 text-slate-900 placeholder-slate-400 rounded-md ring-1 ring-slate-200 shadow-sm" required>
                </div>
            </div>
            <div>
                <p class="text-sm text-slate-700 text-right mb-6"><a href="/forgot-password" class="forgot-text">Forgot Password?</a></p>
            </div>
            <button type="submit" class="h-10 px-6 inline-flex items-center justify-center font-semibold rounded-md bg-f2b082 text-white hover:shadow-2xl">
				<span class="icon">Login</span>
				<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6 ml-1">
					<path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15M12 9l3 3m0 0-3 3m3-3H2.25" />
				</svg>
			</button>
        </form>
    </div>
</figure>

<style lang="postcss">
	
	input, select {
		box-shadow: inset 0 0 5px rgba(0,0,0,0.2);
	}
    .container {
        background-color: #3d4c52;
		width: 90%;
		max-width: 800px; 
		margin: auto;
    }

    .welkombek {
        display: flex;
        min-height: 40vh; 
        align-items: center;
    }

	.flex {
		display: flex;
		height: 100%;
	}

	.package-top {
		background-color: var(--color-bg-4);
		padding: 20px;
		text-align: center;
		border-top-left-radius: 20px;
		position: relative;
		margin-bottom: 10px; 
		width: 100%; 
	}

	.seal {
		background-color: #f8be7f;
		position: absolute;
		top: 0;
		left: 50%;
		transform: translateX(-50%);
		z-index: 1; 
	}

	.welcome-text {
		position: absolute;
		bottom: 10px;
		left: 50%;
		transform: translateX(-50%);
		z-index: 2;
		font-family: 'Helvetica', sans-serif;
		font-weight: 700;
		color: #3d4c52; 
		font-stretch: ultra-condensed;	
	}

	.package-bottom {
		background-color: var(--color-bg-5);
		padding: 20px;
		text-align: center;
		color: #3d4c52; 
		border-bottom-left-radius: 20px;
		margin-top: 10px; 
		font-weight: 800;
		font-family: 'Helvetica', sans-serif;
		font-stretch: condensed;	
	}

    .login-text {
		position: relative; 
		color: var(--color-bg-4);
		font-weight: 800;
		font-family: 'Helvetica', sans-serif;
		font-stretch: condensed;
	}

	.login-text::before {
		content: '';
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		z-index: -1;
		box-shadow: inset 0 0 10px rgba(0, 0, 0, 0.5); 
		border-radius: 5px;
	}

    .forgot-text {
        color: white;
        display: block;
        text-decoration: none;
        font-stretch: ultra-condensed;
        margin-top: 5px;
		font-weight: 600;
    }

    .icon {
        color: var(--color-bg-3);
		
    }

    @media (max-width: 640px) {
        .welkombek {
            display: none; 
        }

        .container {
            width: 100%; 
            padding: 20px;
        }
    }
</style>
