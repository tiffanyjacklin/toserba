<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import { onMount } from 'svelte';
    import { uri, userId, roleId } from '$lib/uri.js';
    import img_produk from "$lib/assets/produk.png";
    import Switch from '$lib/Switch.svelte';
    import LineChart from '$lib/LineChart.svelte';
    import { getFormattedDateNow, getThirtyDaysBefore, getFormattedDateForPrint } from '$lib/DateNow';
	import { goto } from '$app/navigation';
  import exportPDF from '$lib/exportPDF.js';

    let switchValue;
    let sliderValue;
    let multiValue;
    $: limit = 10; 
    $: offset = 0;
    $: totalNotes = 100; 
    $: currentPage = 1; 
    $: totalPages = Math.ceil(totalNotes/limit);
    $: editMode = false;
  
    $: sw_id = 0;
    let products = [];
    let transactions = [];
    let categories = [];
    let current_stock = [];
    let stock_card = [];
    let suppliers = [];
    // search filter query
    $: searchQuery = '';
    $: searchQuery_temp = '';
    $: sort_type = '';
    $: sorting = 'asc';
    $: fast_slow = '';
    $: unit_type = '';
    $: category = '';
    $: startDate = '';
    $: endDate = '';
    $: isLeft = false;
    $: startTransaction = '';
    $: endTransaction = '';
    $: dateChosen = '1M';

    $: searchQuery = '';
    $: searchQuery_temp = '';

    let specific_product = [];
    let selectedYear = 0;
    let selectedMonth = 0;
    let selectedDay= 0;

    const years = Array.from({ length: 50 }, (_, i) => new Date().getFullYear() - i); 
    const months = Array.from({ length: 12 }, (_, i) => (i + 1).toString()); 
    const days = Array.from({ length: 31 }, (_, i) => (i + 1).toString());

    let showModal = null; 
    let showTable = false;
    let showTable1 = false;
    let warehouses = [];
    $: store_name = '';
    $: store_name_temp = '';
    let showFilter = false;
    let showWarehouseList = false;

    function toggleWarehouse(){
      showWarehouseList = !showWarehouseList;
    }
  
    function toggleFilter() {
        showFilter = !showFilter;
    }
    function handleClick(product_id) {
        showModal = product_id;
        
        console.log(product_id)
        fetchProduk(product_id);
        fetchTransactions(product_id);
        
        fetchStockCard(product_id);
        fetchCurrentStock(product_id, sw_id);
        fetchSuppliers();
    }
    function closeModal() {
      showModal = null;
      current_stock = [];
      stock_card = [];
    }
    function toggleTable(product_id) {
      showTable = !showTable;
    }
    function toggleTable1(product_id) {
      console.log(sw_id);
      showTable1 = !showTable1;
    }
    async function fetchWarehouses() {
        const response = await fetch(`http://${$uri}:8888/store_warehouses/type/store/${store_name_temp}/0/0`, {
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
  
        warehouses = data.data;  
        console.log(warehouses);
    }
    function selectWarehouse(warehouse){
      sw_id = warehouse.store_warehouse_id;
      store_name = warehouse.store_warehouse_name;
      showWarehouseList = false;
    }
    async function fetchStockCard(product_id) {
      console.log(`http://${$uri}:8888/products/stock/card/product/${product_id}/0/0`);
        const response = await fetch(`http://${$uri}:8888/products/stock/card/product/${product_id}/0/0`, {
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
  
        stock_card = [...data.data];  
    }
    async function fetchCurrentStock(product_id, sw_id) {
      console.log(`http://${$uri}:8888/products/stock/opname/data/store_warehouse/${product_id}/${sw_id}/0/0`);
        const response = await fetch(`http://${$uri}:8888/products/stock/opname/data/store_warehouse/${product_id}/${sw_id}/0/0`, {
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
  
        current_stock = [...data.data];  
        console.log(current_stock);
    }
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

    
    async function fetchProductPhotos(product_photo_fetched){
      const response = await fetch(`http://${$uri}:8888/file/${product_photo_fetched}`, {
          method: 'GET',
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('fetch user pp failed', response);
          return;
      }

        // Instead of expecting a JSON response, we handle the image as a blob
        const blob = await response.blob();

        // Convert the blob to an object URL so it can be used as the image source
        return URL.createObjectURL(blob);
    }
    
  
    onMount(async () => {
        await fetchProducts();
        await fetchWarehouses();
        await fetchProductCategory();
    });
  
    async function fetchProducts() {
      let uri_temp = isLeft
      ? `products/moving/transaction/range/${sw_id}/${startDate}/${endDate}/${searchQuery}/${category}/${unit_type}/${fast_slow}/${limit}/${offset}`
      : `products/moving/transaction/${sw_id}/${selectedYear}/${selectedMonth}/${selectedDay}/${searchQuery}/${category}/${unit_type}/${fast_slow}/${limit}/${offset}`;
      // e.GET("/products/moving/transaction/:sw_id/:year/:month/:day/:product_id_name_code/:category/:unit_type/:asc/:limit/:offset", controller.GetSlowFastMovingFromTransactionBySWID)
      console.log(uri_temp);
        const response = await fetch(`http://${$uri}:8888/${uri_temp}`, {
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
        products = [...data.data];
        console.log("products",products)
        
        
        for(let i = 0; i < products.length; i++){
          if(products[i].ProductDetails.product_photo != "-"){
            products[i].photo = await fetchProductPhotos(products[i].ProductDetails.product_photo)
          } else {
            products[i].photo = "-";
          }
        }
        
    }
    
    $: if ((store_name_temp !== store_name) ){
      store_name_temp = store_name;
      fetchWarehouses();
    } else{
      store_name_temp = '';
    }

    $: if ((searchQuery_temp !== searchQuery) ){
      console.log(searchQuery);
      fetchProducts();
      searchQuery_temp = searchQuery;
    } else{
      searchQuery_temp = '';
    }
    async function goToPage(page) {
      if (page < 1 || page > Math.ceil(totalNotes / limit)) return;

      currentPage = page;
      offset = (currentPage - 1) * limit;
      await fetchProducts();
    }
    async function fetchProduk(product_id) {
        const response = await fetch(`http://${$uri}:8888/products/all/${product_id}`, {
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

        specific_product = [...data.data];  
    }
    async function fetchTransactions(product_id) {
        const response = await fetch(`http://${$uri}:8888/products/moving/transaction/product/${product_id}/${startTransaction}/${endTransaction}//0/0`, {
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

        transactions = [...data.data].sort((a, b) => {
          return new Date(a.Transaction.transaction_timestamp) - new Date(b.Transaction.transaction_timestamp);
        });
        console.log(transactions);
        list_of_dates = transactions.map(transaction => {
         const date = new Date(transaction.Transaction.transaction_timestamp);
         return date.toLocaleDateString('en-GB', {
               day: '2-digit',
               month: 'short',
               year: 'numeric'
         });
      });

        list_of_quantity = transactions.map(transaction => transaction.TransactionDetails.quantity);
    }
    $: list_of_dates = [];
    $: list_of_quantity = [];
    function updateVariables(quantities_profits, chart_type) {
      const date_list = quantities_profits.map(transaction => {
         const date = new Date(transaction.Transaction.transaction_timestamp);
         return date.toLocaleDateString('en-GB', {
               day: '2-digit',
               month: 'short',
               year: 'numeric'
         });
      });

      const quantity = quantities_profits.map(transaction => transaction.TransactionDetails.quantity);
      // console.log(date_list);
      // console.log(profits);
      return { date_list, quantity }; // Return as an object
   }
    async function editProduct(product_id,atribut) {
      const response = await fetch(`http://${$uri}:8888/products/edit/${product_id}`, {
          method: 'PUT',
          headers: {
                  'Content-Type': 'application/json',
              },
          body: JSON.stringify(atribut)
      });

      if (!response.ok) {
          console.error('PUT product details gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid put product details', data);
          return;
      }
      console.log("product details :",data);
    }
    async function fetchSuppliers() {
        const response = await fetch(`http://${$uri}:8888/suppliers/all/''/0/0`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all supplier fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch suppliers', data);
            return;
        }
 
        suppliers = data.data;
        // console.log(suppliers);
    }
    function getCategoryId(category_name){
      let categoryId = 0;
      let tmp_category = categories.find((category) => category.product_category_name == category_name);
      console.log("tmp_category", tmp_category);
      categoryId = tmp_category.product_category_id;
      return categoryId;
    }
    
    function getSupplierId(supplier_name){
      let supplierId = 0;
      let tmp_supplier = suppliers.find((supplier) => supplier.supplier_name == supplier_name);
      console.log("tmp_supplier", tmp_supplier)
      supplierId = tmp_supplier.supplier_id;
      return supplierId;
    }


  </script>
  
   <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
      <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Product Movement</span>
      
      <!-- <form class="flex items-center max-w-lg mx-auto">    -->
      <label for="voice-search" class="sr-only">Search</label>
      <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
        <input 
        bind:value={searchQuery} 
        type="text" id="voice-search" 
        class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
        placeholder="Search product by id, name, or product code..."/>
        <button on:click={toggleFilter}
          type="button" 
          class="absolute inset-y-0 end-0 flex items-center pe-3 ">
          <i class="fa-solid fa-sliders fa-xl mr-2"></i>
        </button>
        {#if showFilter}
          <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-3/5 bg-gray-100 p-4 rounded-lg font-roboto">
            
            <span class="font-bold text-xl mb-1">Store</span>
            <div class="mb-4">
              <input type="text" bind:value={store_name} on:click={toggleWarehouse} class="rounded-lg w-full h-8"/>
              {#if warehouses.length > 0 && showWarehouseList}
              <ul class="absolute w-11/12 bg-white shadow-md z-10">
                {#each warehouses as warehouse}
                  <li on:click={() => selectWarehouse(warehouse)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{warehouse.store_warehouse_name}</li>
                {/each}
              </ul>
              {/if}
            </div>
            
            <span class="font-bold text-xl mb-1">Product Order</span>
            <div class="grid grid-cols-4 flex w-full flex-wrap">
                <button on:click={() => {fast_slow = (fast_slow === '' || fast_slow !== "desc") ? "desc" : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${fast_slow === "desc" ? 'bg-white text-peach2 border-[#f2b082] border-[#f2b082]' : 'bg-gray-100'}`}>Fast-Moving</button>
                <button on:click={() => {fast_slow = (fast_slow === '' || fast_slow !== "asc") ? "asc" : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${fast_slow === "asc" ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Slow-Moving</button>
            </div>
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
            <div class="">
              <div class="font-bold text-xl mb-1 flex">
                Sale Period
                <Switch bind:value={isLeft} label="" fontSize={14} design="slider" />

                <div style="margin-left: 10px;">
                  {#if isLeft}
                    by date range
                  {:else}
                    by date
                  {/if}
                </div>
              </div>
              <div class="flex gap-x-4 w-full items-center">
                {#if isLeft}
                <span class="font-semibold text-lg mb-4">From</span>
                <input type="date" bind:value={startDate} class="rounded-xl w-32 mb-4 p-2 border" />
                <span class="font-semibold text-lg mb-4">To</span>
                <input type="date" bind:value={endDate} class="rounded-xl w-32 mb-4 p-2 border" />
                {:else}
                <!-- Year, Month, Day Inputs (when the toggle is left) -->
                <div class="gap-x-4">
                  <label for="year" class="font-semibold text-lg mr-4">Year</label>
                  <select id="year" bind:value={selectedYear} class="rounded-xl mb-4 p-2 border">
                    {#each years as year}
                      <option value={year}>{year}</option>
                    {/each}
                  </select>
                </div>

                <div class="gap-x-4">
                  <label for="month" class="font-semibold text-lg mr-4">Month</label>
                  <select id="month" bind:value={selectedMonth} class="rounded-xl mb-4 p-2 border">
                    {#each months as month}
                      <option value={month}>{month}</option>
                    {/each}
                  </select>
                </div>

                <div class="gap-x-4">
                  <label for="day" class="font-semibold text-lg mr-4">Day</label>
                  <select id="day" bind:value={selectedDay} class="rounded-xl mb-4 p-2 border">
                    {#each days as day}
                      <option value={day}>{day}</option>
                    {/each}
                  </select>
                </div>
              {/if}
              </div>
            </div>
            
            <div class="flex justify-between font-semibold mt-4">
                <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { sort_type = ''; sorting = '0'; unit_type = ''; category = ''; store_name = ''; sw_id = 0; startDate = ''; endDate = ''; selectedDay= 0; selectedMonth = 0; selectedYear = 0; }}>Clear</button>
                <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {fetchProducts(); toggleFilter();  currentPage = 1;}}>Apply</button>
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
      
      <div class="w-[96%] my-5 font-roboto">
          <div class="relative overflow-x-auto sm:rounded-lg">
            {#each products as product}
                  <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3">                        
                      <div class="m-4 w-1/12 flex">
                          {#if product.photo != "-"}
                            <img class="rounded-lg " src={product.photo} alt="">
                          {:else}
                            <img class="rounded-lg " src={img_produk} alt="">
                          {/if}
                      </div>
                      <div class="py-4 w-8/12">
                          <div class="font-bold text-[#f2b082] whitespace-nowrap text-lg flex divide-x-2 divide-[#f2b082]">
                            <div class="pr-2">ID: #{product.ProductDetails.product_detail_id}</div>
                            <div class="pl-2">Code: {product.ProductDetails.product_code}</div>
                          </div>
                          <div class="font-semibold text-xl">
                          {product.ProductDetails.product_name}
                          </div>
                          <div class="font-bold text-[#f2b082]  text-lg">
                            {product.TransactionDetails.quantity} {product.ProductDetails.product_unit} sold 
                          </div>
                      </div>
                      <div class="px-6 py-4 font-semibold w-3/12 flex flex-col items-center self-center">
                          <div class="flex justify-center text-xl">
                              Stock: {product.ProductDetails.product_stock} {product.ProductDetails.product_unit}
                          </div>
                          <div  class="flex items-center justify-center py-2 w-full">
                              <button 
                              on:click={() => handleClick(product.ProductDetails.product_detail_id)}
                              type="button" 
                              class="h-10 px-4 w-40 inline-flex items-center justify-start font-bold rounded-3xl bg-[#3d4c52] text-[#f2b082] hover:shadow-2xl">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-6">
                                  <path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
                                  <path fill-rule="evenodd" d="M1.323 11.447C2.811 6.976 7.028 3.75 12.001 3.75c4.97 0 9.185 3.223 10.675 7.69.12.362.12.752 0 1.113-1.487 4.471-5.705 7.697-10.677 7.697-4.97 0-9.186-3.223-10.675-7.69a1.762 1.762 0 0 1 0-1.113ZM17.25 12a5.25 5.25 0 1 1-10.5 0 5.25 5.25 0 0 1 10.5 0Z" clip-rule="evenodd" />
                              </svg>
                              <div class="text-lg text-white font-semibold w-full">View</div>
                              </button>
                          </div>
                      </div>
                  </div>
              {/each}
              
              {#if products.length === 0}
              <div class="justify-center w-full h-full flex rounded-xl py-4 my-3 ">
                  No product found.
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
  
  {#each specific_product as product} 
    {#if showModal === product.ProductDetails.product_detail_id}
      <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
        <div class="flex items-center justify-center pt-8">
          <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Product detail</div>
        </div>
        
      {#if editMode == true}
        <button on:click={() => editMode = false} class="mt-6 mx-4 p-2 bg-darkGray text-peach shadow w-32 rounded-2xl font-semibold border border-peach">Exit Edit Mode</button>
      {:else}
        <button on:click={() => editMode = true} class="mt-6 mx-4 p-2 bg-peach2 text-darkGray shadow w-32 rounded-2xl font-semibold">Edit <i class="fa-regular fa-pen-to-square" style="color: #364445;"></i></button>
      {/if}

        <form class=" mt-4 p-4 md:p-5">
            <div class="grid gap-3 font-roboto font-semibold">
              <div class="">
                  <div class="text-[#f7d4b2]">Product ID</div>
                  <div class="text-white">{product.ProductDetails.product_detail_id}</div>
              </div>
              <div class="">
                <div class="text-[#f7d4b2]">Product Name</div>
                {#if editMode == true}
                  <input name="product_name" id="product_name" type="text" bind:value={product.ProductDetails.product_name} class="bg-white text-darkGray border-0 p-1 rounded">
                {:else}
                  <div class="text-white">{product.ProductDetails.product_name}</div>
                {/if}
              </div>
              <div class="w-full y-full items-center border border-[#f2b082] rounded-xl py-2 px-4 justify-center">
               <div class="text-white text-center text-2xl font-bold mt-4">Product Sales</div>
               <div class="flex justify-center">
                  {#if list_of_quantity.length > 0 && list_of_dates.length > 0}
                      <LineChart data={list_of_quantity} dates={list_of_dates} labelColor={"white"}/>
                  {:else}
                    <div class="text-white m-4">No Transaction have been made.</div>
                  {/if}
                </div>
                <div class="flex justify-center mb-4">
                  <button on:click={() => {dateChosen = '1Y'; endTransaction = getFormattedDateNow(); startTransaction = getThirtyDaysBefore(endTransaction, 365); console.log(startTransaction, endTransaction); fetchTransactions(product.ProductDetails.product_detail_id)}} class={`border border-[#f2b082] border-r-0 text-xs font-light py-2 px-4 ${dateChosen === '1Y' ? 'bg-[#f2b082] text-black' : 'bg-transparent text-white'}`}>1Y</button>
                  <button on:click={() => {dateChosen = '6M'; endTransaction = getFormattedDateNow(); startTransaction = getThirtyDaysBefore(endTransaction, 182); console.log(startTransaction, endTransaction); fetchTransactions(product.ProductDetails.product_detail_id)}} class={`border border-[#f2b082] border-r-0 text-xs font-light py-2 px-4 ${dateChosen === '6M' ? 'bg-[#f2b082] text-black' : 'bg-transparent text-white'}`}>6M</button>
                  <button on:click={() => {dateChosen = '3M'; endTransaction = getFormattedDateNow(); startTransaction = getThirtyDaysBefore(endTransaction, 91); console.log(startTransaction, endTransaction); fetchTransactions(product.ProductDetails.product_detail_id)}} class={`border border-[#f2b082] border-r-0 text-xs font-light py-2 px-4 ${dateChosen === '3M' ? 'bg-[#f2b082] text-black' : 'bg-transparent text-white'}`}>3M</button>
                  <button on:click={() => {dateChosen = '1M'; endTransaction = getFormattedDateNow(); startTransaction = getThirtyDaysBefore(endTransaction, 30); console.log(startTransaction, endTransaction); fetchTransactions(product.ProductDetails.product_detail_id)}} class={`border border-[#f2b082] border-r-0 text-xs font-light py-2 px-4 ${dateChosen === '1M' ? 'bg-[#f2b082] text-black' : 'bg-transparent text-white'}`}>1M</button>
                  <button on:click={() => {dateChosen = '2W'; endTransaction = getFormattedDateNow(); startTransaction = getThirtyDaysBefore(endTransaction, 14); console.log(startTransaction, endTransaction); fetchTransactions(product.ProductDetails.product_detail_id)}} class={`border border-[#f2b082] border-r-0 text-xs font-light py-2 px-4 ${dateChosen === '2W' ? 'bg-[#f2b082] text-black' : 'bg-transparent text-white'}`}>2W</button>
                  <button on:click={() => {dateChosen = '1W'; endTransaction = getFormattedDateNow(); startTransaction = getThirtyDaysBefore(endTransaction, 7); console.log(startTransaction, endTransaction); fetchTransactions(product.ProductDetails.product_detail_id)}} class={`border border-[#f2b082] border-r-0 text-xs font-light py-2 px-4 ${dateChosen === '1W' ? 'bg-[#f2b082] text-black' : 'bg-transparent text-white'}`}>1W</button>
                  <button on:click={() => {dateChosen = '3D'; endTransaction = getFormattedDateNow(); startTransaction = getThirtyDaysBefore(endTransaction, 3); console.log(startTransaction, endTransaction); fetchTransactions(product.ProductDetails.product_detail_id)}} class={`border border-[#f2b082] text-xs font-light py-2 px-4 ${dateChosen === '3D' ? 'bg-[#f2b082] text-black' : 'bg-transparent text-white'}`}>3D</button>
                </div>
              </div>

              <div class="">
                <div class="text-[#f7d4b2]">Product Brand</div>
                {#if editMode == true}
                  <select bind:value={product.ProductDetails.supplier_name} on:change={console.log(product.ProductDetails.supplier_name)} name="product_type" id="product_type" class="w-44 rounded p-1 border-0 text-darkGray">
                    {#each suppliers as supplier}
                      <option value={supplier.supplier_name}>{supplier.supplier_name}</option>
                    {/each}
                  </select>
                {:else}
                  <div class="text-white">{product.Suppliers.supplier_name}</div>
                {/if}
                </div>
              <div class="">
                <div class="text-[#f7d4b2]">Product Type</div>
                {#if editMode == true}
                  <select bind:value={product.ProductCategories.product_category_name} on:change={console.log(product.ProductCategories.product_category_name)} name="product_type" id="product_type" class="w-44 rounded p-1 border-0 text-darkGray">
                    {#each categories as category}
                      <option value={category.product_category_name}>{category.product_category_name}</option>
                    {/each}
                  </select>
                {:else}
                  <div class="text-white">{product.ProductCategories.product_category_name}</div>
                {/if}
              </div>
              <div class="">
                <div class="text-[#f7d4b2]">Date Added</div>
                {#if editMode == true}
                  <div class="my-1 text-peach2">The current date added : </div>
                  <div class="text-white">
                    <DateConverter value={product.ProductDetails.product_timestamp} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                  </div>
                  <div class="my-1 text-peach2">New date added : </div>
                  <!-- <input type="date" bind:value={new Date(product.ProductDetails.product_timestamp).toJSON().slice(0, 10)} class="w-44 mb-4 p-2 border-0 rounded" /> -->
                  <input type="date" bind:value={product.ProductDetails.product_timestamp} on:change={console.log(product.ProductDetails.product_timestamp)} class="w-44 mb-4 p-2 border-0 rounded" />
                {:else}
                  <div class="text-white">
                      {#if product.ProductDetails.product_timestamp.length > 1}
                      <DateConverter value={product.ProductDetails.product_timestamp} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                      {:else}
                      -
                      {/if}
                  </div>                
                {/if}
              </div>
              <!-- <div class="">
                <div class="text-[#f7d4b2]">Expiration Date</div>
                <div class="text-white">
                  {#if product.ProductDetails.expiry_date.length > 1}
                    <DateConverter value={product.ProductDetails.expiry_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                  {:else}
                    -
                  {/if}
                </div>
              </div> -->
              <div class="">
                <div class="text-[#f7d4b2]">Current Stock
                  <button on:click={() => toggleTable1(product.ProductDetails.product_detail_id)} class="ml-2">
                    {#if showTable1}
                      <i class="fa-solid fa-caret-up"></i>
                    {:else}
                      <i class="fa-solid fa-caret-down"></i>
                    {/if}
                  </button>
                </div>
              {#if showTable1 && current_stock.length > 0}
                <div class="relative overflow-x-auto shadow-md w-fit rounded-lg">
                  <table class="w-fit rounded-lg text-sm text-left rtl:text-right">
                    <thead class="text-xs text-gray-700 uppercase bg-gray-100">
                      <tr class="border-b-2 border-black">
                        <th scope="col" class="px-3 py-2 text-sm font-bold uppercase text-center">
                          Batch
                        </th>
                        <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                          Expiry Date
                        </th>
                        <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                          Stock
                        </th>
                        <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                          Unit Type
                        </th>
                      </tr>
                    </thead>
                    <tbody>
                      {#each current_stock as stock, i}
                        <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                          <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                            {stock.batch}
                          </th>
                          <td class="px-1 py-2 text-center">
                            <DateConverter value={stock.expired_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                          </td>
                          <td class="px-1 py-2 text-center">
                            {stock.expected_stock}
                          </td>
                          <td class="px-1 py-2 text-center">
                            {stock.unit_type}
                          </td>
                        </tr>
                      {/each}
                    </tbody>
                  </table>
                </div>
              {/if}
              </div>
              <div class="">
                <div class="text-[#f7d4b2]">Last Inventory Taking</div>
                <div class="text-white">{product.ProductDetails.product_name}</div>
              </div>
              <div class="">
                <div class="text-[#f7d4b2]">
                  Stock Card
                  <button on:click={() => toggleTable(product.ProductDetails.product_detail_id)} class="ml-2">
                    {#if showTable}
                       <i class="fa-solid fa-caret-up"></i>
                    {:else}
                       <i class="fa-solid fa-caret-down"></i>
                    {/if}
                 </button>
                </div>
                {#if showTable && stock_card.length > 0}
                <div class="printable-section">
                  <div class="relative overflow-x-auto shadow-md sm:rounded-lg ">
                    <table class="w-full text-sm text-left rtl:text-right printable-table">
                      <thead class="text-xs text-gray-700 uppercase bg-gray-100">
                        <tr class="border-b-2 border-black">
                          <th scope="col" class="px-3 py-2 text-sm font-bold uppercase text-center">
                              No
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
                        {#each stock_card as stock, i}
                          <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                            <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                                  {i+1}
                            </th>
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
                <div class="flex items-center justify-start">
                  <button type="button" 
                  on:click={() => exportPDF(window.location.origin+`/print_stock_card/${$uri}/${product.ProductDetails.product_detail_id}/-`, `StockCard_${product.ProductDetails.product_detail_id}_AllSW_PrintedOn${getFormattedDateForPrint()}`, 190)}
                  class="mt-2 flex w-40 items-center justify-start text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-md py-1.5 text-center">
                    <div class="w-2/12 flex justify-center ml-2">
                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096m-.72-.096L17.66 18m0 0 .229 2.523a1.125 1.125 0 0 1-1.12 1.227H7.231c-.662 0-1.18-.568-1.12-1.227L6.34 18m11.318 0h1.091A2.25 2.25 0 0 0 21 15.75V9.456c0-1.081-.768-2.015-1.837-2.175a48.055 48.055 0 0 0-1.913-.247M6.34 18H5.25A2.25 2.25 0 0 1 3 15.75V9.456c0-1.081.768-2.015 1.837-2.175a48.041 48.041 0 0 1 1.913-.247m10.5 0a48.536 48.536 0 0 0-10.5 0m10.5 0V3.375c0-.621-.504-1.125-1.125-1.125h-8.25c-.621 0-1.125.504-1.125 1.125v3.659M18 10.5h.008v.008H18V10.5Zm-3 0h.008v.008H15V10.5Z" />
                      </svg>
                    </div>
                    <div class="w-10/12 text-start ml-2">
                      Print stock card
                    </div>
                  </button>
                </div>
                {/if}
              </div>
              <div class="">
                <div class="text-[#f7d4b2]">Buy Price</div>
                {#if editMode == true}
                <div class="w-44">
                  <MoneyInput bind:value={product.ProductDetails.buy_price} shadow={false}/>
                </div>
                {:else}
                  <div class="text-white">
                      <MoneyConverter value={product.ProductDetails.buy_price} currency={true} decimal={true}></MoneyConverter>
                  </div>                
                {/if}
              </div>
              <div class="">
                <div class="text-[#f7d4b2]">Sell Price</div>
                {#if editMode == true}
                <div class="w-44">
                  <MoneyInput bind:value={product.ProductDetails.sell_price} shadow={false}/>
                </div>
                {:else}
                  <div class="text-white">
                      <MoneyConverter value={product.ProductDetails.sell_price} currency={true} decimal={true}></MoneyConverter>
                  </div>             
                {/if}
              </div>
              <div class="">
                <div class="text-[#f7d4b2]">Minimum Stock</div>
                {#if editMode == true}
                  <input type="number" bind:value={product.ProductDetails.min_stock} class="bg-white text-darkGray border-0 p-1 rounded [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none">
                {:else}
                  <div class="text-white">{product.ProductDetails.min_stock}</div>
                {/if}
              </div>
              
              <div class="flex items-center justify-center">
                {#if editMode == false}
                  <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                    Close
                  </button>
                {:else}
                  <button type="button" on:click={async() => 
                  { let product_code = product.ProductDetails.product_code;
                    let product_category_id = getCategoryId(product.ProductCategories.product_category_name);
                    let product_name = product.ProductDetails.product_name;
                    let supplier_id =  getSupplierId(product.ProductDetails.supplier_name);
                    let buy_price = product.ProductDetails.buy_price;
                    let sell_price = product.ProductDetails.sell_price;
                    let min_stock = product.ProductDetails.min_stock;
                    let product_unit = product.ProductDetails.product_unit;
                    let product_timestamp = product.ProductDetails.product_timestamp + " 00:00:00";
                    let atribut = {
                      product_code,
                      product_category_id,
                      product_name,
                      supplier_id,
                      buy_price,
                      sell_price,
                      min_stock,
                      product_unit,
                      product_timestamp
                    };await editProduct(product.ProductDetails.product_detail_id,atribut); console.log(JSON.stringify(atribut));
                    Swal.fire({
                        title: "Produk Berhasil terupdate",
                        icon: "success",
                        color: "white",
                        background: "#364445",
                        confirmButtonColor: '#F2AA7E'
                      }); closeModal(); editMode = false; editMode = editMode; fetchProducts()}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                    Save
                  </button>
                {/if}
              </div>
            </div>
        </form>
    </TaskModal> 
    {/if}
  {/each}
  