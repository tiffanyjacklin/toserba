<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import { onMount } from 'svelte';
    import { uri, userId, roleId } from '$lib/uri.js';

    import { goto } from '$app/navigation';
    
    let members = [];
    let search_phone_number = "";
    onMount(async () => {
        fetchMembers();
    });
    async function fetchMembers() {
        const response = await fetch(`http://${$uri}:8888/cashier/members`, {
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

        members = data.data;
    }
    let searchActive = false;

    // Function to fetch member by phone number
    async function fetchPhoneNumber(search_phone_number) {
        try {
            const response = await fetch(`http://${$uri}:8888/cashier/members/phone_number/${search_phone_number}`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            });

            if (!response.ok) {
                throw new Error('Failed to fetch member data');
            }

            const data = await response.json();

            if (data.status !== 200 || !data.data) {
                return null;
            }

            return data.data;
        } catch (error) {
            console.error('Fetch error:', error);
            return null;
        }
    }

    // Function to check and display member data based on search input
    async function checkPhoneNumber() {
        searchActive = true;
        const memberData = await fetchPhoneNumber(search_phone_number);

        if (!memberData) {
            // No member found
            members = [];
        } else {
            // Member found
            members = [memberData];
        }
    }
    async function handleSearch(event) {
        if (event.key === 'Enter') {
            await checkPhoneNumber();
        }
    }
    // Watch the search input for changes and call checkPhoneNumber when needed
    $: if (search_phone_number.length === 0) {
        fetchMembers();
    } 
 </script>
 
 <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Subtract Products</span>
    
     <div class="w-[96%] my-5">
        
        <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
            <table class="w-full text-sm text-left rtl:text-right">
                <thead class="text-xs text-gray-700 uppercase bg-gray-5">
                    <tr class="border-b-2 border-black">
                        <th scope="col" class="px-6 py-3 text-sm font-bold">
                            ID
                        </th>
                        <th scope="col" class="px-6 py-3 text-sm font-bold">
                            NAME
                        </th>
                        <th scope="col" class="px-6 py-3 text-sm font-bold">
                            PHONE NUMBER
                        </th>
                        <th scope="col" class="px-6 py-3 text-sm font-bold">
                            POINTS
                        </th>
                        <th scope="col" class="px-6 py-3 text-sm font-bold">
                            JOIN DATE
                        </th>
                    </tr>
                </thead>
                <tbody>
                    {#if searchActive && members.length === 0}
                        <tr>
                            <td colspan="5" class="text-center py-4">No member found.</td>
                        </tr>
                    {:else}
                        {#each members as member, i}

                        <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                            <th scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">
                                {member.member_id}
                            </th>
                            <td class="px-6 py-4">
                                {member.member_name}
                            </td>
                            <td class="px-6 py-4">
                                {member.member_phone_number}
                            </td>
                            <td class="px-6 py-4">
                                {member.member_points}
                            </td>
                            <td class="px-6 py-4">
                                <DateConverter value={member.member_join_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                            </td>
                        </tr>
                        {/each}
                    {/if}
                </tbody>
            </table>
        </div>
     </div>

     
 </div>