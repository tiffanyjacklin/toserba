<script>
  import TaskModal from '$lib/TaskModal.svelte';
  import MoneyInput from '$lib/MoneyInput.svelte';
  import MoneyConverter from '$lib/MoneyConverter.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { getFormattedDate} from '$lib/DateNow.js';
  import { uri, userId, roleId, sessionId, transactionId } from '$lib/uri.js';
  console.log("sessionId", $sessionId);

  import { loading } from '$lib/loading';

  export let session_main_or_not = false;
  $: limit = 10; 
  $: offset = 0; 
  $: totalNotes = 10; 
  $: currentPage = 1; 
  $: totalPages = Math.ceil(totalNotes/limit);

  $: endDate = '';
  $: startDate = '';
  $: endPrice = 999999999;
  $: startPrice = 0;

  $: searchQuery = '';
  $: searchQuery_temp = '';
  let showFilter = false;

  function toggleFilter() {
    showFilter = !showFilter;
  }
  let showModal = false;
  let transactions = [];
  let searchQuery = '';
  let filteredTransactions = [];
  let cashiers = [];
  let cashier_name = '';

  function closeModal() {
     showModal = false;
  }

  function handleClick() {
     showModal = true;
  }

  function navigateToTransaction(transactionIdnya) {
    transactionId.set(transactionIdnya);
    if (session_main_or_not) {
        goto(`session_main`);
    } else {
        const url = `/transaction_history/${transactionIdnya}`;
        goto(url);    
    }
  }
  async function goToPage(page) {
    $loading = true;
    if (page < 1 || page > Math.ceil(totalNotes / limit)) return;

    currentPage = page;
    offset = (currentPage - 1) * limit;
    await fetchTransactions();
    $loading = false;
  }
  $: if ((searchQuery_temp !== searchQuery) ){
    console.log(searchQuery);
    fetchTransactions();
    searchQuery_temp = searchQuery;
  } else{
    searchQuery_temp = '';
  }
  onMount(async () => {
    $loading = true;
    await fetchTransactions();
    await fetchCashiers();
    $loading = false;
  });
  async function fetchCashiers() {
      const response = await fetch(`http://${$uri}:8888/user/roles/data/1`, {
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

      cashiers = data.data;
   //   console.log(session);
   }
  // Function to fetch all transactions or filter based on search
  async function fetchTransactions() {
      let response;
      console.log($sessionId);

      if ($sessionId === String(0) || $sessionId === '') {
          response = await fetch(`http://${$uri}:8888/transaction/${startDate}/${endDate}/${cashier_name}/${startPrice}/${endPrice}/${searchQuery}/${limit}/${offset}`, {
              method: 'GET',
              headers: {
                  'Content-Type': 'application/json'
              }
          });
      } else {
          response = await fetch(`http://${$uri}:8888/cashier/session/transaction/${$sessionId}/${startDate}/${endDate}/${cashier_name}/${startPrice}/${endPrice}/${searchQuery}/${limit}/${offset}`, {
              method: 'GET',
              headers: {
                  'Content-Type': 'application/json'
              }
          });
      }

      if (!response.ok) {
          console.error('get all transactions fetch failed', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid fetch transactions', data);
          return;
      }
      totalNotes = data.total_rows;
      totalPages = Math.ceil(totalNotes/limit);
      transactions = data.data;
      filteredTransactions = transactions;
      // console.log(filteredTransactions);
  }
  function isDateWithinRange(transactionDate) {
    const date = new Date(transactionDate);
    const start = startDate ? new Date(startDate) : null;
    const end = endDate ? new Date(endDate) : null;
    const todayDate = new Date(today);
    if (start && end && start.getDate() === end.getDate()) {
      return date.getDate() === start.getDate();
    }
    if (start && end) {
      return date.getDate() >= start.getDate() && date.getDate() <= end.getDate();
    }
    // If only startDate is provided
    if (start) {
      return date.getDate() >= start.getDate();
    }
    // If only endDate is provided
    if (end) {
      return date.getDate() <= end.getDate();
    } 
    else {
      return true;
    }
  }
  let showDatePicker = false;
  let startDate = '';
  let endDate = '';
  let today = getFormattedDate();
  function toggleDatePicker() {
    showDatePicker = !showDatePicker;
  }
</script>

 <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Transaction History</span>
    
    <!-- <form class="flex items-center max-w-lg mx-auto">    -->
       <label for="voice-search" class="sr-only">Search</label>
       <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
        <input 
            type="text" 
            id="voice-search" 
            bind:value={searchQuery}
            class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
            placeholder="Search by Transaction ID or Cashier's name..."/>
            <button on:click={toggleFilter}
                type="button" 
                class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                <i class="fa-solid fa-sliders fa-xl mr-2"></i>
            </button>
            {#if showFilter}
                <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-fit  bg-gray-100 p-4 rounded-lg font-roboto">
                  <span class="font-bold text-xl mb-1">Time Period</span>

                  <div class="flex gap-x-4 w-full items-center">
                    <span class="font-semibold text-lg mb-4">From</span>
                    <input type="date" bind:value={startDate} class="rounded-xl w-32 mb-4 p-2 border" />
                    <span class="font-semibold text-lg mb-4">To</span>
                    <input type="date" bind:value={endDate} class="rounded-xl w-32 mb-4 p-2 border" />
                  </div>
                  {#if (String($sessionId) === String('') || String($sessionId) === String(0))}
                    <span class="font-bold text-xl mb-1">Cashier</span>
                    <div class="flex gap-x-4 w-full items-center">
                      {#each cashiers as cashier}
                        <button on:click={() => {cashier_name = (cashier_name === '' || cashier_name !== cashier.user_id) ? cashier.user_id : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:bg-white hover:border hover:border-peach2 hover:text-peach2 ${cashier_name === cashier.user_id ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>{cashier.user_fullname}</button>
                      {/each}
                    </div>
                  {/if}
                  <span class="font-bold text-xl mb-4">Price Range</span>
                  <div class="flex gap-x-4 w-full items-center mt-2">
                    <span class="font-semibold text-lg ">From</span>
                    <MoneyInput bind:value={startPrice} shadow={false}/>
                    <span class="font-semibold text-lg ">To</span>
                    <MoneyInput bind:value={endPrice} shadow={false}/>
                  </div>

                  <div class="flex justify-between font-semibold mt-4">
                      <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { startDate = ""; endDate = ""; cashier_name = ""; startPrice = 0; endPrice = 999999999;}}>Clear</button>
                      <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {fetchTransactions(); showFilter = false; currentPage = 1;}}>Apply</button>
                  </div>
                </div>
            {/if}
       </div>
    <!-- </form> -->
    
   
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
                      <th scope="col" class="px-6 py-3 text-sm font-bold">TRANSACTION ID</th>
                      <th scope="col" class="px-6 py-3 text-sm font-bold">DATE</th>
                      <th scope="col" class="px-6 py-3 text-sm font-bold">TIME</th>
                      <th scope="col" class="px-6 py-3 text-sm font-bold">TOTAL</th>
                      <th scope="col" class="px-6 py-3 text-sm font-bold">RESPONSIBLE PERSON</th>
                      <th scope="col" class="px-6 py-3 text-sm font-bold">DETAIL</th>
                  </tr>
              </thead>
              <tbody>
                  {#if filteredTransactions.length === 0}
                      <tr>
                          <td colspan="6" class="text-center py-4">No transactions found.</td>
                      </tr>
                  {:else}
                      {#each filteredTransactions as transaction, i}
                      <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                          <th scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">{transaction.transaction_id}</th>
                          <td class="px-6 py-4">
                              <DateConverter value={transaction.transaction_timestamp} date={true} hour={false} dash={false} monthNumber={true}/>
                          </td>
                          <td class="px-6 py-4">
                              <DateConverter value={transaction.transaction_timestamp} date={false} hour={true} ampm={true} second={false} />
                          </td>
                          <td class="px-6 py-4">
                              <MoneyConverter value={transaction.transaction_total_price} currency={true} decimal={true}></MoneyConverter>
                          </td>
                          <td class="px-6 py-4">{transaction.transaction_user}</td>
                          <td class="py-2">
                              <button class="py-2.5 border border-darkGray bg-peach rounded-lg font-bold text-darkGray w-full" on:click={() => {console.log(transaction.transaction_id); navigateToTransaction(transaction.transaction_id);} }>View</button>
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