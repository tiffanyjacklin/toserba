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
    
    let products = [];
    let all_produk = [];

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

    $: if (searchQuery.length > 0) {
        all_produk = products.filter(item => 
            item.ProductDetails.product_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            item.ProductDetails.product_detail_id.toString().includes(searchQuery)
        );
    } else {
        all_produk = [...products];
    }

    onMount(async () => {
      await fetchProduk();
  });

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
                <button on:click={() => {tampilan = "add_product"; tampilan = tampilan;}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Add Product</button>
            {:else}
                <button on:click={() => {tampilan = "add_product"; tampilan = tampilan;}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-52 py-2 rounded-3xl border-2 border-darkGray">Add Product</button>
            {/if}
        </div>    
    </div>


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

      {:else if tampilan == "verify_add_subtract"}

      {:else if tampilan == "assign_product"}

      {:else if tampilan == "add_product"}
        
      {/if}
  
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