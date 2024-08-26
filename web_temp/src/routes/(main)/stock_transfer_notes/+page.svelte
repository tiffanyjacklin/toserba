<script>
  import TaskModal from '$lib/TaskModal.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
  import MoneyConverter from '$lib/MoneyConverter.svelte';
  import { onMount } from 'svelte';
  import { uri, userId, roleId } from '$lib/uri.js';
  import img_produk from "$lib/assets/produk.png";

  let products = [];
  let all_produk = [];
  let stock_card = [];
  let searchQuery = '';
  let showModal = null; 
  let showTable = false;


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
      stock_card = [];
    }
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

      stock_card = [...data.data];  
  }


  onMount(async () => {
      await fetchProduk();
  });

  async function fetchProduk() {
      const response = await fetch(`http://${$uri}:8888/orders/transfer/notes/all`, {
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
          product.ProductDetails.product_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
          product.ProductDetails.product_detail_id.toString().includes(searchQuery)
      );
  } else {
      all_produk = [...products];
  }
</script>

 
 <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Stock Transfer Notes</span>
    
    <!-- <form class="flex items-center max-w-lg mx-auto">    -->
       <label for="voice-search" class="sr-only">Search</label>
       <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
          <input 
          bind:value={searchQuery} 
          on:keydown={(event) => handleSearch(event)} 
          type="text" id="voice-search" 
          class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
          placeholder="Search stock transfer notes..."/>
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
        {#each all_produk as product}
        <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3">                        
          <div class="m-4 w-1/12 flex items-center">
            <i class="fa-regular fa-file-lines"></i>
          </div>
          <div class="py-4 w-8/12">
              <div class="font-bold text-[#f2b082] whitespace-nowrap">
                <!-- #{product.ProductDetails.product_detail_id} -->
              </div>
              <div class="font-semibold">
                <!-- {product.ProductDetails.product_name} -->
              </div>
          </div>
          <div class="px-6 py-4 font-semibold w-3/12">
            <div class="flex justify-center">
              <!-- Stock: {product.ProductDetails.product_stock} {product.ProductDetails.product_unit} -->
            </div>
            <div  class="flex items-center justify-start py-2 w-full">
              <button 
              on:click={() => handleClick(product.transfer_note_id)}
              type="button" 
              class="h-10 px-4 w-full inline-flex items-center justify-start font-bold rounded-md bg-[#3d4c52] text-[#f2b082] hover:shadow-2xl">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-6">
                  <path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
                  <path fill-rule="evenodd" d="M1.323 11.447C2.811 6.976 7.028 3.75 12.001 3.75c4.97 0 9.185 3.223 10.675 7.69.12.362.12.752 0 1.113-1.487 4.471-5.705 7.697-10.677 7.697-4.97 0-9.186-3.223-10.675-7.69a1.762 1.762 0 0 1 0-1.113ZM17.25 12a5.25 5.25 0 1 1-10.5 0 5.25 5.25 0 0 1 10.5 0Z" clip-rule="evenodd" />
                </svg>
                <div class="text-lg ml-6 text-white font-semibold">View</div>
              </button>
            </div>
          </div>
      </div>
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

{#each all_produk as product} 
  {#if showModal === product.ProductDetails.product_detail_id}
    <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
      <div class="flex items-center justify-center pt-8">
        <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Product detail</div>
      </div>
      <form class=" mt-8 p-4 md:p-5">
          <div class="grid gap-3 font-roboto font-semibold">
            <div class="">
                <div class="text-[#f7d4b2]">Product ID</div>
                <div class="text-white">{product.ProductDetails.product_detail_id}</div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Product Name</div>
              <div class="text-white">{product.ProductDetails.product_name}</div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Product Brand</div>
              <div class="text-white">{product.Suppliers.supplier_name}</div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Product Type</div>
              <div class="text-white">{product.ProductCategories.product_category_name}</div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Date Added</div>
              <div class="text-white">
                {#if product.ProductDetails.product_timestamp.length > 1}
                  <DateConverter value={product.ProductDetails.product_timestamp} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                {:else}
                  -
                {/if}
              </div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Expiration Date</div>
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
              {#if showTable && stock_card.length > 0}
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
              {/if}
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Buy Price</div>
              <div class="text-white">
                <MoneyConverter value={product.ProductDetails.buy_price} currency={true} decimal={true}></MoneyConverter>
              </div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Sell Price</div>
              <div class="text-white">
                <MoneyConverter value={product.ProductDetails.sell_price} currency={true} decimal={true}></MoneyConverter>
              </div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Minimum Stock</div>
              <div class="text-white">{product.ProductDetails.min_stock}</div>
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