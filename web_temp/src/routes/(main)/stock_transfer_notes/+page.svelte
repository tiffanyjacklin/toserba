<script>
  import TaskModal from '$lib/TaskModal.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
  import MoneyConverter from '$lib/MoneyConverter.svelte';
  import { onMount } from 'svelte';
  import { uri, userId, roleId } from '$lib/uri.js';
  import img_produk from "$lib/assets/produk.png";

  let tf_notes = [];
  let transfer_notes = [];
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

      tf_notes = [...data.data];  
      transfer_notes = [...tf_notes];
      console.log(transfer_notes);
  }

  $: if (searchQuery.length > 0) {
      transfer_notes = tf_notes.filter(item => 
        tf_notes.transfer_note_id.toLowerCase().includes(searchQuery)
          // product.ProductDetails.product_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
          // product.ProductDetails.product_detail_id.toString().includes(searchQuery)
      );
  } else {
      transfer_notes = [...tf_notes];
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
        {#each transfer_notes as note}
        <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3">                        
          <div class=" w-1/12 flex justify-center items-center">
            <!-- <i class="fa-regular fa-file-lines fa-xl"></i> -->
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-10">
              <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
            </svg>
            
          </div>
          <div class="py-4 w-9/12">
              <div class="font-bold whitespace-nowrap">
                Stock Transfer Note #{note.transfer_note_id}
              </div>
              <div class="font-semibold">
                <DateConverter value={note.created_at} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={true} dateFirst={true}/>
              </div>
              <div class="flex font-semibold gap-1">
                {#if note.status_verify === 0}
                  <div class="">
                    Not Verified, 
                  </div>
                {:else}
                  <div class="text-[#f2b082]">
                    Verified, 
                  </div>
                {/if}
                {#if note.status_send === 0}
                  <div class="">
                    Not Sent.
                  </div>
                {:else}
                  <div class="text-[#f2b082]">
                    Sent. 
                  </div>
                {/if}
              </div>

          </div>
          <div class="font-semibold w-2/12">
            <div class="flex justify-center">
              <!-- Stock: {product.ProductDetails.product_stock} {product.ProductDetails.product_unit} -->
            </div>
            <button 
            on:click={() => handleClick(note.transfer_note_id)}
            type="button" 
            class="flex items-center justify-center py-2 w-full h-full px-4 font-bold bg-[#3d4c52] text-[#f2b082] hover:bg-darkGray ">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.75" stroke="currentColor" class="size-10">
                <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
              </svg>
            
            </button>
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

{#each transfer_notes as note} 
  {#if showModal === note.transfer_note_id}
    <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
      <div class="flex items-center justify-center pt-8">
        <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Product detail</div>
      </div>
      <form class=" mt-8 p-4 md:p-5">
          <div class="grid gap-3 font-roboto font-semibold">
            <div class="">
                <div class="text-[#f7d4b2]">Stock Transfer Note ID</div>
                <div class="text-white">{note.transfer_note_id}</div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Created at</div>
              <DateConverter value={note.created_at} date={true} hour={true} second={false} ampm={true} monthNumber={false} dash={false} dateFirst={false}/>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">
                Stock Card
                <button on:click={() => toggleTable(note.transfer_note_id)} class="ml-2">
                  {#if showTable}
                     <i class="fa-solid fa-caret-up"></i>
                  {:else}
                     <i class="fa-solid fa-caret-down"></i>
                  {/if}
               </button>
              </div>
              {showTable}
              {#if showTable && stock_card.length > 0}
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
                        In
                      </th>
                      <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                        Out
                      </th>
                      <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                        Unit Type
                      </th>
                      <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                        Batch Number
                      </th>
                      <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                        Expiry Date
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
                          {stock.product_name}
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
                          {stock.product_batch}
                        </td>
                        <td class="px-1 py-2 text-center">
                          <DateConverter value={stock.expired_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                        </td>
                      </tr>
                    {/each}
                  </tbody>
                </table>
              </div>
              {/if}
            </div>
            <div class="flex items-center justify-start">
              <button type="button" on:click={() => closeModal()} class="mt-2 flex w-2/4 items-center justify-start text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-md py-1.5 text-center">
                <div class="w-2/12 flex justify-center">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096m-.72-.096L17.66 18m0 0 .229 2.523a1.125 1.125 0 0 1-1.12 1.227H7.231c-.662 0-1.18-.568-1.12-1.227L6.34 18m11.318 0h1.091A2.25 2.25 0 0 0 21 15.75V9.456c0-1.081-.768-2.015-1.837-2.175a48.055 48.055 0 0 0-1.913-.247M6.34 18H5.25A2.25 2.25 0 0 1 3 15.75V9.456c0-1.081.768-2.015 1.837-2.175a48.041 48.041 0 0 1 1.913-.247m10.5 0a48.536 48.536 0 0 0-10.5 0m10.5 0V3.375c0-.621-.504-1.125-1.125-1.125h-8.25c-.621 0-1.125.504-1.125 1.125v3.659M18 10.5h.008v.008H18V10.5Zm-3 0h.008v.008H15V10.5Z" />
                  </svg>
                </div>
                <div class="w-10/12 text-start">
                  Print stock card
                </div>
              </button>
            </div>

            <div class="">
              <div class="text-[#f7d4b2]">Delivery Order</div>
              <div class="flex items-center justify-start">
                <button type="button" on:click={() => closeModal()} class="mt-2 flex w-2/4 items-center justify-start text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-md py-1.5 text-center">
                  <div class="w-2/12 flex justify-center">
                    <i class="fa-solid fa-plus"></i>
                  </div>
                  <div class="w-10/12 text-start">
                    Create delivery order
                  </div>
                </button>
              </div>
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