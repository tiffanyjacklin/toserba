<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import { onMount } from 'svelte';
    import { uri } from '$lib/uri.js';

    import { goto } from '$app/navigation';
    
    export let userId = 0;
    export let roleId = 0;
    let notifications = [];
    onMount(async () => {
        fetchNotifications();
    });
    async function fetchNotifications() {
        const response = await fetch(`http://${$uri}:8888/notifications`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all produk fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch last', data);
            return;
        }

        notifications = data.data;
        console.log(notifications)
    }
 </script>
 
 <div class="mx-8 mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Notifications</span>
     <div class="w-[96%] my-5 min-h-screen">
        <div class="relative overflow-x-auto shadow-md sm:rounded-lg font-roboto text-lg">
            {#if notifications.length === 0}
                <tr>
                    <td colspan="5" class="text-center py-4">No notification found.</td>
                </tr>
            {:else}
                {#each notifications as notification, i}
                <div class="flex border-2 justify-between divide-x-2 divide-[#364445]">                        
                    <div class="flex">
                        <div class="px-6 py-4 font-bold text-gray-900 whitespace-nowrap">
                            {notification.Notifications.notification_type_name}
                        </div>
                        <div class="px-6 py-4 font-semibold">
                            {notification.Notifications.description}
                        </div>
                    </div>
                    <div class="px-6 py-4 font-semibold">
                        <DateConverter value={notification.Notifications.timestamp} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                    </div>
                </div>
                {/each}
            {/if}
        </div>
     </div>

 </div>