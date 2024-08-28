<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId } from '$lib/uri.js';
    import img_toko from "$lib/assets/store.png";
  
    // export let userId = 0;
    // export let roleId = 0;
    // export let sessionId = 0;
    // console.log(sessionId);
    
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
        const url = `/transaction_history/${transactionId}`;
        goto(url);
    }
  
    onMount(async () => {
      await fetchTransactions();
    });
  
    // Function to fetch all transactions or filter based on search
    async function fetchTransactions() {
        let response;
        console.log($sessionId);
  
        if ($sessionId === String(0) || $sessionId === '') {
            response = await fetch(`http://${$uri}:8888/transaction`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        } else {
            
            response = await fetch(`http://${$uri}:8888/cashier/session/transaction/${$sessionId}`, {
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
        console.log(filteredTransactions);
    }

  </script>
  
   <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
      <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Inventory</span>
      
      <!-- <form class="flex items-center max-w-lg mx-auto">    -->
         <label for="voice-search" class="sr-only">Search</label>
         <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
          <input 
              type="text" 
              id="voice-search" 
              bind:value={searchQuery}
              class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
              placeholder="Search..."/>
         </div>
      <!-- </form> -->

        <button class="my-4 mt-8 p-4 border-2 border-black rounded-xl w-11/12">
            <div class="flex">
                <div class="w-2/12">
                    <img class="w-32 rounded-xl" src={img_toko} alt="">
                </div>
                <div class="w-10/12 ml-8 flex flex-col items-start justify-center">
                    <span class="text-xl font-semibold text-wrap">Store Toserba XYZ</span>
                    <span class="text-xl font-semibold text-wrap">Jl. Jenderal Basuki Rachmat No.8-12, Kedungdoro, Kec. Tegalsari, Surabaya, Jawa Timur 60261</span>
                </div>
            </div>
        </button>

  
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