<script>
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';
    import { browser } from '$app/environment';
    import { uri, userId, roleId } from '$lib/uri.js';
    import { get } from 'svelte/store';
    import { getFormattedDate } from '$lib/DateNow.js';

    export let data;
    let json;
    let roles = [];
    userId.set(String(data.id));
    // let userId = data.id;
    // console.log($userId);
    let selectedRole = '';
    $: isAdminAlreadyAppeared = false;
  
    // console.log("user id : " + $userId);

    async function fetchRoles() {
        const response = await fetch(`http://${$uri}:8888/user/roles/${$userId}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('Roles fetch failed', response);
            return;
        }

        const data = await response.json();
        console.log("data", data);

        if (data.status !== 200) {
            console.error('Invalid user roles', data);
            return;
        }
        
        roles = data.data;

        for (let i = 0; i < roles.length; i++) {
            if (roles[i].role_id == 5){
                if (isAdminAlreadyAppeared == false){
                    isAdminAlreadyAppeared = true;
                } else {
                    roles.splice(i,1);
                }
            }
        }

        console.log(roles);
    }

    onMount(() => {
        fetchRoles();
    });

    function ChooseRole(role_id, role_name) {
        selectedRole = role_id;
        roleId.set(String(role_id));
        roleId.subscribe(async value => {
            let description = "User ID "+$userId+" login sebagai "+role_name+" pada "+getFormattedDate();
            await insertNotif(description);
            if (value === String(1)){
                goto(`/session`);
            }
            else if (value === String(4)){
                goto(`/products`);
            }
            else if (value === String(5)){
                goto(`/manage_cashier`);
            }
            else if (value === String(6)){
                goto(`/dashboard`);
            }
        });
    }

    async function insertNotif(descriptionnya){
        console.log(descriptionnya);
        const response = await fetch(`http://${$uri}:8888/notifications/add`, {
            method: 'POST',
            body: JSON.stringify({
                user_id: Number($userId),
                roles_id: Number($roleId),
                description: descriptionnya,
                notification_type_id: 13
            })
        });

        if (!response.ok) {
            console.error('POST new notif gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid post new notif', data);
            return;
        }
    }
</script>
<svelte:head>
    <title>Toserba | Pilih Role</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A==" crossorigin="anonymous" referrerpolicy="no-referrer" />  
</svelte:head>
<div class="flex justify-center my-10">
    <div class="h2 self-center font-bold text-4xl text-darkGray">Pilih Role Anda</div>
</div>

<div class="flex justify-center">
    <div class="flex flex-wrap justify-center align-items-center gap-4 w-8/12">
        {#each roles as role, index}
            <a on:click={() => ChooseRole(role.role_id, role.roles_name)} href="#" value={role.role_id} class="w-72 h-48 flex flex-col text-center items-center justify-center block max-w-sm p-6 bg-peach border border-peach2 rounded-lg shadow hover:bg-peach2 ">
                {#if role.role_id == 1}
                    <i class="fa-solid fa-cash-register fa-5x" style="color: #364445;"></i>
                {:else if role.role_id == 2}
                    <i class="fa-solid fa-cart-flatbed fa-5x" style="color: #364445;"></i>
                {:else if role.role_id == 3}
                    <i class="fa-solid fa-warehouse fa-5x" style="color: #364445;"></i>
                {:else if role.role_id == 4}
                    <i class="fa-solid fa-user-gear fa-5x" style="color: #364445;"></i>
                {:else if role.role_id == 5}
                    <i class="fa-solid fa-user-group fa-5x" style="color: #364445;"></i>
                {:else if role.role_id == 6}
                    <i class="fa-solid fa-user-tie fa-5x" style="color: #364445;"></i>
                {/if}
                <h5 class="capitalize mt-2 text-2xl font-semibold tracking-tight text-darkGray">{role.roles_name}</h5>
                <!-- <h5 class="capitalize mt-2 text-2xl font-semibold tracking-tight text-darkGray">{role.role_id}</h5> -->
            </a>
        {/each}
    </div>
</div>

<div class="flex mt-8 justify-center">
    <button on:click={e => window.location.href="/login"} type="button self-end" class="text-black font-semibold bg-peach hover:bg-peach2 focus:ring-4 focus:ring-peach2 font-medium rounded-lg text-sm px-8 py-2.5 me-2 mb-2">Kembali</button>
</div>
