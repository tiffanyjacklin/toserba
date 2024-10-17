<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import { onMount } from 'svelte';
    import { uri, userId, roleId } from '$lib/uri.js';
    import { goto } from '$app/navigation';
    $: limit = 10; 
    $: offset = 0; 
    $: totalNotes = 10; 
    $: currentPage = 1; 
    $: totalPages = Math.ceil(totalNotes/limit);
    let members = [];

    $: endDate = '';
    $: startDate = '';

    $: searchQuery = '';
    $: searchQuery_temp = '';
    let showFilter = false;

    function toggleFilter() {
        showFilter = !showFilter;
    }

    onMount(async () => {
        fetchMembers();
    });
    async function fetchMembers() {
        const response = await fetch(`http://${$uri}:8888/cashier/members/${startDate}/${endDate}/${searchQuery}/${limit}/${offset}`, {
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
        totalNotes = data.total_rows;
        totalPages = Math.ceil(totalNotes/limit);
        members = data.data;
    }

    $: if ((searchQuery_temp !== searchQuery) ){
      console.log(searchQuery);
      fetchMembers();
      searchQuery_temp = searchQuery;
    } else{
      searchQuery_temp = '';
    }
    async function goToPage(page) {
      if (page < 1 || page > Math.ceil(totalNotes / limit)) return;

      currentPage = page;
      offset = (currentPage - 1) * limit;
      await fetchMembers();
    }


 </script>
 
 <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Members</span>
    <div class="w-11/12 flex items-center">
      <div class="relative w-full  shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg mr-4">
          <input 
              type="text" 
              id="voice-search" 
              bind:value={searchQuery}
              class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
              placeholder="Search member's name or phone number..."/>
          <button on:click={toggleFilter}
              type="button" 
              class="absolute inset-y-0 end-0 flex items-center pe-3 ">
              <i class="fa-solid fa-sliders fa-xl mr-2"></i>
          </button>
          {#if showFilter}
              <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-2/5 bg-gray-100 p-4 rounded-lg font-roboto">
                <span class="font-bold text-xl mb-1">Join Date Period</span>

                <div class="flex gap-x-4 w-full items-center">
                  <span class="font-semibold text-lg mb-4">From</span>
                  <input type="date" bind:value={startDate} class="rounded-xl w-32 mb-4 p-2 border" />
                  <span class="font-semibold text-lg mb-4">To</span>
                  <input type="date" bind:value={endDate} class="rounded-xl w-32 mb-4 p-2 border" />
                </div>
                
                <div class="flex justify-between font-semibold mt-4">
                    <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { startDate = ""; endDate = ""; }}>Clear</button>
                    <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {fetchMembers(); showFilter = false;  currentPage = 1;}}>Apply</button>
                </div>
              </div>
          {/if}
      </div>
    </div>
      
 
   
  <nav class="my-8 flex justify-center">
      <ul class="flex items-center -space-x-px h-8 text-sm">
      {#if totalNotes !== 0}
      <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="{currentPage === 1 ? 'opacity-50 cursor-not-allowed' : 'hover:text-white hover:bg-black'} mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
          <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
          </svg>
          Previous
          </a>
      </li>
      {/if}
  
      {#if totalPages <= 5}
          {#each Array(totalPages) as _, i}
          <li>
              <a 
                  href="#" 
                  on:click|preventDefault={() => goToPage(i + 1)} 
                  class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                      {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                  {i + 1}
              </a>
          </li>
          {/each}
      {:else}
          {#if currentPage > 3}
          <li>
              <a 
                  href="#" 
                  on:click|preventDefault={() => goToPage(1)} 
                  class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                  1
              </a>
          </li>
          <li class="mx-1 flex items-center justify-center px-3 h-8">...</li>
          {/if}

          {#each Array(5) as _, index}
              {#if currentPage <= 3}
                  {#if index < 5 && index < totalPages}
                  <li>
                      <a 
                          href="#" 
                          on:click|preventDefault={() => goToPage(index + 1)} 
                          class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                              {currentPage === index + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                          {index + 1}
                      </a>
                  </li>
                  {/if}
              {:else if currentPage >= totalPages - 2}
                  {#if index + totalPages - 5 >= 0}
                  <li>
                      <a 
                          href="#" 
                          on:click|preventDefault={() => goToPage(index + totalPages - 5 + 1)} 
                          class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                              {currentPage === index + totalPages - 5 + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                          {index + totalPages - 5 + 1}
                      </a>
                  </li>
                  {/if}
              {:else}
                  {#if index + currentPage - 2 >= 0 && index + currentPage - 2 < totalPages}
                  <li>
                      <a 
                          href="#" 
                          on:click|preventDefault={() => goToPage(index + currentPage - 2)} 
                          class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                              {currentPage === index + currentPage - 2 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                          {index + currentPage - 2}
                      </a>
                  </li>
                  {/if}
              {/if}
          {/each}

          {#if currentPage < totalPages - 2}
          <li class="mx-1 flex items-center justify-center px-3 h-8">...</li>
          <li>
              <a 
                  href="#" 
                  on:click|preventDefault={() => goToPage(totalPages)} 
                  class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                  {totalPages}
              </a>
          </li>
          {/if}
      {/if}

      {#if totalNotes !== 0}
      <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="{currentPage === (Math.ceil(totalNotes / limit)) ? 'opacity-50 cursor-not-allowed' : 'hover:text-white hover:bg-black'} flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
          Next
          <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
          </svg>
          </a>
      </li>
      {/if}
      </ul>
  </nav>
 
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
                {#if members.length === 0}
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

     
  <nav class="my-8 flex justify-center">
      <ul class="flex items-center -space-x-px h-8 text-sm">
      {#if totalNotes !== 0}
      <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="{currentPage === 1 ? 'opacity-50 cursor-not-allowed' : 'hover:text-white hover:bg-black'} mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
          <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
          </svg>
          Previous
          </a>
      </li>
      {/if}
  
      {#if totalPages <= 5}
          {#each Array(totalPages) as _, i}
          <li>
              <a 
                  href="#" 
                  on:click|preventDefault={() => goToPage(i + 1)} 
                  class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                      {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                  {i + 1}
              </a>
          </li>
          {/each}
      {:else}
          {#if currentPage > 3}
          <li>
              <a 
                  href="#" 
                  on:click|preventDefault={() => goToPage(1)} 
                  class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                  1
              </a>
          </li>
          <li class="mx-1 flex items-center justify-center px-3 h-8">...</li>
          {/if}

          {#each Array(5) as _, index}
              {#if currentPage <= 3}
                  {#if index < 5 && index < totalPages}
                  <li>
                      <a 
                          href="#" 
                          on:click|preventDefault={() => goToPage(index + 1)} 
                          class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                              {currentPage === index + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                          {index + 1}
                      </a>
                  </li>
                  {/if}
              {:else if currentPage >= totalPages - 2}
                  {#if index + totalPages - 5 >= 0}
                  <li>
                      <a 
                          href="#" 
                          on:click|preventDefault={() => goToPage(index + totalPages - 5 + 1)} 
                          class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                              {currentPage === index + totalPages - 5 + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                          {index + totalPages - 5 + 1}
                      </a>
                  </li>
                  {/if}
              {:else}
                  {#if index + currentPage - 2 >= 0 && index + currentPage - 2 < totalPages}
                  <li>
                      <a 
                          href="#" 
                          on:click|preventDefault={() => goToPage(index + currentPage - 2)} 
                          class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                              {currentPage === index + currentPage - 2 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                          {index + currentPage - 2}
                      </a>
                  </li>
                  {/if}
              {/if}
          {/each}

          {#if currentPage < totalPages - 2}
          <li class="mx-1 flex items-center justify-center px-3 h-8">...</li>
          <li>
              <a 
                  href="#" 
                  on:click|preventDefault={() => goToPage(totalPages)} 
                  class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                  {totalPages}
              </a>
          </li>
          {/if}
      {/if}

      {#if totalNotes !== 0}
      <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="{currentPage === (Math.ceil(totalNotes / limit)) ? 'opacity-50 cursor-not-allowed' : 'hover:text-white hover:bg-black'} flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
          Next
          <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
          </svg>
          </a>
      </li>
      {/if}
      </ul>
  </nav>
     
 </div>