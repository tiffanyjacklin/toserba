<script>
    import DateConverter from '$lib/DateConverter.svelte';
    import { onMount } from 'svelte';
    import { uri, roleId } from '$lib/uri.js';

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
    $: role_id_notif = 0;

    $: if (role_id_notif !== undefined) {
        fetchNotifications();
    }

    async function fetchNotifications() {
        url = (Number($roleId) !== 6 && Number($roleId) !== 5)
            ? `http://${$uri}:8888/notifications/${$roleId}`
            : `http://${$uri}:8888/notifications/${role_id_notif}`;

        console.log(url);
        const response = await fetch(url, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        });

        if (response.ok) {
            const data = await response.json();
            if (data.status === 200) {
                notifications = data.data;
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
                        on:click={() => { whatNotif = notifType; role_id_notif = notificationMap[notifType];}} 
                        class={`font-medium text-xl w-56 py-2 rounded-lg border ${whatNotif === notifType ? "bg-peach2 text-darkGray" : "bg-darkGray text-white hover:bg-[#3d4c52]"}`}>
                        {notifType.replace(/_/g, ' ')}
                    </button>
                {/each}
            </div>
        </div>
    {/if}
    <div class="my-5 min-h-screen w-full">
        <div class="relative overflow-x-auto  sm:rounded-lg text-lg">
            {#if notifications.length === 0}
                <div class="text-center py-4 border border-black w-full rounded-lg shadow-md my-4">No notification found.</div>
            {:else}
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
            {/if}
        </div>
    </div>
</div>
