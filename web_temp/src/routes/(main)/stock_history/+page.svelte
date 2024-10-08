<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    // import DateNow from '$lib/DateNow';
    import { getFormattedDate, isInTimeRange } from '$lib/DateNow.js';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId } from '$lib/uri.js';
    import img_produk from "$lib/assets/produk.png";
    export let data;
    
    $: limit = 10; 
    $: offset = 0; 
    $: totalNotes = 10; 
    $: currentPage = 1; 

    $: endDate = '';
    $: startDate = '';
    $: searchQuery = '';
    $: searchQuery_temp = '';
    $: unit_type = '';
    $: category = '';
    $: reason = '';

    let showModal = null; 
    let showTable = false;
    let warehouse = [];
    let stock_history = [];
    let categories = [];
    let reasons = [];
    let showFilter = false;
    function toggleFilter() {
        showFilter = !showFilter;
    }
    $: if ((searchQuery_temp !== searchQuery) ){
        console.log(searchQuery);
        fetchStockHistory();
        searchQuery_temp = searchQuery;
    } else{
        searchQuery_temp = '';
    }
    async function goToPage(page) {
        if (page < 1 || page > Math.ceil(totalNotes / limit)) return;

        currentPage = page;
        offset = (currentPage - 1) * limit;
        await fetchStockHistory();
    }
    onMount(async () => {
        await fetchWarehouse();
        await fetchStockHistory();
        await fetchProductCategory();
        await fetchStockDescriptions();
    });
    async function fetchProductCategory() {
        const response = await fetch(`http://${$uri}:8888/products/category`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all current stock fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch current stock', data);
            return;
        }

        categories = [...data.data];  
        console.log(categories);
    }
    async function fetchStockDescriptions() {
        const response = await fetch(`http://${$uri}:8888/products/stock/card/description`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all current stock fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch current stock', data);
            return;
        }

        reasons = [...data.data];  
        console.log(reasons);
    }
    async function fetchWarehouse() {
        const response = await fetch(`http://${$uri}:8888/store_warehouses/${$userId}/${$roleId}/''/0/0`, {
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

        warehouse = data.data[0];  
        console.log(warehouse);
    }
    async function fetchStockHistory() {
        console.log(`http://${$uri}:8888/products/stock/card/product/store_warehouse/${warehouse.StoreWarehouses.store_warehouse_id}/${startDate}/${endDate}/${category}/${unit_type}/${reason}/${searchQuery}/${limit}/${offset}`);
        const response = await fetch(`http://${$uri}:8888/products/stock/card/product/store_warehouse/${warehouse.StoreWarehouses.store_warehouse_id}/${startDate}/${endDate}/${category}/${unit_type}/${reason}/${searchQuery}/${limit}/${offset}`, {
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

        stock_history = [...data.data];  
        console.log(stock_history);
    }
  </script>
  
   <div class="mt-[90px] mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Stock History</span>
      
    <label for="voice-search" class="sr-only">Search</label>
    <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
        <input 
       bind:value={searchQuery} 
       type="text" id="voice-search" 
       class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
         placeholder="Search stock history..."/>
        <button on:click={toggleFilter}
            type="button" 
            class="absolute inset-y-0 end-0 flex items-center pe-3 ">
            <i class="fa-solid fa-sliders fa-xl mr-2"></i>
        </button>
        {#if showFilter}
            <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-fit bg-gray-100 p-4 rounded-lg font-roboto">
            <span class="font-bold text-xl mb-1">Unit Type</span>
            <div class="grid grid-cols-4 flex w-full flex-wrap">
                <button on:click={() => {unit_type = (unit_type === '' || unit_type !== "unit") ? "unit" : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${unit_type === 'unit' ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Units</button>
                <button on:click={() => {unit_type = (unit_type === '' || unit_type !== "gram") ? "gram" : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${unit_type === 'gram' ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Grams</button>
            </div>
            <span class="font-bold text-xl mb-1">Product Category</span>
            <div class="grid grid-cols-4 flex w-full flex-wrap">
              {#each categories as cat}
                <button on:click={() => {category = (category === '' || category !== cat.product_category_id) ? cat.product_category_id : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:bg-white hover:border hover:border-peach2 hover:text-peach2 ${category === cat.product_category_id ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>{cat.product_category_name}</button>
              {/each}
            </div>
            <span class="font-bold text-xl mb-1">Reason</span>
            <div class="grid grid-cols-4 flex w-full flex-wrap">
              {#each reasons as r}
                <button on:click={() => {reason = (reason === '' || reason !== r.stock_description) ? r.stock_description : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:bg-white hover:border hover:border-peach2 hover:text-peach2 ${reason === r.stock_description ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>{r.stock_description}</button>
              {/each}
            </div>
            <div class="flex gap-x-4"> 
                <div>
                <span class="font-bold text-xl mb-1">Start Date</span>
                <div class="flex w-full flex-wrap">
                    <input type="date" bind:value={startDate} class="w-full mb-4 p-2 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] rounded" />
                </div>
                </div>
                <div>
                <span class="font-bold text-xl mb-1">End Date</span>
                <div class="flex w-full flex-wrap">
                    <input type="date" bind:value={endDate} class="w-full mb-4 p-2 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] rounded" />
                </div>
                </div>
            </div>
            <div class="flex justify-between font-semibold mt-4">
                <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { unit_type = ''; category = ''; reason = ''; endDate = ''; startDate = ''; }}>Clear</button>
                <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {fetchStockHistory(); toggleFilter()}}>Apply</button>
            </div>
            </div>
        {/if}
        </div>

        <nav class="my-8">
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
        <div class="w-11/12">
          <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
            <table class="w-full text-sm text-left rtl:text-right">
              <thead class="text-xs text-gray-700 uppercase bg-gray-100">
                <tr class="border-b-2 border-black">
                  <th scope="col" class="px-3 py-2 text-sm font-bold uppercase text-center">
                      No
                  </th>
                  <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                      Product Name
                  </th>
                  <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                      Batch
                  </th>
                  <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                      Expiry Date
                  </th>
                  <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                    In
                  </th>
                  <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                    Out
                  </th>
                  <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                    Unit Type
                  </th>
                  <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                    Reason
                  </th>
                  <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                    Date
                  </th>
                </tr>
              </thead>
              <tbody>
                {#each stock_history as stock, i}
                  <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                    <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                          {i+1+offset}
                    </th>
                    <td class="px-1 py-2 text-center">
                      {stock.product_name}
                    </td>
                    <td class="px-1 py-2 text-center">
                      {stock.product_batch}
                    </td>
                    <td class="px-1 py-2 text-center">
                      <DateConverter value={stock.expired_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                    </td>
                    <td class="px-1 py-2 text-center">
                      {stock.stock_in}
                    </td>
                    <td class="px-1 py-2 text-center">
                      {stock.stock_out}
                    </td>
                    <td class="px-1 py-2 text-center">
                      {stock.product_unit}
                    </td>
                    <td class="px-1 py-2 text-center">
                      {stock.stock_description}
                    </td>
                    <td class="px-1 py-2 text-center">
                      <DateConverter value={stock.stock_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                    </td>
                  </tr>
                {/each}
              </tbody>
            </table>
          </div>
        </div>
        
        <nav class="my-8">
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
       
   </div>
