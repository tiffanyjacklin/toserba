<script>
    import DateConverter from '$lib/DateConverter.svelte';
    import { onMount } from 'svelte';
    import { uri, roleId } from '$lib/uri.js';

    $: limit = 20;
    $: offset = 0; 
    $: totalNotes = 10;
    $: currentPage = 1;

    let url = '';
    let whatNotif = 'System';
    let notifications = [];
    let system_notifications = [];
    let cashier_notifications = [];
    let store_inventory_employee_notifications = [];
    let wh_employee_notifications = [];
    let wh_operational_employee_notifications = [];
    let admin_notifications = [];
    let owner_notifications = [];
    $: search_user_name = ''
    $: search_user_id = '';
    $: notif_type_id = '';
    $: notif_type_namenya = '';
    $: start_date = '';
    $: end_date = '';
    $: role_id_notif = 0;
    
    $: searchQuery = '';
    $: searchQuery_temp = '';
    let showFilter = false;

    function toggleFilter() {
      showFilter = !showFilter;
    }
    let showTypeList = false;

    function toggleTypes(){
        showTypeList = !showTypeList;
        showUsersList = false;
    }
    let showUsersList = false;

    function toggleUsers(){
        showUsersList = !showUsersList;
        showTypeList = false;
    }
    $: users = [];
    $: notif_types = [];
    $: if (role_id_notif !== undefined) {
        fetchNotifications();
        if (role_id_notif !== 0 || String(role_id_notif) !== ''){
            fetchUsers();

        }
        
        fetchNotificationsType();
    }
    
    onMount(async () => {
        await fetchUsers();
        await fetchNotificationsType();
    });
    async function selectType(type){
        notif_type_id = type.notification_type_id; 
        notif_type_namenya = type.notification_type_name;
        toggleTypes();
    }
    
    async function selectUser(user){
        search_user_id = user.user_id; 
        search_user_name = user.user_fullname;
        toggleUsers();
    }
    async function goToPage(page) {
        if (page < 1 || page > Math.ceil(totalNotes / limit)) return;

        currentPage = page;
        offset = (currentPage - 1) * limit;
        await fetchNotifications();
    }

    async function fetchUsers() {
        url = (Number($roleId) !== 6 && Number($roleId) !== 5)
            ? `http://${$uri}:8888/user/roles/data/${$roleId}`
            : `http://${$uri}:8888/user/roles/data/${role_id_notif}`;

        console.log(url);
        const response = await fetch(url, {
                method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error(' session fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch ', data);
            return;
        }
        users = data.data;

        if (Number($roleId) === 5 || Number(role_id_notif) === 5) {
            const uniqueFullnames = new Set();
            users = users.filter(user => {
                if (uniqueFullnames.has(user.user_fullname)) {
                    return false; // Skip if the fullname is already in the set
                } else {
                    uniqueFullnames.add(user.user_fullname);
                    return true; // Keep the user if the fullname is unique
                }
            });
        }
    }
    
    async function fetchNotificationsType() {
        const response = await fetch(`http://${$uri}:8888/notifications/type/0/0`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error(' session fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch ', data);
            return;
        }
        notif_types = data.data;
    }
    async function fetchNotifications() {
        url = (Number($roleId) !== 6 && Number($roleId) !== 5)
            ? `http://${$uri}:8888/notifications/${$roleId}/${search_user_id}/${notif_type_id}/${start_date}/${end_date}/${limit}/${offset}`
            : `http://${$uri}:8888/notifications/${role_id_notif}/${search_user_id}/${notif_type_id}/${start_date}/${end_date}/${limit}/${offset}`;

        console.log(url);
        const response = await fetch(url, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });

        if (response.ok) {
            const data = await response.json();
            if (data.status === 200) {
                notifications = data.data;
                totalNotes = data.total_rows;
            } else {
                console.error('Invalid fetch response', data);
            }
        } else {
            console.error('Fetch failed', response);
        }
    }

    const notificationMap = {
        "System": 0,
        "Cashier": 1,
        "Store Inventory": 2,
        "Warehouse": 3,
        "Warehouse Operational": 4,
        "Admin": 5,
        "Owner": 6
    };

</script>

