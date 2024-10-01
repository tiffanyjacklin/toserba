<script>
  import TaskModal from '$lib/TaskModal.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
  import MoneyConverter from '$lib/MoneyConverter.svelte';
  import { onMount } from 'svelte';
  import { uri, userId, roleId, sw_name } from '$lib/uri.js';
  import { get } from 'svelte/store';
  import { goto } from '$app/navigation';

  let warehouse = [];
  $: products = [];
  $: all_products = [];
  $: stocks = [];
  $: all_stocks = [];

  let showModal = false;
  let showAddProduct = false;
  $: showIDList = false;
  $: showNameList = false;
  $: showExpiredDateList = false;
  $: showBatchList = false;
  let userClearedBatch = false;
  let userClearedExpiredDate = false;

  $: productId = '';
  $: productName = '';
  $: expired_date = '';
  $: batch = '';
  
  $: expiredDateOfSelectedProduct = [];
  $: batchOfSelectedProduct = [];
  $: products_to_subtract = [];
  let products_to_send_fix = [];
  
  onMount(async () => {
      await fetchWarehouse();
      await fetchProducts();
      await fetchStockOpname();
  });
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

    warehouse = data.data[0].StoreWarehouses;
  }
  async function fetchProducts() {
    const response = await fetch(`http://${$uri}:8888/products/store_warehouse/${$userId}/${$roleId}////////0/0`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    });

    if (!response.ok) {
        console.error('Fetch stock opname failed', response);
        return;
    }

    const data = await response.json();

    if (data.status !== 200) {
        console.error('Invalid stock opname fetch', data);
        return;
    }

    products = [...data.data];
    all_products = products.filter(item => item.ProductDetails.product_stock > 0);
    // console.log("dari fetch products",products);
    // console.log("dari fetch products",all_products);
  }
  async function fetchStockOpname() {
    const response = await fetch(`http://${$uri}:8888/products/stock/opname/data/store_warehouse/${warehouse.store_warehouse_id}/${productName}/${batch}/''/${productId}/${expired_date}/''/''//0/0`, {
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
    all_stocks = stocks.filter(item => item.expected_stock > 0);
    // console.log("dari fetch stocks",stocks);
    // console.log("dari fetch stocks",all_stocks);
  }
  function toggleProductAdd() {
    showAddProduct = !showAddProduct;
  }
  function handleClick() {
    showModal = true;
  }
  function closeModal() {
    showModal = false;
  }
  function toggleIDList() {
    showIDList = !showIDList;
    showNameList = false;
  }
  function toggleNameList() {
    showNameList = !showNameList;
    showIDList = false;
  }
  async function selectProduct(stock) {
    productId = stock.ProductDetails.product_detail_id;
    productName = stock.ProductDetails.product_name;
    expired_date = '';
    batch = '';

    showIDList = false;
    showNameList = false;
    autoFillIfOnlyOneStock();
  } 
  async function toggleExpiredDateList() {
    if (productId && productName) {
      autoFillIfOnlyOneStock();
      showExpiredDateList = !showExpiredDateList;
      showBatchList = false;
    }
  }
  async function toggleBatchList() {
    if (productId && productName) {
      autoFillIfOnlyOneStock();
      showBatchList = !showBatchList;
      showExpiredDateList = false;
    }
  }
  async function autoFillIfOnlyOneStock() {
    await fetchStockOpname();
    filterUniqueExpiredDates(); 
    filterUniqueBatches(); 
    if (all_stocks.length === 1 || (batchOfSelectedProduct.length === 1 && expiredDateOfSelectedProduct.length === 1)) {
      if (!userClearedBatch) {
        batch = expiredDateOfSelectedProduct[0].batch;
      }
      if (!userClearedExpiredDate) {
        expired_date = batchOfSelectedProduct[0].expired_date;
      }
    }
  }
  async function selectProductExp(stock) {
    expired_date = stock.expired_date;
    showExpiredDateList = false;
    autoFillIfOnlyOneStock();
    userClearedBatch = false;
    userClearedExpiredDate = false;
  }
  async function selectProductBatch(stock) {
    batch = stock.batch;
    showBatchList = false;
    autoFillIfOnlyOneStock();
    userClearedBatch = false;
    userClearedExpiredDate = false;
  }
  async function clearBatch() {
    batch = '';
    userClearedBatch = true;
    autoFillIfOnlyOneStock();
  }
  async function clearExpiredDate() {
    expired_date = '';
    userClearedExpiredDate = true;
    autoFillIfOnlyOneStock();
  }
  function filterUniqueExpiredDates() {
    const uniqueDates = new Map();

    all_stocks.forEach(stock => {
        if (stock.product_detail_id === productId) {
            if ((batch === '' || stock.batch === batch) && stock.expired_date && !isAlreadyInProductsToSubtract(stock)) {
                uniqueDates.set(stock.expired_date, stock);
            }
        }
    });

    expiredDateOfSelectedProduct = Array.from(uniqueDates.values());

    if (expiredDateOfSelectedProduct.length === 1) {
        expired_date = expiredDateOfSelectedProduct[0].expired_date;
    }
  }
  function filterUniqueBatches() {
    const uniqueBatches = new Map();

    all_stocks.forEach(stock => {
        if (stock.product_detail_id === productId) {
            if ((expired_date === '' || stock.expired_date === expired_date) && stock.batch && !isAlreadyInProductsToSubtract(stock)) {
                uniqueBatches.set(stock.batch, stock);
            }
        }
    });

    batchOfSelectedProduct = Array.from(uniqueBatches.values());

    if (batchOfSelectedProduct.length === 1) {
        batch = batchOfSelectedProduct[0].batch;
    }
  }
  function isAlreadyInProductsToSubtract(stock) {
    return products_to_subtract.some(subtract =>
        subtract.product_detail_id === stock.product_detail_id &&
        subtract.batch === stock.batch &&
        subtract.expired_date === stock.expired_date
    );
  }
  function filterProductsBasedOnSubtraction() {
    if (products_to_subtract.length > 0) {
      all_products = all_products.filter(product => {
        const productStocks = all_stocks.filter(stock => stock.product_detail_id === product.ProductDetails.product_detail_id);
        const allSubtracted = areAllStocksSubtracted(productStocks);
        return !allSubtracted;
      });
    }
  }
  function areAllStocksSubtracted(productStocks) {
    const allSubtracted = productStocks.every(stock => {
      const isSubtracted = products_to_subtract.some(subtract => 
        subtract.product_detail_id === stock.product_detail_id &&
        subtract.batch === stock.batch &&
        subtract.expired_date === stock.expired_date
      );
      return isSubtracted;
    });
    return allSubtracted;
  }
  function addProductToProductList(productIdnya, productNamenya, expired_dateNya, batchNya) {
    let temp = all_stocks.filter(stock =>
      stock.product_detail_id === productIdnya &&
      stock.product_name.toLowerCase().includes(productNamenya.toLowerCase()) &&
      stock.expired_date === expired_dateNya &&
      stock.batch === batchNya
    );
    products_to_subtract = [...products_to_subtract, ...temp];
    resetVariables();
  }
  function deleteProductFromList(product_id, expired_dateNya, batchnya) {
    products_to_subtract = products_to_subtract.filter(stock =>
      !(stock.product_detail_id === product_id &&
        stock.expired_date === expired_dateNya &&
        stock.batch === batchnya)
    );
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
    resetVariables();
    closeModal();
  }
  async function resetVariables(){
    productId = '';
    productName = '';
    expired_date = '';
    batch = '';
    showExpiredDateList = false;
    showBatchList = false;
    showIDList = false;
    showNameList = false;
    expiredDateOfSelectedProduct = [];
    batchOfSelectedProduct = [];
    
    await fetchProducts();
    await fetchStockOpname();
    filterProductsBasedOnSubtraction();
    autoFillIfOnlyOneStock();
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
                  <input type="number" max={product.expected_stock} min={0} step="0.5" bind:value={product.subtract_quantity} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
                </td>
                <td class="px-1 py-2 text-center">
                  {product.unit_type}
                </td>
                <td class="px-1 py-2 text-center">
                  <input type="text" step="0.5" bind:value={product.notes} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
                </td>
                <td class="px-1 py-2 text-center">
                  <button on:click={() => deleteProductFromList(product.product_detail_id, product.expired_date, product.batch)} type="button" 
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
        <hr class="absolute w-1/2 border-t-[1px] border-black  top-1/2 transform -translate-y-1/2"/>
      
        <button on:click={toggleProductAdd} type="button" 
          class="z-10 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#F2AA7E] outline outline-[1.5px] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg px-3 py-3 text-center">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
          </svg>
        </button>
      </div>
    <!-- <div class="select-text	">
      Products: {#each products as stock} {stock.ProductDetails.product_detail_id}, {stock.ProductDetails.product_batch}, {stock.ProductDetails.expiry_date} & <br> {/each} <br>
      All Products: {#each all_products as stock} {stock.ProductDetails.product_detail_id}, {stock.ProductDetails.product_batch}, {stock.ProductDetails.expiry_date} & <br> {/each} <br>
      Stocks: {#each stocks as stock} {stock.product_detail_id}, {stock.batch}, {stock.expired_date} &   {/each} <br>
      All Stocks: {#each all_stocks as stock} {stock.product_detail_id}, {stock.batch}, {stock.expired_date} & {/each} <br>
      Product to Transfer: {#each products_to_subtract as stock} {stock.product_detail_id}, {stock.batch}, {stock.expired_date} &  {/each} <br>
      Expired Date of Selected Product: {#each expiredDateOfSelectedProduct as stock} {stock.product_detail_id}, {stock.batch}, {stock.expired_date} & {/each} <br>
      Batch of Selected Product: {#each batchOfSelectedProduct as stock} {stock.product_detail_id}, {stock.batch}, {stock.expired_date} & {/each}
      <br> ShowModal: {showModal} <br> showIDList: {showIDList} <br> showNameList: {showNameList} <br> Expired Date: {expired_date} <br> Batch: {batch} <br> showBatchList: {showBatchList} <br> showExpiredDateList: {showExpiredDateList} <br>
    </div> -->
      
      {#if showAddProduct}
      <div class="relative mt-8 flex items-center justify-center w-full">
        <div class="rounded-lg w-1/3 p-4 outline outline-1 bg-white text-black gap-2">
          <button class="" on:click={resetVariables}>Reset</button>
          <div class="my-3">
            <div class="font-semibold">Product ID</div>
            <input type="text" bind:value={productId} on:click={toggleIDList} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
            {#if showIDList && all_products.length > 0}
              <ul class="absolute w-1/4 bg-white shadow-md z-10">
                {#each all_products as stock}
                  <li on:click={() => selectProduct(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.ProductDetails.product_detail_id} - {stock.ProductDetails.product_name}</li>
                {/each}
              </ul>
            {/if}
          </div>
          
          <div class="my-3">
            <div class="font-semibold">Product Name</div>
            <input type="text" bind:value={productName} on:click={toggleNameList} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
            {#if showNameList && all_products.length > 0}
            <ul class="absolute w-1/4  bg-white shadow-md z-10">
              {#each all_products as stock}
                <li on:click={() => selectProduct(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.ProductDetails.product_name} - {stock.ProductDetails.product_detail_id}</li>
              {/each}
            </ul>
            {/if}
          </div>
          <div class="my-3">
            <div class="font-semibold">Product Batch</div>
            <input type="text" on:input={clearBatch} bind:value={batch} on:click={toggleBatchList} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
            {#if showBatchList && batchOfSelectedProduct.length > 0}
            <ul class="absolute w-1/4  bg-white shadow-md z-10">
              {#each batchOfSelectedProduct as stock}
                <li on:click={() => selectProductBatch(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.batch}</li>
              {/each}
            </ul>
            {/if}
          </div>

          <div class="my-3">
            <div class="font-semibold">Expired date</div>
            <input type="text" on:input={clearExpiredDate} bind:value={expired_date} on:click={toggleExpiredDateList} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
            {#if showExpiredDateList && expiredDateOfSelectedProduct.length > 0}
            <ul class="absolute w-1/4  bg-white shadow-md z-10">
              {#each expiredDateOfSelectedProduct as stock}
                <li on:click={() => selectProductExp(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.expired_date}</li>
              {/each}
            </ul>
            {/if}
          </div>

          <div class="flex justify-center">
            <button on:click={() => addProductToProductList(productId, productName, expired_date, batch)} type="button" 
              disabled={productId === '' || productName === '' || expired_date === '' || batch === ''}
              class="w-1/2 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#F2AA7E] outline outline-[1px] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg px-3 py-1 my-3 text-center">
              Add
            </button>
          </div>
        </div>
      </div>
      {/if}
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
  
  