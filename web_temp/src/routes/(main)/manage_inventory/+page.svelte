<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId } from '$lib/uri.js';
    import img_toko from "$lib/assets/store.png";
    
    let storeWarehouse = [];
    let filtered_sw = [];

    $: limit = 10; 
    $: offset = 0;
    $: currentPage = 1; 
    $: totalRows = 0;

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
        const response = await fetch(`http://${$uri}:8888/store_warehouses/${$userId}/${$roleId}`, {
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

        totalRows = data.data.length
        storeWarehouse = data.data;
        filtered_sw = structuredClone(storeWarehouse)
        console.log(storeWarehouse);
        
    }

    async function goToPage(page) {
        if (page < 1 || page > Math.ceil(totalRows / limit)) return;

        currentPage = page;
        offset = (currentPage - 1) * limit;
        await getAllStoreWarehouse()
    }

    $: if (searchQuery.length > 0) {
      filtered_sw = storeWarehouse.filter(item => 
            item.StoreWarehouses.store_warehouse_name.toLowerCase().includes(searchQuery.toLowerCase())
        );
    } else {
      filtered_sw = [...storeWarehouse];
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

      {#each filtered_sw as warehouse}
          {#if warehouse.StoreWarehouses.store_warehouse_type != "STORE"}
              <button on:click={() => navigateToWarehousePage(warehouse.StoreWarehouses.store_warehouse_id)} class="my-4 p-4 border-2 border-black rounded-xl w-11/12 hover:bg-gray-200">
                  <div class="flex">
                      <img class="w-32 rounded-xl mr-8 " src={img_toko} alt="">
                      <div class="w-10/12 flex flex-col items-start justify-center">
                          <span class="text-2xl font-semibold text-wrap my-1">{warehouse.StoreWarehouses.store_warehouse_name}</span>
                          <span class="text-2xl font-semibold text-wrap my-1 text-start">{warehouse.StoreWarehouses.store_warehouse_address}</span>
                      </div>
                  </div>
              </button>
          {/if}
      {/each}

  
      <nav class="my-8">
        <ul class="flex items-center -space-x-px h-8 text-sm">
          {#if totalRows !== 0}
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
          {#each Array(Math.ceil(totalRows / limit)) as _, i}
            <li>
              <a href="#" on:click|preventDefault={() => goToPage(i + 1)} class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">{i + 1}</a>
            </li>
          {/each}
      
          {#if totalRows !== 0}
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
       
   </div>