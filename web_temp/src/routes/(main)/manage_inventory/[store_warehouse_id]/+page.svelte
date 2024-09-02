<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { getFormattedDate, isInTimeRange } from '$lib/DateNow.js';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId } from '$lib/uri.js';
    import img_produk from "$lib/assets/produk.png";

    export let data;
    let store_warehouse_id = data.store_warehouse_id;

    $: tampilan = "products"
    let searchQuery = '';
    let showModal = null; 
    let showTable = false;
    
    let products = [];
    let all_produk = [];
    let stock_card_product = [];

    let product_category = [];
    let suppliers = [];

    // STOCK HISTORY
    let stock_card_history = [];

    //VERIFY ADD SUBTRACT
    let verify_add = [];
    let verify_subtract = [];

    // ADD NEW PRODUK
    let product_name = "";
    let product_code = "";
    let product_category_id = "";
    let supplier_id;
    let buy_price;
    let sell_price;
    let min_stock;
    let product_unit = "";

    function handleClick(product_id) {
      showModal = product_id;
      console.log(product_id)
    }
    function closeModal() {
        showModal = null;
    }
    function toggleTable(product_id) {
        showTable = !showTable;
        if (showTable){
        fetchStockCard(product_id);
        } else {
        stock_card_product = [];
        }
    }

    async function fetchProduk() {
        const response = await fetch(`http://${$uri}:8888/products/store_warehouse/${$userId}/${$roleId}`, {
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

        products = [...data.data];  
        all_produk = [...products];
        console.log(all_produk);
    }

  async function fetchStockCard(product_id) {
      const response = await fetch(`http://${$uri}:8888/products/stock/card/product/${product_id}`, {
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

      stock_card_product = [...data.data];  
  }

  async function fetchProductCategory() {
        const response = await fetch(`http://${$uri}:8888/products/category`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all product category fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch product category', data);
            return;
        }
 
        product_category = data.data;
    }
  
    async function fetchSuppliers() {
        const response = await fetch(`http://${$uri}:8888/suppliers/all`, {
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
        console.log(suppliers);
    }
    
    async function fetchStockCardHistory() {
        const response = await fetch(`http://${$uri}:8888/products/stock/card/product/store_warehouse/${store_warehouse_id}`, {
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
 
        stock_card_history = data.data;
        // console.log("stockcard History",stock_card_history);
    }

    async function fetchAddVerify() {
        const response = await fetch(`http://${$uri}:8888/orders/supplier/not_verified`, {
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
 
        verify_add = data.data;
    }
    
    async function fetchSubtractVerify() {
        const response = await fetch(`http://${$uri}:8888/products/stock/subtract/not_verified`, {
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
 
        verify_subtract = data.data;
    }
   
    async function getStoreWarehouse(sw_id) {
        const response = await fetch(`http://${$uri}:8888/store_warehouses/${sw_id}`, {
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
 
        let nama_wr = data.data.store_warehouse_name ;
        return nama_wr;
    }

    async function AddNewProduct() {
        const response = await fetch(`http://${$uri}:8888/products/add`, {
            method: 'POST',
            body: JSON.stringify([{
              product_code,
              product_category_id,
              product_name,
              supplier_id,
              buy_price,
              sell_price,
              min_stock,
              product_unit
            }])
        });

        if (!response.ok) {
            console.error('POST add new product gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid post add new product', data);
            return;
        }
        console.log("post new add product berhasil ",data);
      }

    $: if (searchQuery.length > 0) {
        all_produk = products.filter(item => 
            item.ProductDetails.product_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            item.ProductDetails.product_detail_id.toString().includes(searchQuery)
        );
    } else {
        all_produk = [...products];
    }

    onMount(async () => {
      fetchProduk();
      fetchStockCardHistory();
      fetchProductCategory();
      fetchSuppliers();
      fetchAddVerify();
      fetchSubtractVerify();
  });

  $: editMode = false;

  </script>
  
   <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={() => goto('/manage_inventory')} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Inventory</span>
      
    <div class="w-11/12 my-10">
        <div class="flex">
            {#if tampilan == "products"}
                <button on:click={() => {tampilan = "products"; tampilan = tampilan;}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Products</button>
            {:else}
                <button on:click={() => {tampilan = "products"; tampilan = tampilan;}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Products</button>
            {/if}
            {#if tampilan == "stock_history"}
                <button on:click={() => {tampilan = "stock_history"; tampilan = tampilan;}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Stock History</button>
            {:else}
                <button on:click={() => {tampilan = "stock_history"; tampilan = tampilan;}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Stock History</button>
            {/if}
            {#if tampilan == "verify_add_subtract"}
                <button on:click={() => {tampilan = "verify_add_subtract"; tampilan = tampilan;}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Verify Add Subtract</button>
            {:else}
                <button on:click={() => {tampilan = "verify_add_subtract"; tampilan = tampilan;}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Verify Add Subtract</button>
            {/if}
            {#if tampilan == "assign_product"}
                <button on:click={() => {tampilan = "assign_product"; tampilan = tampilan;}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Assign Product</button>
            {:else}
                <button on:click={() => {tampilan = "assign_product"; tampilan = tampilan;}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Assign Product</button>
            {/if}
            {#if tampilan == "add_product"}
                <button on:click={() => {tampilan = "add_product"; tampilan = tampilan;}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Add New Product</button>
            {:else}
                <button on:click={() => {tampilan = "add_product"; tampilan = tampilan;}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Add New Product</button>
            {/if}
        </div>    
    </div>

    {#if tampilan != "add_product"}
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
      {/if}
      
      {#if tampilan == "products"}
        <div class="w-[96%] my-5 font-roboto">
            <div class="relative overflow-x-auto sm:rounded-lg">
            {#each all_produk as product}
                <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3">                        
                    <div class="m-4 w-1/12 flex">
                    <img class="rounded-lg " src={img_produk} alt="">
                    </div>
                        <div class="py-4 w-8/12">
                            <div class="font-bold text-[#f2b082] whitespace-nowrap text-lg">
                            #{product.ProductDetails.product_detail_id}
                            </div>
                            <div class="font-semibold text-xl">
                            {product.ProductDetails.product_name}
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
            </div>
        </div>
      {:else if tampilan == "stock_history"}
        <div class="w-11/12">
          <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
            <table class="w-full text-sm text-left rtl:text-right">
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
                {#each stock_card_history as stock, i}
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
      {:else if tampilan == "verify_add_subtract"}
        <div class="w-[96%] my-5 font-roboto">
            <div class="relative overflow-x-auto sm:rounded-lg">
            {#each verify_add as add_req}
                <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3 py-2 px-4">    
                  <div class="w-10/12 flex flex-col font-semibold text-lg">
                    <span class="my-1">Add Product Stock Request</span>
                    <span class="my-1">From warehouse {getStoreWarehouse(add_req.store_warehouse_id)}</span>
                    <div class="flex my-1">
                      <span class="mx-1">XX Items, </span>
                      {#if add_req.status_verify == 0}
                        <span class="">UNVERIFIED.</span>
                      {:else}
                        <span class="">VERIFIED.</span>
                      {/if}
                    </div>
                  </div>
                  
                  <div class="w-2/12 flex justify-end items-center">
                    <button class="p-4 bg-darkGray rounded-xl"><svg width="60" height="60" viewBox="0 0 60 60" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M2.5 30C2.5 30 12.5 10 30 10C47.5 10 57.5 30 57.5 30C57.5 30 47.5 50 30 50C12.5 50 2.5 30 2.5 30Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M30 37.5C34.1421 37.5 37.5 34.1421 37.5 30C37.5 25.8579 34.1421 22.5 30 22.5C25.8579 22.5 22.5 25.8579 22.5 30C22.5 34.1421 25.8579 37.5 30 37.5Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      </button>
                  </div>
                </div>
            {/each}
            {#each verify_subtract as sub_req}
                <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3 py-2 px-4">    
                  <div class="w-10/12 flex flex-col font-semibold text-lg">
                    <span class="my-1">Subtract Product Stock Request</span>
                    <span class="my-1">From warehouse {getStoreWarehouse(sub_req.store_warehouse_id)}</span>
                    <div class="flex my-1">
                      <span class="mx-1">XX Items, </span>
                      {#if sub_req.status_verify == 0}
                        <span class="">UNVERIFIED.</span>
                      {:else}
                        <span class="">VERIFIED.</span>
                      {/if}
                    </div>
                  </div>
                  
                  <div class="w-2/12 flex justify-end items-center">
                    <button class="p-4 bg-darkGray rounded-xl"><svg width="60" height="60" viewBox="0 0 60 60" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M2.5 30C2.5 30 12.5 10 30 10C47.5 10 57.5 30 57.5 30C57.5 30 47.5 50 30 50C12.5 50 2.5 30 2.5 30Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M30 37.5C34.1421 37.5 37.5 34.1421 37.5 30C37.5 25.8579 34.1421 22.5 30 22.5C25.8579 22.5 22.5 25.8579 22.5 30C22.5 34.1421 25.8579 37.5 30 37.5Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      </button>
                  </div>
                </div>
            {/each}
            </div>
        </div>
      {:else if tampilan == "assign_product"}
v
      {:else if tampilan == "add_product"}
        <div class="w-11/12">
          <div class="flex flex-col mx-4">
              
              <span class="text-xl text-darkGray font-semibold">Product Code</span>
              <input bind:value={product_code} type="text" class="my-1 mb-6 rounded-3xl focus:border-peach focus:ring-peach2" placeholder="Input Product Code">
              
              <span class="text-xl text-darkGray font-semibold">Product Name</span>
              <input bind:value={product_name} type="text" class="my-1 mb-6 rounded-3xl focus:border-peach focus:ring-peach2" placeholder="Input Product Name">

              <div class="grid grid-cols-3 gap-6">
                <div>
                  <span class="text-xl text-darkGray font-semibold">Product Type</span>
                  <select bind:value={product_category_id}  class="w-full rounded-3xl p-2 my-1 focus:border-peach focus:ring-peach2">
                    {#each product_category as category}
                      <option value={category.product_category_id}>{category.product_category_name}</option>
                    {/each}
                  </select>
                </div>
                <div>
                  <span class="text-xl text-darkGray font-semibold">Product Brand</span>
                  <div class="">
                    <select bind:value={supplier_id} class="w-full rounded-3xl p-2 my-1 focus:border-peach focus:ring-peach2">
                      {#each suppliers as supplier}
                        <option value={supplier.supplier_id}>{supplier.supplier_name}</option>
                      {/each}
                    </select>
                  </div>
                </div>
                <div>
                  <span class="text-xl text-darkGray font-semibold">Product Unit Type</span>
                  <select bind:value={product_unit} class="w-full rounded-3xl p-2 my-1 focus:border-peach focus:ring-peach2">
                    <option value="unit">Unit</option>
                    <option value="gram">Gram</option>
                  </select>
                </div>
                <div>
                  <span class="text-xl text-darkGray font-semibold">Buy Price</span>
                  <input bind:value={buy_price} type="number" class="[appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none w-full my-1 mb-6 rounded-3xl focus:border-peach focus:ring-peach2" placeholder="Input Buy Price">
                </div>
                <div>
                  <span class="text-xl text-darkGray font-semibold">Sell Price</span>
                  <input bind:value={sell_price} type="number" class="[appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none w-full my-1 mb-6 rounded-3xl focus:border-peach focus:ring-peach2" placeholder="Input Sell Price">
                </div>
                <div>
                  <span class="text-xl text-darkGray font-semibold">Min Stock</span>
                  <input bind:value={min_stock} type="number" class="[appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none w-full my-1 mb-6 rounded-3xl focus:border-peach focus:ring-peach2" placeholder="Input Min Stock">
                </div>
              </div>
          </div>
          <div class="flex justify-center mt-8">
            <!-- <button class="w-48 py-2 bg-darkGray text-peach rounded-2xl text-lg font-semibold mx-4">Back</button> -->
            <button on:click={() => showModal = "confirm_add"} class="w-48 py-2 bg-peach text-darkGray rounded-2xl text-lg font-semibold mx-4">Add</button>
          </div>;
        </div>
      {/if}

      {#if showModal == "confirm_add" }
        <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
          <div class="flex items-center justify-center pt-8 font-roboto">
            <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Save</div>
          </div>
          <form class="my-4 p-4 md:p-5 font-roboto text-xl">
                <div class="text-[#f7d4b2] font-medium text-center mb-8">
                  Are you sure you want to submit the changes you've made?
                </div>
                <div class="flex items-center justify-center gap-4">
                    <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                      Back
                    </button>
                    <button type="button" on:click={() => {AddNewProduct(); Swal.fire({
                      title: "Produk Berhasil Ditambahkan",
                      icon: "success",
                      color: "white",
                      background: "#364445",
                      confirmButtonColor: '#F2AA7E'
                    }); closeModal();
                    product_code = "";
                    product_category_id = 0;
                    product_name = "";
                    supplier_id = 0;
                    buy_price = 0;
                    sell_price = 0;
                    min_stock = 0;
                    product_unit = ""}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                      Add
                    </button>
                </div>
          </form>
        </TaskModal> 
        {/if}
        
      {#if tampilan != "add_product"}
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
      {/if}
       
   </div>

{#each all_produk as product} 
  {#if showModal === product.ProductDetails.product_detail_id}
    <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
      <div class="flex items-center justify-center pt-8">
        <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Product detail</div>
      </div>
      {#if editMode == true}
        <button on:click={() => editMode = false} class="mt-6 mx-4 p-2 bg-darkGray text-peach shadow w-32 rounded-2xl font-semibold border border-peach">Save <i class="fa-solid fa-check" style="color: #FACFAD;"></i></button>
      {:else}
        <button on:click={() => editMode = true} class="mt-6 mx-4 p-2 bg-peach2 text-darkGray shadow w-32 rounded-2xl font-semibold">Edit <i class="fa-regular fa-pen-to-square" style="color: #364445;"></i></button>
      {/if}
      <form class=" mt-4 p-4 md:p-5">
          <div class="grid gap-3 font-roboto font-semibold">
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product ID</div>
                <div class="text-white">{product.ProductDetails.product_detail_id}</div>
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product Name</div>
                {#if editMode == true}
                  <input name="product_name" id="product_name" type="text" bind:value={product.ProductDetails.product_name} class="bg-white text-darkGray border-0 p-1 rounded">
                {:else}
                  <div class="text-white">{product.ProductDetails.product_name}</div>
                {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product Brand</div>
                {#if editMode == true}
                  <select name="product_type" id="product_type" class="w-44 rounded p-1 border-0 text-darkGray">
                    {#each suppliers as supplier}
                    <option value={supplier.supplier_id}>{supplier.supplier_name}</option>
                    {/each}
                  </select>
                {:else}
                  <div class="text-white">{product.Suppliers.supplier_name}</div>
                {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product Type</div>
                {#if editMode == true}
                  <select name="product_type" id="product_type" class="w-44 rounded p-1 border-0 text-darkGray">
                    {#each product_category as category}
                    <option value={category.product_category_id}>{category.product_category_name}</option>
                    {/each}
                  </select>
                {:else}
                  <div class="text-white">{product.ProductCategories.product_category_name}</div>
                {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Date Added</div>
                {#if editMode == true}
                  <input type="date" value={new Date(product.ProductDetails.product_timestamp).toJSON().slice(0, 10)} class="w-44 mb-4 p-2 border-0 rounded" />
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
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Expiration Date</div>
                  <div class="text-white">
                      {#if product.ProductDetails.expiry_date.length > 1}
                      <DateConverter value={product.ProductDetails.expiry_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                      {:else}
                      -
                      {/if}
                  </div>              
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Current Stock</div>
              <div class="text-white">{product.ProductDetails.product_stock} {product.ProductDetails.product_unit}</div>
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
              {#if showTable && stock_card_product.length > 0}
              <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
                <table class="w-full text-sm text-left rtl:text-right">
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
                    {#each stock_card_product as stock, i}
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
              {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Buy Price</div>
                {#if editMode == true}
                <div class="w-44">
                  <MoneyInput value={product.ProductDetails.buy_price} />
                </div>
                {:else}
                  <div class="text-white">
                      <MoneyConverter value={product.ProductDetails.buy_price} currency={true} decimal={true}></MoneyConverter>
                  </div>                
                {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Sell Price</div>
                {#if editMode == true}
                <div class="w-44">
                  <MoneyInput value={product.ProductDetails.sell_price} />
                </div>
                {:else}
                  <div class="text-white">
                      <MoneyConverter value={product.ProductDetails.sell_price} currency={true} decimal={true}></MoneyConverter>
                  </div>             
                {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Minimum Stock</div> 
                {#if editMode == true}
                  <input id="product_name" type="text" value={product.ProductDetails.min_stock} class="bg-white text-darkGray border-0 p-1 rounded">
                {:else}
                  <div class="text-white">{product.ProductDetails.min_stock}</div>
                {/if}
            </div>
            
            <div class="flex items-center justify-center">
                <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                  Close
                </button>
            </div>
          </div>
      </form>
  </TaskModal> 
  {/if}
{/each}