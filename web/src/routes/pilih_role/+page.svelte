<script>
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';

    let json;
    let allowed_roles = []
    let roles = [];
    let selectedRole = '';
    let userId = localStorage.getItem('userId');
    console.log("user id : " + userId)

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
            
            allowed_roles = json.toserba.user_roles.filter(u => u.user_id == userId);
            console.log('Allowed Roles:', allowed_roles); 
            for (let i = 0; i < allowed_roles.length; i++) {
                const tmp_role = json.toserba.roles.find(r => r.roles_id == allowed_roles[i].roles_id)
                roles.push(tmp_role) 
            }
            console.log('Roles:', roles);
            roles = roles
            selectedRole = 'Select Your Role'; 
        } catch (error) {
            console.error('Error fetching JSON:', error);
        }
    });
    
    
    function ChooseRole(roles_id){
        selectedRole = roles_id;
        console.log("role : " + selectedRole);

        const user_role = selectedRole;

        // window.location.href = '/dashboard'
        goto('/dashboard')
        localStorage.setItem('userId', userId)
        localStorage.setItem('user_role', user_role)
    }


</script>

<svelte:head>
	<title>Pilih Role</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A==" crossorigin="anonymous" referrerpolicy="no-referrer" />  
</svelte:head>

<div class="flex justify-center my-10">
    <div class="h2 self-center font-bold text-4xl text-darkGray">Pilih Role Anda</div>
</div>

<div class="grid grid-cols-3 gap-4 flex-items-stretch">
    {#each roles as role, index}
        <div class="">
            <a on:click={ChooseRole(role.roles_id)} href="#" value={role.roles_id} class="h-full text-center flex flex-col gap-y-3 items-center justify-center block max-w-sm p-6 bg-peach border border-peach2 rounded-lg shadow hover:bg-peach2 ">
                {#if role.roles_id == 1}
                    <i class="fa-solid fa-cash-register fa-5x" style="color: #364445;"></i>
                {:else if role.roles_id == 2}
                    <i class="fa-solid fa-cart-flatbed fa-5x" style="color: #364445;"></i>
                {:else if role.roles_id == 3}
                    <i class="fa-solid fa-warehouse fa-5x" style="color: #364445;"></i>
                {:else if role.roles_id == 4}
                    <i class="fa-solid fa-user-gear fa-5x" style="color: #364445;"></i>
                {:else if role.roles_id == 5}
                    <i class="fa-solid fa-user-group fa-5x" style="color: #364445;"></i>
                {:else if role.roles_id == 6}
                    <i class="fa-solid fa-user-tie fa-5x" style="color: #364445;"></i>
                {/if}
                <h5 class="capitalize mb-2 text-2xl font-semibold tracking-tight text-darkGray">{role.roles_name}</h5>
            </a>
        </div>
    {/each}

</div>

<div class="flex mt-8 justify-center">
    <button on:click={e => window.location.href="/"} type="button self-end" class="text-black font-semibold bg-gray-200 hover:bg-gray-300 focus:ring-4 focus:ring-gray-100 font-medium rounded-lg text-sm px-8 py-2.5 me-2 mb-2">Kembali</button>
</div>
