<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId } from '$lib/uri.js';
    import img_toko from "$lib/assets/store.png";
    
    let storeWarehouse = [];

    let showModal = false;
    let searchQuery = '';
  
    function closeModal() {
       showModal = false;
    }
  
    function handleClick() {
       showModal = true;
    }
  
    function navigateToWarehousePage(store_warehouse_id) {
        const url = `/manage_inventory/${store_warehouse_id}`;
        goto(url);
    }
  
    onMount(async () => {
      await getAllStoreWarehouse();
    });
  
    async function getAllStoreWarehouse(){
        const response = await fetch(`http://${$uri}:8888/store_warehouses/all`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch store warehouse failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch promo', data);
            return;
        }

        storeWarehouse = data.data;
        console.log(storeWarehouse);
        
    }

  </script>
  
   <div class="mt-[90px] mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
      <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Inventory</span>
      
      <!-- <form class="flex items-center max-w-lg mx-auto">    -->
         <label for="voice-search" class="sr-only">Search</label>
         <div class="mb-4 relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
          <input 
              type="text" 
              id="voice-search" 
              bind:value={searchQuery}
              class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
              placeholder="Search..."/>
         </div>
      <!-- </form> -->

      {#each storeWarehouse as warehouse}
          {#if warehouse.store_warehouse_type != "STORE"}
              <button on:click={() => navigateToWarehousePage(warehouse.store_warehouse_id)} class="my-4 p-4 border-2 border-black rounded-xl w-11/12 hover:bg-gray-200">
                  <div class="flex">
                      <img class="w-32 rounded-xl mr-8 " src={img_toko} alt="">
                      <div class="w-10/12 flex flex-col items-start justify-center">
                          <span class="text-2xl font-semibold text-wrap my-1">{warehouse.store_warehouse_name}</span>
                          <span class="text-2xl font-semibold text-wrap my-1 text-start">{warehouse.store_warehouse_address}</span>
                      </div>
                  </div>
              </button>
          {/if}
      {/each}

  
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