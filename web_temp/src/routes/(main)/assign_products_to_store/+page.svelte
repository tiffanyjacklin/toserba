<script>
  import TaskModal from '$lib/TaskModal.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
  import MoneyConverter from '$lib/MoneyConverter.svelte';
  import { onMount } from 'svelte';
  import { uri, userId, roleId, storeId, sw_name } from '$lib/uri.js';
  import img_produk from "$lib/assets/produk.png";
  import { get } from 'svelte/store';
	import { goto } from '$app/navigation';
  // storeId.set('');

  let productId = '';
  let productName = '';
  let stores = [];
  let all_stores = [];
  let stocks = [];
  let all_stocks = [];
  let warehouse = [];
  $: filteredStock = [];
  let product = [];

  // let stock_card = [];
  let searchQuery = '';
  let showModal = false; 
  let showTable = false;
  let showAddProduct = false;
  let products_to_transfer = [];

  function chooseStore(id, store_warehouse_name){
    storeId.set(String(id));
    sw_name.set(store_warehouse_name);
    console.log($storeId, $sw_name);
  }
  function back(){
    storeId.set('');
    sw_name.set('');
  }
  function handleClick() {
    showModal = true;
  }
  function closeModal() {
    showModal = false;
  }
  function toggleTable(product_id) {
    showTable = !showTable;
    // if (showTable){
      // fetchStockCard(product_id);
    // } else {
      // stock_card = [];
    // }
  }
  function toggleProductAdd() {
    showAddProduct = !showAddProduct;
  }
  // async function fetchStockCard(product_id) {
  //     const response = await fetch(`http://${$uri}:8888/products/stock/card/product/${product_id}`, {
  //         method: 'GET',
  //         headers: {
  //             'Content-Type': 'application/json'
  //         }
  //     });

  //     if (!response.ok) {
  //         console.error('get all produk fetch failed', response);
  //         return;
  //     }

  //     const data = await response.json();

  //     if (data.status !== 200) {
  //         console.error('Invalid fetch last', data);
  //         return;
  //     }

  //     stock_card = [...data.data];  
  // }


  onMount(async () => {
      await fetchStore();
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
  async function fetchStore() {
      const response = await fetch(`http://${$uri}:8888/store_warehouses/type/store`, {
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

      stores = [...data.data];  
      all_stores = [...stores];
      console.log(all_stores);
  }
  $: if (searchQuery.length > 0) {
      all_stores = stores.filter(item => 
        item.store_warehouse_name.toLowerCase().includes(searchQuery.toLowerCase()) ||     
        item.store_warehouse_address.toLowerCase().includes(searchQuery.toLowerCase()) ||     
        item.store_warehouse_phone_number.toString().includes(searchQuery.toLowerCase())     
      );
  } else {
      all_stores = [...stores];
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

    all_stocks = stocks.filter(item => 
      item.expected_stock > 0     
    );
    filteredStock = filterOldestStock(all_stocks);
  }

  function filterOldestStock(all_stockss) {
    let stockMap = new Map();

    const filteredForTransfer = all_stockss.filter(stock => {
        return !products_to_transfer.some(transfer =>
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

  function addProductToProductList(productIdnya, productNamenya) {
    let filteredProducts = filteredStock.filter(stock => 
      stock.product_detail_id === productIdnya && 
      stock.product_name.toLowerCase().includes(productNamenya.toLowerCase())
    );

    filteredProducts = filteredProducts.map(product => {
        const existingProduct = products_to_transfer.find(transfer =>
            transfer.product_detail_id === product.product_detail_id &&
            transfer.batch === product.batch
        );

        if (!existingProduct) {
            return {
                ...product,
                quantity: ''
            };
        }
        return null;
    }).filter(product => product !== null);

    products_to_transfer = [...products_to_transfer, ...filteredProducts];

    product = [];
    productId = ''; 
    productName = '';

    all_stocks = stocks.filter(item => item.expected_stock > 0);
    filteredStock = filterOldestStock(all_stocks);
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
  }

  let temp = [];
  function deleteProductFromList(product_id) {
      products_to_transfer = products_to_transfer.filter(stock => 
        stock.product_detail_id !== product_id
      );

      all_stocks = stocks.filter(item => item.expected_stock > 0);
      filteredStock = filterOldestStock(all_stocks);
  }
  function filterProductForSending(products){
    return products.map(product => ({
        product_detail_id: product.product_detail_id,
        quantity: product.quantity,
        expired_date: product.expired_date,
        batch: product.batch
    }));
  }
  let products_to_send_fix = [];
  async function sendProducts(){
    products_to_send_fix = filterProductForSending(products_to_transfer);
    console.log(products_to_send_fix);

    const response = await fetch(`http://${$uri}:8888/orders/transfer/notes/add/${$userId}/${$roleId}`, {
      method: 'POST',
      body: JSON.stringify(products_to_send_fix)
    });

    if (!response.ok) {
      console.error('POST transfer note gagal', response);
      return;
    }

    const data = await response.json();

    if (data.status !== 200) {
      console.error('Invalid post transfer note', data);
      return;
    }
    console.log("insert transfer note detail",data);

    const transferDetails = data.data;

    for (const detail of transferDetails) {
      const transfer_note_detail_id = detail.transfer_note_detail_id;

      const response2 = await fetch(`http://${$uri}:8888/orders/transfer/notes/update/${transfer_note_detail_id}`, {
        method: 'PUT',
        body: JSON.stringify({
          "store_warehouse_to": Number($storeId),
          "user_id_from": Number($userId),
        }),
        headers: {
          'Content-Type': 'application/json'
        }
      });

      if (!response2.ok) {
        console.error('PUT transfer note failed', response2);
        continue;
      }

      const data2 = await response2.json();

      if (data2.status !== 200) {
        console.error('Invalid put transfer note', data2);
        continue;
      }

      console.log("Updated transfer note detail", data2);
    }
    goto(`/stock_transfer_notes`);
  }

</script>
<!-- {$storeId} -->
{#if $storeId === ''} 
 <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Assign Product to Store</span>

    <!-- <form class="flex items-center max-w-lg mx-auto">    -->
       <label for="voice-search" class="sr-only">Search</label>
       <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
          <input 
          bind:value={searchQuery} 
          on:keydown={(event) => handleSearch(event)} 
          type="text" id="voice-search" 
          class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
          placeholder="Search store..."/>
          <button 
                type="button" class="absolute inset-y-0 end-0 flex items-center pe-3 mr-1">
            <!-- <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
              </svg> -->
              <i class="fa-solid fa-sliders fa-xl mr-2"></i>
          </button>
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
 
     <div class="w-[96%] my-5 font-roboto">
        <div class="relative overflow-x-auto sm:rounded-lg">
          {#each all_stores as store}
          <button class="w-full h-full flex border-2 rounded-xl ml-auto border-gray-700 my-3 hover:bg-gray-200" type="button"
            on:click={() => chooseStore(store.store_warehouse_id, store.store_warehouse_name)}>                        
            <div class="m-4 w-1/12 flex items-center">
              <img class="rounded-lg " src={img_produk} alt="">
            </div>
            <div class="py-4 w-11/12">
                <div class="font-bold justify-start whitespace-nowrap flex">
                  <div class="">{store.store_warehouse_type}</div>
                  <div class="capitalize mx-1">{store.store_warehouse_name}</div>
                </div>
                <div class="font-semibold flex justify-start">
                  {store.store_warehouse_address}
                </div>
            </div>
          </button>
          {/each}
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
{:else}
<div class="select-none font-roboto text-[#364445] mx-8 mt-[90px] mb-10 flex flex-col items-center justify-center bg-white shadow-[0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
  <div class="flex flex-col w-full pb-10 justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="flex mt-10 justify-between mx-10 relative">
      <button type="button" on:click={back} class="text-lg z-10 hover:text-[#f2b082]">
        <i class="fa-solid fa-angle-left"></i>
        Back
      </button>
      <div class="absolute inset-0 text-center"> 
        <span class="text-4xl font-bold font-roboto text-[#364445]">Assign Product to Store {$sw_name}</span>
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
              Stock
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Stock to Send
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Unit Type
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Action
            </th>
          </tr>
        </thead>
        <tbody>
          {#each products_to_transfer as product, i}
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
                {product.expected_stock}
              </td>
              <td class="px-1 py-2 text-center">
                <input type="number" max={product.expected_stock} step="0.5" bind:value={product.quantity} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
              </td>
              <td class="px-1 py-2 text-center">
                {product.unit_type}
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
    Stocks:
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
    {#each products_to_transfer as stock}
      {stock.product_detail_id}, {stock.batch} & 
    {/each}
    <br>
    ShowModal: {showModal}
    
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
        <div class="flex justify-center">
          <button on:click={() => addProductToProductList(productId, productName)} type="button" 
            class="w-1/2 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#F2AA7E] outline outline-[1px] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg px-3 py-1 my-3 text-center">
            Add
          </button>
        </div>
      </div>
    </div>
    {/if}
    <!-- disabled={products_to_transfer.length === 0} -->
    <div class="flex items-center justify-center my-8">
      <button on:click={() => handleClick()} type="button" 
        class="mt-2 flex items-center justify-center bg-[#3d4c52] text-[#F2AA7E] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] hover:bg-darkGray focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg px-12 py-3 text-center"
        
        >
        Submit
      </button>
    </div>
  </div>
</div>
{/if}
{#if showModal}

<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Submit</div>
  </div>
  <form class="my-4 p-4 md:p-5 font-roboto text-xl">
        <div class="text-[#f7d4b2] font-medium text-center mb-8">
          Are you sure you want to submit the assignment to an admin for review?
        </div>
        <div class="flex items-center justify-center gap-4">
            <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
              Back
            </button>
            <button type="button" on:click={() => sendProducts()} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
              Submit
            </button>
        </div>
  </form>
</TaskModal> 

{/if}

