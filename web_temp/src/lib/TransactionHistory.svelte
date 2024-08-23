<script>
  import TaskModal from '$lib/TaskModal.svelte';
  import MoneyConverter from '$lib/MoneyConverter.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { getFormattedDate} from '$lib/DateNow.js';
  import { uri } from '$lib/uri.js';

  export let userId = 0;
  export let roleId = 0;
  export let sessionId = 0;
  console.log(sessionId);
  
  let showModal = false;
  let transactions = [];
  let searchQuery = '';
  let filteredTransactions = [];

  function closeModal() {
     showModal = false;
  }

  function handleClick() {
     showModal = true;
  }

  function navigateToTransaction(transactionId) {
      const url = `/transaction_history/${userId}/${roleId}/${transactionId}`;
      goto(url);
  }

  onMount(async () => {
    await fetchTransactions();
  });

  // Function to fetch all transactions or filter based on search
  async function fetchTransactions() {
      let response;

      if (sessionId === 0) {
          response = await fetch(`http://${$uri}:8888/transaction`, {
              method: 'GET',
              headers: {
                  'Content-Type': 'application/json'
              }
          });
      } else {
          response = await fetch(`http://${$uri}:8888/cashier/session/transaction/${sessionId}`, {
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

      transactions = data.data;
      filteredTransactions = transactions;
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
  $: if (searchQuery.length > 0 || endDate !== '' || startDate !== '')  {
    filteredTransactions = transactions.filter(item => {
      const matchesSearch = item.transaction_user.toLowerCase().includes(searchQuery.toLowerCase()) ||
                            item.transaction_id.toString().includes(searchQuery);
      const matchesDate = isDateWithinRange(item.transaction_timestamp); // Assuming `transaction_date` is the date field in your data

      return matchesSearch && matchesDate;
    });
  } else {
      filteredTransactions = transactions;  // Reset to show all transactions
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
            placeholder="Search..."/>
            <button 
            type="button" 
            class="absolute inset-y-0 end-0 flex items-center pe-3 " 
            on:click={toggleDatePicker}>
            <i class="fa-solid fa-sliders fa-xl mr-2"></i>
          </button>
          {#if showDatePicker}
            <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-64 bg-gray-100 p-4 rounded-lg font-roboto">
              <label class="block mb-2 font-semibold text-gray-700">Start Date</label>
              <input type="date" bind:value={startDate} class="w-full mb-4 p-2 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] rounded" />
              
              <label class="block mb-2 font-semibold text-gray-700">End Date</label>
              <input type="date" bind:value={endDate} class="w-full mb-4 p-2 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] rounded" />
              
              <div class="flex justify-between font-semibold">
                <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { startDate = ''; endDate = ''; }}>Clear</button>
                <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={toggleDatePicker}>Apply</button>
              </div>
            </div>
          {/if}
       </div>
    <!-- </form> -->
    
    <nav class="my-8 ">
       <ul class="flex items-center -space-x-px h-8 text-sm">
         <li>
           <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
             <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
              </svg>
             Previous
           </a>
         </li>
 
         <li>
           <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">1</a>
         </li>
         <li>
           <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">2</a>
         </li>
         <li>
           <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">3</a>
         </li>
         <li>
           <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg ">...</a>
         </li>
         <li>
           <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">67</a>
         </li>
         <li>
           <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">68</a>
         </li>
        
         <li>
           <a href="#" class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
             Next
             <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
              </svg>
           </a>
         </li>
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
                              <DateConverter value={transaction.transaction_timestamp} date={true} />
                          </td>
                          <td class="px-6 py-4">
                              <DateConverter value={transaction.transaction_timestamp} date={false} hour={true} ampm={true} />
                          </td>
                          <td class="px-6 py-4">
                              <MoneyConverter value={transaction.transaction_total_price} currency={true} decimal={true}></MoneyConverter>
                          </td>
                          <td class="px-6 py-4">{transaction.transaction_user}</td>
                          <td class="py-2">
                              <button class="py-2.5 border border-darkGray bg-peach rounded-lg font-bold text-darkGray w-full" on:click={() => navigateToTransaction(transaction.transaction_id)}>View</button>
                          </td>  
                      </tr>
                      {/each}
                  {/if}
              </tbody>
          </table>
      </div>
  </div>

     <nav class="my-8 ">
        <ul class="flex items-center -space-x-px h-8 text-sm">
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
              <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                 <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
               </svg>
              Previous
            </a>
          </li>
  
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">1</a>
          </li>
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">2</a>
          </li>
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">3</a>
          </li>
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg ">...</a>
          </li>
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">67</a>
          </li>
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">68</a>
          </li>
         
          <li>
            <a href="#" class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
              Next
              <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                 <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
               </svg>
            </a>
          </li>
        </ul>
      </nav>
     
 </div>