<div class="mx-8 mb-10 py-8 px-12 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg font-roboto">
    <span class="text-4xl font-bold text-[#364445] my-10">Notifications</span>
    {#if Number($roleId) === 5 || Number($roleId) === 6}
        <div class="">
            <div class="grid grid-cols-4 gap-x-2 gap-y-4">
                {#each Object.keys(notificationMap) as notifType}
                    <button 
                        on:click={() => { whatNotif = notifType; role_id_notif = notificationMap[notifType]; notif_type_id = ""; notif_type_namenya = ""; start_date = ""; end_date = ""; search_user_id = ""; search_user_name = "";}} 
                        class={`font-medium text-xl w-56 py-2 rounded-lg border ${whatNotif === notifType ? "bg-peach2 text-darkGray" : "bg-darkGray text-white hover:bg-[#3d4c52]"}`}>
                        {notifType.replace(/_/g, ' ')}
                    </button>
                {/each}
            </div>
        </div>
    {/if}
    <div class="my-5 min-h-screen w-full">
        <div class="relative overflow-x-auto  sm:rounded-lg text-lg">
            <label for="voice-search" class="sr-only">Search</label>
                <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
                <input 
                type="text"  on:click={toggleFilter}
                id="voice-search" 
                class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                placeholder="Click to show filter" />          
                <button on:click={toggleFilter}
                    type="button" 
                    class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                    <i class="fa-solid fa-sliders fa-xl mr-2"></i>
                </button>
                {#if showFilter}
                    <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-fit  bg-gray-100 p-4 rounded-lg font-roboto">
                        <span class="font-bold text-xl mb-1">Join Date Period</span>
        
                        <div class="flex gap-x-4 w-full items-center">
                        <span class="font-semibold text-lg mb-4">From</span>
                        <input type="date" bind:value={start_date} class="rounded-xl w-32 mb-4 p-2 border" />
                        <span class="font-semibold text-lg mb-4">To</span>
                        <input type="date" bind:value={end_date} class="rounded-xl w-32 mb-4 p-2 border" />
                        </div>
                        {#if ((String(role_id_notif) === '' || role_id_notif === 0) && $roleId !== '6') || ($roleId === '6' && role_id_notif !== 0)}
                        <span class="font-bold text-xl mb-1">User</span>
                        <div class="mb-4">
                            <input type="text" bind:value={search_user_name} on:click={toggleUsers} class="rounded-lg w-full h-8"/>
                            {#if users.length > 0 && showUsersList}
                            <ul class={`${users.length > 5 ? 'h-64' : 'h-fit'} mt-2 overflow-y-auto absolute w-11/12  bg-white shadow-md z-10`}>
                                {#each users as user}
                                <li on:click={() => {selectUser(user)}} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{user.user_fullname}</li>
                                {/each}
                            </ul>
                            {/if}
                        </div>
                        {/if}
                        
                        
                        <span class="font-bold text-xl mb-1">Notification Type</span>
                        <div class="mb-4">
                            <input type="text" bind:value={notif_type_namenya} on:click={toggleTypes} class="rounded-lg w-full h-8"/>
                            {#if notif_types.length > 0 && showTypeList}
                            <ul class={`${notif_types.length > 5 ? 'h-64' : 'h-fit'} mt-2 overflow-y-auto absolute w-11/12  bg-white shadow-md z-10`}>
                                {#each notif_types as type}
                                <li on:click={() => {selectType(type)}} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{type.notification_type_name}</li>
                                {/each}
                            </ul>
                            {/if}
                        </div>
        
                        <div class="flex justify-between font-semibold mt-4">
                            <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={async () => { notif_type_id = ""; notif_type_namenya = ""; start_date = ""; end_date = ""; search_user_id = ""; search_user_name = ""; await fetchNotifications(); showFilter = false;}}>Clear</button>
                            <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={async () => {await fetchNotifications(); showFilter = false;}}>Apply</button>
                        </div>
                    </div>
                {/if}
                </div>

            {#if notifications.length === 0}
                <div class="text-center py-4 border border-black w-full rounded-lg shadow-md my-4">No notification found.</div>
            {:else}
                
                <nav class="my-8 flex justify-center">
                    <ul class="flex items-center -space-x-px h-8 text-sm">
                    {#if totalNotes !== 0}
                    <li>
                        <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                        <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                            <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
                        </svg>
                        Previous
                        </a>
                    </li>
                    {/if}
                
                    <!-- Pagination Links -->
                    {#each Array(Math.ceil(totalNotes / limit)) as _, i}
                        <li>
                        <a href="#" on:click|preventDefault={() => goToPage(i + 1)} class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">{i + 1}</a>
                        </li>
                    {/each}
            
                    {#if totalNotes !== 0}
                    <li>
                        <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                        Next
                        <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                            <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
                        </svg>
                        </a>
                    </li>
                    {/if}
                    </ul>
                </nav>

                {#each notifications as notification}
                    <div class="flex border border-black justify-between divide-x-2 divide-[#364445] rounded-lg shadow-md my-4 py-1">
                        <div class="flex divide-x-0 w-[80%]">
                            <div class="w-1/5 px-6 py-3 font-bold text-gray-900">{notification.Notifications.notification_type_name}</div>
                            <div class="w-4/5 px-6 py-3 font-semibold">{notification.Notifications.description}</div>
                        </div>
                        <div class="px-6 py-3 font-semibold w-[20%]">
                            <DateConverter value={notification.Notifications.timestamp} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false} />
                        </div>
                    </div>
                {/each}

                <nav class="my-8 flex justify-center">
                    <ul class="flex items-center -space-x-px h-8 text-sm">
                       {#if totalNotes !== 0}
                       <li>
                        <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                          <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                            <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
                          </svg>
                          Previous
                        </a>
                       </li>
                       {/if}
                  
                      <!-- Pagination Links -->
                      {#each Array(Math.ceil(totalNotes / limit)) as _, i}
                        <li>
                          <a href="#" on:click|preventDefault={() => goToPage(i + 1)} class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">{i + 1}</a>
                        </li>
                      {/each}
              
                      {#if totalNotes !== 0}
                      <li>
                        <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                          Next
                          <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                            <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
                          </svg>
                        </a>
                      </li>
                      {/if}
                    </ul>
                  </nav>
            {/if}
        </div>
    </div>
</div>
