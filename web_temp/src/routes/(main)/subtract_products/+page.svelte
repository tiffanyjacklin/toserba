<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, storeId, sw_name } from '$lib/uri.js';
    import { get } from 'svelte/store';
    import { goto } from '$app/navigation';
    storeId.set('');
  
    let productId = '';
    let productName = '';
    let expired_date = '';
    let batch = '';
    let stores = [];
    let all_stores = [];
    let stocks = [];
    let all_stocks = [];
    let warehouse = [];
    $: filteredStock = [];
    $: expiredDateOfSelectedProduct = [];
    let product = [];
  
    // let stock_card = [];
    let searchQuery = '';
    let showModal = false; 
    let showTable = false;
    let showAddProduct = false;
    let products_to_subtract = [];
  
   
    function handleClick() {
      showModal = true;
    }
    function closeModal() {
      showModal = false;
    }
    function toggleTable(product_id) {
      showTable = !showTable;
    }
    function toggleProductAdd() {
      showAddProduct = !showAddProduct;
    }
    onMount(async () => {
        await fetchWarehouse(); 
        await fetchStockOpname();
    });
  
  
    async function fetchWarehouse() {
        const response = await fetch(`http://${$uri}:8888/store_warehouses/${$userId}/${$roleId}`, {
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
  
        warehouse = data.data;  
        // all_stores = [...stores];
        console.log(warehouse);
    }
  
    async function fetchStockOpname() {
        const response = await fetch(`http://${$uri}:8888/products/stock/opname/data/store_warehouse/${warehouse.store_warehouse_id}`, {
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
  
        stocks = [...data.data];  
        // all_stocks = [...stocks];
        all_stocks = stocks.filter(item => 
          item.expected_stock > 0     
        );
        filteredStock = filterOldestStock(all_stocks);
        console.log(all_stocks);
        console.log(filteredStock);
    }
    
    function filterStock(value, type) {
      // Filter based on productId or productName
      if (type === 'id') {
        filteredStock = filteredStock.filter(stock => String(stock.product_detail_id).includes(value));
      } else {
        filteredStock = filteredStock.filter(stock => stock.product_name.toLowerCase().includes(value.toLowerCase()));
      }
    }
    function selectProduct(stock) {
        productId = stock.product_detail_id;
        productName = stock.product_name;
    }
    function selectProductExp(stock) {
        expired_date = stock.expired_date;

        all_stocks = stocks.filter(item => 
            item.expected_stock > 0     
        );
        filteredStock = filterOldestStock(all_stocks);
        expiredDateOfSelectedProduct = [];
    }
    function filterOldestStock(all_stockss) {
      let stockMap = new Map();
  
      const filteredForTransfer = all_stockss.filter(stock => {
          return !products_to_subtract.some(transfer =>
              transfer.product_name === stock.product_name &&
              transfer.batch === stock.batch
          );
      });
  
      filteredForTransfer.forEach(stock => {
          let existing = stockMap.get(stock.product_name);
  
          if (!existing || isOlder(stock.expired_date, existing.expired_date)) {
              stockMap.set(stock.product_name, stock);
          }
      });
  
      return Array.from(stockMap.values());
    }
    function isOlder(date1, date2) {
      // Convert "0000-00-00" to a very old date
      if (date1 === "0000-00-00") return true;
      if (date2 === "0000-00-00") return false;
  
      // Compare actual dates
      return new Date(date1) < new Date(date2);
    }
    function addProductToProductList(productIdnya, productNamenya, expired_dateNya) {
        console.log(expired_dateNya);
        let temp = expiredDateOfSelectedProduct.filter(stock => 
            stock.product_detail_id === productIdnya && 
            stock.product_name.toLowerCase().includes(productNamenya.toLowerCase()) &&
            stock.expired_date.includes(expired_dateNya)
        );
    
        products_to_subtract = [...products_to_subtract, ...temp];
    
        product = [];
        productId = ''; 
        productName = '';
        expired_date = '';
    
        all_stocks = stocks.filter(item => item.expected_stock > 0);
        filteredStock = filterOldestStock(all_stocks);
        expiredDateOfSelectedProduct = [];
    }
  
    $: if (String(productId).length > 0) {
      filterStock(productId, 'id');
    } else {
      
      all_stocks = stocks.filter(item => 
        item.expected_stock > 0     
      );
      filteredStock = filterOldestStock(all_stocks);
    }
    $: if (productName.length > 0) {
      filterStock(productName, 'name');
    } else {
      
      all_stocks = stocks.filter(item => 
        item.expected_stock > 0     
      );
      filteredStock = filterOldestStock(all_stocks);
      
    }
    $: if (productId === '' && productName.length === '') {
      all_stocks = stocks.filter(item => 
        item.expected_stock > 0     
      );
      filteredStock = filterOldestStock(all_stocks);
      expiredDateOfSelectedProduct = [];
    }
    $: if (productId !== '' && productName.length > 0) {
        expiredDateOfSelectedProduct = all_stocks.filter(item =>
        item.product_detail_id === productId &&
        item.product_name.toLowerCase().includes(productName.toLowerCase()) &&
        !products_to_subtract.some(transfer =>
            transfer.product_detail_id === item.product_detail_id &&
            transfer.batch === item.batch &&
            transfer.expired_date === item.expired_date
        )
        );
    }
    
    let temp = [];
    function deleteProductFromList(product_id) {
        products_to_subtract = products_to_subtract.filter(stock => 
          stock.product_detail_id !== product_id
        );
  
        all_stocks = stocks.filter(item => item.expected_stock > 0);
        filteredStock = filterOldestStock(all_stocks);
    }
    function filterProductForSubtract(products){
      return products.map(product => ({
          product_detail_id: product.product_detail_id,
          subtract_quantity: product.subtract_quantity,
          notes: product.notes,
          expired_date: product.expired_date,
          batch: product.batch
      }));
    }
    let products_to_send_fix = [];

    async function subtractProducts(){
      products_to_send_fix = filterProductForSubtract(products_to_subtract);
      console.log(products_to_send_fix);
  
      const response = await fetch(`http://${$uri}:8888/products/stock/subtract/${$userId}/${$roleId}`, {
        method: 'POST',
        body: JSON.stringify(products_to_send_fix)
      });
  
      if (!response.ok) {
        console.error('POST subtract product gagal', response);
        return;
      }
  
      const data = await response.json();
  
      if (data.status !== 200) {
        console.error('Invalid post subtract product', data);
        return;
      }
      console.log("insert subtract product detail",data);
      products_to_subtract = [];
      closeModal();
    //   goto(`/subtra`);
    }
  
  </script>
  <div class="select-none font-roboto text-[#364445] mx-8 mt-[90px] mb-10 flex flex-col items-center justify-center bg-white shadow-[0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="flex flex-col w-full pb-10 justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
      <div class="flex mt-10 justify-between mx-10 relative">
        <div class="absolute inset-0 text-center"> 
          <span class="text-4xl font-bold font-roboto text-[#364445]">Subtract Products</span>
        </div>      
      </div>
      <div class="w-full p-10 font-semibold text-xl mt-5 ">
        <table class="w-full text-sm text-left rtl:text-right">
          <thead class="text-xs text-gray-700 uppercase bg-white">
            <tr class="border-b-2 border-black">
              <th scope="col" class="px-3 py-2 text-sm font-bold uppercase text-center">
                No
              </th>
              <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                Product Name
              </th>
              <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
                Batch
              </th>
              <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
                Expired Date
              </th>
              <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
                Stock
              </th>
              <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
                Subtract Amount
              </th>
              <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
                Unit Type
              </th>
              <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
                Notes
              </th>
              <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
                Action
              </th>
            </tr>
          </thead>
          <tbody>
            {#each products_to_subtract as product, i}
              <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                      {i+1}
                </th>
                <td class="px-1 py-2 text-center">
                  {product.product_name}
                </td>
                <td class="px-1 py-2 text-center">
                  {product.batch}
                </td>
                <td class="px-1 py-2 text-center">
                    {product.expired_date}
                  </td>
                <td class="px-1 py-2 text-center">
                  {product.expected_stock}
                </td>
                <td class="px-1 py-2 text-center">
                  <input type="number" max={product.expected_stock} step="0.5" bind:value={product.subtract_quantity} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
                </td>
                <td class="px-1 py-2 text-center">
                  {product.unit_type}
                </td>
                <td class="px-1 py-2 text-center">
                  <input type="text" step="0.5" bind:value={product.notes} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
                </td>
                <td class="px-1 py-2 text-center">
                  <button on:click={() => deleteProductFromList(product.product_detail_id)} type="button" 
                    class="mt-2 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] hover:bg-[#F2AA7E] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg outline outline-[1px] px-3 py-3 text-center">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                      <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                    </svg>
                  </button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
      <div class="relative flex items-center justify-center w-full">
        <!-- Horizontal Line behind the button -->
        <hr class="absolute w-1/2 border-t-[1px] border-black  top-1/2 transform -translate-y-1/2"/>
      
        <!-- Button in front of the line -->
        <button on:click={toggleProductAdd} type="button" 
          class="z-10 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#F2AA7E] outline outline-[1.5px] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg px-3 py-3 text-center">
          
          <!-- SVG Icon -->
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
          </svg>
      
        </button>
      </div>
      <!-- Stocks:
      {#each stocks as stock}
        {stock.product_detail_id}, {stock.batch} & 
      {/each}
      <br>
      All Stocks:
      {#each all_stocks as stock}
        {stock.product_detail_id}, {stock.batch} & 
      {/each}
      <br>
      Filtered for Double Value:
      {#each filteredStock as stock}
        {stock.product_detail_id}, {stock.batch} & 
      {/each}
      <br>
      Product to Transfer:
      {#each products_to_subtract as stock}
        {stock.product_detail_id}, {stock.batch} & 
      {/each}
      <br>
      Expired Date of Selected Product:
      {#each expiredDateOfSelectedProduct as stock}
        {stock.product_detail_id}, {stock.batch}, {stock.expired_date} & 
      {/each}
      <br>
      ShowModal: {showModal} -->
      
      {#if showAddProduct}
      <div class="relative mt-8 flex items-center justify-center w-full">
        <div class="rounded-lg w-1/3 p-4 outline outline-1 bg-white text-black gap-2">
          <div class="my-3">
            <div class="font-semibold">Product ID</div>
            <input type="text" bind:value={productId} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
            {#if filteredStock.length > 0 && productId !== '' && productName === ''}
              <ul class="absolute w-1/4 bg-white shadow-md z-10">
                {#each filteredStock as stock}
                  <li on:click={() => selectProduct(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.product_detail_id} - {stock.product_name}</li>
                {/each}
              </ul>
            {/if}
          </div>
          
          <div class="my-3">
            <div class="font-semibold">Product Name</div>
            <input type="text" bind:value={productName} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
            {#if filteredStock.length > 0 && productName !== '' && productId === ''}
            <ul class="absolute w-1/4  bg-white shadow-md z-10">
              {#each filteredStock as stock}
                <li on:click={() => selectProduct(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.product_name} - {stock.product_detail_id}</li>
              {/each}
            </ul>
            {/if}
          </div>

          <div class="my-3">
            <div class="font-semibold">Expired date</div>
            <input type="text" bind:value={expired_date} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
            {#if expiredDateOfSelectedProduct.length > 0 && productName !== '' && productId !== '' && expired_date === ''}
            <ul class="absolute w-1/4  bg-white shadow-md z-10">
              {#each expiredDateOfSelectedProduct as stock}
                <li on:click={() => selectProductExp(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.expired_date}</li>
              {/each}
            </ul>
            {/if}
          </div>

          <div class="flex justify-center">
            <button on:click={() => addProductToProductList(productId, productName, expired_date)} type="button" 
              class="w-1/2 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#F2AA7E] outline outline-[1px] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg px-3 py-1 my-3 text-center">
              Add
            </button>
          </div>
        </div>
      </div>
      {/if}
      <!-- disabled={products_to_subtract.length === 0} -->
      <div class="flex items-center justify-center my-8">
        <button on:click={() => handleClick()} type="button" 
          class="mt-2 flex items-center justify-center bg-[#3d4c52] text-[#F2AA7E] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] hover:bg-darkGray focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg px-12 py-3 text-center"
          disabled={products_to_subtract.length === 0}>
          Submit
        </button>
      </div>
    </div>
  </div>
  {#if showModal}
  
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Submit</div>
    </div>
    <form class="my-4 p-4 md:p-5 font-roboto text-xl">
          <div class="text-[#f7d4b2] font-medium text-center mb-8">
            Are you sure you want to submit the changes you've made?
          </div>
          <div class="flex items-center justify-center gap-4">
              <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                Back
              </button>
              <button type="button" on:click={() => subtractProducts()} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                Submit
              </button>
          </div>
    </form>
  </TaskModal> 
  
  {/if}
  
  