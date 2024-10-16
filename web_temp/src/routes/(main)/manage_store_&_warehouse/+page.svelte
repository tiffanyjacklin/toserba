<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { getFormattedDate, isInTimeRange, formatDate } from '$lib/DateNow.js';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId } from '$lib/uri.js';
    import supermarket from "$lib/assets/supermarket.jpg";
    $: limit = 10; 
    $: offset = 0; 
    $: totalNotes = 10; 
    $: currentPage = 1; 
    $: totalPages = Math.ceil(totalNotes/limit);

    $: searchQuery = '';
    $: searchQuery_temp = '';
    $: tampilan = 'View';
    $: showModal = null;
    $: id_modal = null;
    $: sw_name = '';
    $: sw_type = '';
    $: sw_name_address = '';
    $: phone_number = '';
    $: address = '';

    
    let store_warehouses = [];
    let all_store_warehouses = [];
    let handled_store = [];
    $: sw_specific = [];
    $: sw_specific_temp = [];
    let showFilter = false;
    $: provinces = [];
    $: province = '';
    $: province_id = '';
    $: province_name = '';
    $: province_name_temp = '';
    $: cities = [];
    $: city = '';
    $: city_name = '';
    $: city_name_temp = '';
    $: location_idnya = '';
    $: location = [];
    let showProvince = false;
    let showCity = false;

    function toggleFilter() {
        showFilter = !showFilter;
    }
    function handleClick(sessionId) {
        showModal = sessionId;
    }
    function closeModal() {
          showModal = null;
          sw_specific = [];
          sw_specific_temp = [];

    }
    async function selectProvince(province){
      province_name = province.province;
      province_id = province.location_id;
      city_name = '';
      location_idnya = '';      
      await fetchCity();
      showProvince = false;
    }
    function selectCity(city){
      city_name = city.city;
      location_idnya = city.location_id;
      showCity = false;
    }
    async function fetchSpecificSW(idNya){
          const response = await fetch(`http://${$uri}:8888/store_warehouses/${idNya}`, {
              method: 'GET',
              headers: {
                  'Content-Type': 'application/json'
              }
          });

          if (!response.ok) {
              console.error('fetch all promo failed', response);
              return;
          }

          const data = await response.json();

          if (data.status !== 200) {
              console.error('Invalid fetch all promo', data);
              return;
          }

          sw_specific = data.data;
          sw_specific_temp = { ...sw_specific };
          console.log(sw_specific);
          console.log(sw_specific_temp);
          sw_specific.store_warehouse_type = sw_specific.store_warehouse_type.charAt(0).toUpperCase() + sw_specific.store_warehouse_type.slice(1).toLowerCase();
          await fetchLocation(sw_specific.location_id);
    }
  
    onMount(async () => {
      await fetchStoreWarehouse();
    });
    $: if ((searchQuery_temp !== searchQuery) ){
      console.log(searchQuery);
      fetchStoreWarehouse();
      searchQuery_temp = searchQuery;
    } else{
      searchQuery_temp = '';
    }
    $: if ((province_name_temp !== province_name) ){
      console.log(province_name);
      console.log(province_name_temp);
      fetchProvince();
      province_name_temp = province_name;
    } else{
      province_name_temp = '';
    }
    $: if ((city_name_temp !== city_name) ){
      console.log(city_name);
      console.log(city_name_temp);
      fetchCity();
      city_name_temp = city_name;
    } else{
      city_name_temp = '';
    }
    async function fetchProvince() {
        const response = await fetch(`http://${$uri}:8888/locations/province/all/${province_name}/0/0`, {
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

        provinces = [...data.data];  
    }
    $: uricity = '';
    async function fetchCity() {
        const response = await fetch(`http://${$uri}:8888/locations/cities/all/${province_id}/${city_name}/0/0`, {
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

        cities = [...data.data];  
    }
    async function fetchLocation(id) {
        const response = await fetch(`http://${$uri}:8888/locations/${id}`, {
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

        location = data.data;  
        console.log(location);
    }

    async function fetchStoreWarehouse() {
    
      const response = await fetch(`http://${$uri}:8888/store_warehouses/type/${sw_type}/${searchQuery}/${limit}/${offset}`, {
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

      store_warehouses = [...data.data];  
      all_store_warehouses = [...store_warehouses];
      totalNotes = data.total_rows;
      totalPages = Math.ceil(totalNotes/limit);
      console.log(all_store_warehouses);
      
    }
    async function addSW(store_warehouse_type){
      const response = await fetch(`http://${$uri}:8888/store_warehouses/add`, {
        method: 'POST',
        body: JSON.stringify({
          store_warehouse_type: store_warehouse_type,
          store_warehouse_name: sw_name,
          store_warehouse_address: address,
          store_warehouse_phone_number: phone_number,
          location_id: location_idnya
        }),
        headers: {
          'Content-Type': 'application/json'
        }
      });
  
      if (!response.ok) {
        console.error('POST store_warehouses gagal', response);
        return;
      }
  
      const data = await response.json();
  
      if (data.status !== 200) {
        console.error('Invalid post store_warehouses', data);
        return;
      }
      console.log("insert store_warehouses detail",data);
      closeModal();
      sw_type = '';
      sw_name = '';
      phone_number = '';
      address = '';
      await fetchStoreWarehouse();
    }
    async function editSW(store_warehouse_specific){
      console.log(`http://${$uri}:8888/store_warehouses/edit/${store_warehouse_specific.store_warehouse_id}`);
      console.log(store_warehouse_specific.store_warehouse_name);
      console.log(store_warehouse_specific.store_warehouse_address);
      console.log(store_warehouse_specific.store_warehouse_phone_number);
      console.log(location_idnya);
      const response = await fetch(`http://${$uri}:8888/store_warehouses/edit/${store_warehouse_specific.store_warehouse_id}`, {
        method: 'PUT',
        body: JSON.stringify({
          store_warehouse_name: store_warehouse_specific.store_warehouse_name,
          store_warehouse_address: store_warehouse_specific.store_warehouse_address,
          store_warehouse_phone_number: store_warehouse_specific.store_warehouse_phone_number,
          location_id: location_idnya
        }),
        headers: {
          'Content-Type': 'application/json'
        }
      });
  
      if (!response.ok) {
        console.error('PUT store_warehouses gagal', response);
        return;
      }
  
      const data = await response.json();
  
      if (data.status !== 200) {
        console.error('Invalid PUT store_warehouses', data);
        return;
      }
      console.log("update store_warehouses detail",data);
      closeModal();
      sw_name = '';
      phone_number = '';
      address = '';
      await fetchStoreWarehouse();
    }
    function toggleProvince() {
      showProvince = !showProvince;
    }
    function toggleCity() {
      showCity = !showCity;
    }
    // $: if (province !== '' && city !== '') {
    //   showProvince = false;
    //   showCity = false;
    // }
    async function goToPage(page) {
      if (page < 1 || page > Math.ceil(totalNotes / limit)) return;

      currentPage = page;
      offset = (currentPage - 1) * limit;
      await fetchStoreWarehouse();
    }
  </script>
  
   <div class="mx-8 font-roboto mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Store & Warehouse</span>
      <!-- <div class="w-11/12 mb-8">
        <div class="grid grid-cols-4 gap-x-2 gap-y-4">
          <button 
            on:click={() => { tampilan = "view"; }} class={`font-medium text-xl w-56 py-2 rounded-3xl border-2 border-darkGray ${tampilan === "view" ? "bg-peach2 text-darkGray": "bg-darkGray text-white"}`}>
            View Store & Warehouse
          </button>
          <button 
            on:click={() => { handleClick("add new store"); }} class={`font-medium text-xl w-56 py-2 rounded-3xl border-2 border-darkGray ${showModal === "add new store" ? "bg-peach2 text-darkGray": "bg-darkGray text-white"}`}>
            Add New Store
          </button>
          <button 
            on:click={() => { handleClick("add new warehouse"); }} class={`font-medium text-xl w-56 py-2 rounded-3xl border-2 border-darkGray ${showModal === "add new warehouse" ? "bg-peach2 text-darkGray": "bg-darkGray text-white"}`}>
            Add New Warehouse
          </button>
          <button 
            on:click={() => { tampilan = "Edit"; }} class={`font-medium text-xl w-56 py-2 rounded-3xl border-2 border-darkGray ${tampilan === "Edit" ? "bg-peach2 text-darkGray": "bg-darkGray text-white"}`}>
            Edit Store & Warehouse
          </button>
        </div>
      </div> -->

        <div class="w-11/12 flex items-center">
            <div class="relative w-full  shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg mr-4">
                <input 
                    type="text" 
                    id="voice-search" 
                    bind:value={searchQuery}
                    class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                    placeholder="Search for a store or warehouse by store or warehouse name or address..."/>
                <button on:click={toggleFilter}
                    type="button" 
                    class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                    <i class="fa-solid fa-sliders fa-xl mr-2"></i>
                </button>
                {#if showFilter}
                    <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-2/5 bg-gray-100 p-4 rounded-lg font-roboto">
                      <span class="font-bold text-xl mb-1">Location Type</span>
                      <div class="flex w-full flex-wrap">
                          <button class={`w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:border-peach2 hover:text-peach ${sw_type === 'store' ? 'bg-white text-peach2' : 'bg-gray-100'}`} on:click={() => {sw_type = (sw_type === '' || sw_type !== "store") ? "store" : '';}}>Store</button>
                          <button class={`w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:border-peach2 hover:text-peach ${sw_type === 'warehouse' ? 'bg-white text-peach2' : 'bg-gray-100'}`} on:click={() => {sw_type = (sw_type === '' || sw_type !== "warehouse") ? "warehouse" : '';}}>Warehouse</button>
                      </div>
                      
                      
                      <div class="flex justify-between font-semibold mt-4">
                          <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { sw_type = ""; }}>Clear</button>
                          <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {fetchStoreWarehouse(); showFilter = false;}}>Apply</button>
                      </div>
                    </div>
                {/if}
            </div>
            <div class="relative w-3/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-xl">
              <button on:click={async () => {showModal = "add new"; await fetchProvince(); province_name = ''; city_name = ''; sw_name = ''; sw_type = ''; address = ''; phone_number = '';}} class="w-full py-4 rounded-xl bg-peach font-semibold text-lg text-darkGray border-2 border-darkGray"><i class="fa-solid fa-plus mr-2"></i>Add New Location</button>
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

      <div class="w-[96%] my-5 font-roboto">
        <div class="relative overflow-x-auto sm:rounded-lg">
          {#each all_store_warehouses as sw}
          <button class="w-full h-full flex border-2 rounded-xl ml-auto border-gray-700 my-3 hover:bg-gray-200" type="button"
            on:click={() => {fetchSpecificSW(sw.store_warehouse_id); handleClick(sw.store_warehouse_id); tampilan = 'View';}}>                        
            <div class="m-4 w-1/12 flex items-center">
              <img class="rounded-lg aspect-square" src={supermarket} alt="">
            </div>
            <div class="py-4 w-11/12">
              <div class="font-bold justify-start whitespace-nowrap flex">
                  <div class="">{sw.store_warehouse_type}</div>
                  <div class="capitalize mx-1">{sw.store_warehouse_name}</div>
                </div>
                <div class="font-semibold flex justify-start">
                  {sw.store_warehouse_address}
                </div>
            </div>
          </button>
          {/each}
          {#if all_store_warehouses.length === 0}
          <div class="justify-center w-full h-full flex border-2 rounded-xl py-4 border-gray-400 my-3 ">
            No Store or Warehouse found.
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
       
   </div>

   <!-- ADD NEW EMPLOYEE -->
{#if showModal === "add new" }
<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Add New Location</div>
  </div>
  <div class="flex flex-col justify-center p-8 font-roboto text-lg font-semibold">
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Location Name</span>
      <input type="text" bind:value={sw_name} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
    </div>
    <div class="flex flex-col my-2 font-roboto">
      <span class="text-peach font-semibold mb-1">Location Type</span>
      <div class="flex gap-x-2">
        <button class={`w-48 py-2 rounded-2xl font-semibold border border-transparent p-2 hover:border-peach2 hover:text-peach2 ${sw_type === 'STORE' ? 'bg-white text-peach2' : 'bg-gray-300'}`}
        on:click={() => {sw_type = "STORE"}} >Store</button>
        <button class={`w-48 py-2 rounded-2xl font-semibold p-2  border border-transparent hover:border-peach2 hover:text-peach2 ${sw_type === 'WAREHOUSE' ? 'bg-white text-peach2' : 'bg-gray-300'}`}
        on:click={() => {sw_type = "WAREHOUSE"}}>Warehouse</button>
      </div>
    </div>
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Province</span>
      <input type="text" on:click={toggleProvince} bind:value={province_name} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
      {#if provinces.length > 0 && showProvince}
        <ul class={`${provinces.length > 5 ? 'h-60' : 'h-fit'} overflow-y-auto absolute w-10/12 bg-white shadow-md mt-[5.5rem] ml-2 z-10`}>
          {#each provinces as province}
            <li on:click={() => selectProvince(province)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{province.province}</li>
          {/each}
        </ul>
      {/if}
    </div>
    
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">City</span>
      <input type="text" on:click={toggleCity}  bind:value={city_name} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
      {#if cities.length > 0 && showCity}
        <ul class={`${cities.length > 5 ? 'h-60' : 'h-fit'}  overflow-y-auto absolute w-10/12 bg-white shadow-md mt-[5.5rem] ml-2 z-10`}>
          {#each cities as city}
            <li on:click={() => selectCity(city)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{city.city}</li>
          {/each}
        </ul>
      {/if}
    </div>
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Location Address</span>
      <textarea rows="4" type="text" bind:value={address} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2"></textarea>
    </div>
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Location Phone Number</span>
      <input type="text" bind:value={phone_number} maxlength="13" class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2" on:input="{(e) => phone_number = e.target.value.replace(/\D/g, '')}">
    </div>
    <div class="flex mt-8 items-center justify-center text-lg">
      <button class="w-48 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold" on:click={() => closeModal()}>Discard</button>
      <button class="w-48 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold"on:click={() => addSW(sw_type)}>Add</button>
    </div>
  </div>
</TaskModal> 
{:else}
<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium capitalize flex">
      <div>Location Detail</div>
    </div>
  </div>
  <div class="flex flex-col justify-center p-8 font-roboto">
    {#if tampilan === 'View'}
    <button class="w-32 py-2 mb-4 px-4 bg-peach2 hover:bg-peach  text-darkGray border border-black rounded-xl font-semibold flex shadow-xl justify-center gap-x-2" on:click={async () => {tampilan = 'Edit'; await fetchProvince(); province_name_temp = location.province; province_id = location.location_id; province_name = location.province; city_name_temp = location.city; city_name = location.city; location_idnya = location.location_id;}}>
      <div>Edit </div> 
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="size-5">
        <path d="m5.433 13.917 1.262-3.155A4 4 0 0 1 7.58 9.42l6.92-6.918a2.121 2.121 0 0 1 3 3l-6.92 6.918c-.383.383-.84.685-1.343.886l-3.154 1.262a.5.5 0 0 1-.65-.65Z" />
        <path d="M3.5 5.75c0-.69.56-1.25 1.25-1.25H10A.75.75 0 0 0 10 3H4.75A2.75 2.75 0 0 0 2 5.75v9.5A2.75 2.75 0 0 0 4.75 18h9.5A2.75 2.75 0 0 0 17 15.25V10a.75.75 0 0 0-1.5 0v5.25c0 .69-.56 1.25-1.25 1.25h-9.5c-.69 0-1.25-.56-1.25-1.25v-9.5Z" />
      </svg>
    </button>
    <div class="flex flex-col my-2">
      <span class="text-peach  mb-1 font-semibold capitalize flex">
        <div>Location Name</div>
      </span>
      <div class="text-white font-semibold">{sw_specific.store_warehouse_name}</div>
    </div>
    <div class="flex flex-col my-2 font-roboto">
      <span class="text-peach  mb-1 font-semibold capitalize flex">
        <div>Location Type</div>
      </span>
      <div class="text-white font-semibold">{sw_specific.store_warehouse_type}</div>
    </div>
    <div class="flex x-full ">
      <div class="flex w-1/2 flex-col my-2">
        <span class="text-peach  mb-1 font-semibold capitalize flex">
          <div>City</div>
        </span>
        <div class="text-white font-semibold">{location.city}</div>
      </div>
      <div class="flex w-1/2 flex-col my-2 font-roboto">
        <span class="text-peach  mb-1 font-semibold capitalize flex">
          <div>Province</div>
        </span>
        <div class="text-white font-semibold">{location.province}</div>
      </div>
    </div>
    <div class="flex  flex-col my-2">
      <span class="text-peach font-semibold mb-1">Location Address</span>
      <div class="text-white font-semibold">{sw_specific.store_warehouse_address}</div>
    </div>
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Location Phone Number</span>
      <div class="text-white font-semibold">{sw_specific.store_warehouse_phone_number}</div>
    </div>
    <div class="flex mt-8 items-center justify-center text-lg">
      <button class="w-48 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold" on:click={() => closeModal()}>Close</button>
    </div>
    {:else if tampilan === 'Edit'}
    <!-- <button class="w-32 py-2 px-4 bg-peach2 hover:bg-peach text-darkGray border border-peach rounded-xl font-semibold" on:click={() => {tampilan = 'View';}}>
      Exit Edit Mode
    </button> -->
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1  capitalize flex">
        <div>Location Name</div>
      </span>
      <input type="text" bind:value={sw_specific.store_warehouse_name} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
    </div>
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1  capitalize flex">
        <div>Location Type</div>
      </span>
      <div class="text-white font-semibold">{sw_specific.store_warehouse_type}</div>
    </div>
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Province</span>
      <input type="text" on:click={toggleProvince} bind:value={province_name} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
      {#if provinces.length > 0 && showProvince}
        <ul class={`${provinces.length > 5 ? 'h-60' : 'h-fit'} overflow-y-auto absolute w-10/12 bg-white shadow-md mt-[5.5rem] ml-2 z-10`}>
          {#each provinces as province}
            <li on:click={() => selectProvince(province)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{province.province}</li>
          {/each}
        </ul>
      {/if}
    </div>
    
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">City</span>
      <input type="text" on:click={toggleCity}  bind:value={city_name} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
      {#if cities.length > 0 && showCity}
        <ul class={`${cities.length > 5 ? 'h-60' : 'h-fit'}  overflow-y-auto absolute w-10/12 bg-white shadow-md mt-[5.5rem] ml-2 z-10`}>
          {#each cities as city}
            <li on:click={() => selectCity(city)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{city.city}</li>
          {/each}
        </ul>
      {/if}
    </div>
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Location Address</span>
      <textarea rows="4" type="text" bind:value={sw_specific.store_warehouse_address} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2"></textarea>
    </div>
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Location Phone Number</span>
      <input type="text" bind:value={sw_specific.store_warehouse_phone_number} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
    </div>
    <div class="flex mt-8 items-center justify-center text-lg">
      <button class="w-48 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold" on:click={() => {tampilan = 'View'; sw_specific = { ...sw_specific_temp };; console.log(sw_specific); console.log(sw_specific_temp);}}>Discard</button>
      <button class="w-48 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold" on:click={() => {editSW(sw_specific); tampilan = 'View'}}>Save</button>
    </div>
    {/if}
   
  </div>
</TaskModal> 
{/if}