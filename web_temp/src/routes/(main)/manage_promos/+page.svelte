<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { getFormattedDate, isInTimeRange } from '$lib/DateNow.js';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId } from '$lib/uri.js';

    let searchQuery = '';
    let promos = [];

    $: showModal = null;
    $: showDropDown = false;

    function toggleTable() {
        showTable = !showTable;
   }
   function handleClick(sessionId) {
      showModal = sessionId;
      fetchTransactionBySession(sessionId);
   }
   function closeModal() {
        showModal = null;
        showModal12 = null;
   }

   async function fetchPromos(){
        const response = await fetch(`http://${$uri}:8888/promos`, {
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

        promos = data.data;
        console.log(promos);
        
    }
  
    onMount(async () => {
      await fetchPromos();
    });

    // $: session.forEach(item => {
    //     item.actual_difference = item.actual_closing_cash - item.expected_closing_cash;
    //     item.deposit_difference = item.actual_closing_cash - item.deposit_money;
    // });
  
  </script>
  
   <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Promos</span>

        <div class="w-11/12 flex items-center">
            <div class="relative w-9/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg mr-4">
                <input 
                    type="text" 
                    id="voice-search" 
                    bind:value={searchQuery}
                    class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                    placeholder="Search..."/>
                <button 
                    type="button" 
                    class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                    <i class="fa-solid fa-sliders fa-xl mr-2"></i>
                </button>
            </div>
            <div class="relative w-3/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-xl">
                <button on:click={() => {showModal = "choose_product"}} class="w-full py-4 rounded-xl bg-peach font-semibold text-lg text-darkGray border-2 border-darkGray"><i class="fa-solid fa-plus mr-2"></i>Add New Promo</button>
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

      <div class="w-[96%] my-5 font-roboto">
        <div class="relative overflow-x-auto sm:rounded-lg">
            {#each promos as promo}
            <div class="flex items-center border-2 rounded-xl ml-auto border-gray-700 m-3 py-2 px-4">    
              <div class="w-10/12 flex flex-col font-semibold text-lg">
                <span class="my-1">{promo["ProductDetail"].product_name}</span>
                <div class="flex justify-between my-1">
                  <span class="mx-1 text-peach2">Applied to XX Stores</span>
                  <span class="mx-1"></span>
                  <span class="mx-1">Promo End : {promo["Promo"].promo_end_date}</span>
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

<!-- MODAL CHOOSE PRODUCT -->
{#if showModal == "choose_product" }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Choose Product</div>
    </div>
    <div class="flex flex-col justify-center p-8">
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold">Product ID</span>
        <input on:input={() => showDropDown = true}  type="text" class="rounded-xl mb-1" placeholder="Choose Product ID">
        {#if showDropDown}
        <ul class="z-10 bg-peach text-darkGray rounded">
          <li class="p-1 rounded hover:bg-peach2 font-semibold">Pepper</li>
          <li class="p-1 rounded hover:bg-peach2 font-semibold">Pepper</li>
          <li class="p-1 rounded hover:bg-peach2 font-semibold">Pepper</li>
        </ul>
        {/if}
      </div>
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold">Product Name</span>
        <input on:input={() => showDropDown = true}  type="text" class="rounded-xl mb-1" placeholder="Choose Product Name">
        {#if showDropDown}
        <ul class="z-10 bg-peach text-darkGray rounded">
          <li class="p-1 rounded hover:bg-peach2 font-semibold">Pepper</li>
          <li class="p-1 rounded hover:bg-peach2 font-semibold">Pepper</li>
          <li class="p-1 rounded hover:bg-peach2 font-semibold">Pepper</li>
        </ul>
        {/if}
      </div>
      <div class="flex mt-8 items-center justify-center">
        <button class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
        <button on:click={() => {showModal = "add_promo"; showModal = showModal;}} class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Add</button>
      </div>
    </div>
  </TaskModal> 
  {/if}

  <!-- MODAL ADD PROMO -->
{#if showModal == "add_promo" }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Add Promo</div>
    </div>
    <div class="flex flex-col justify-center p-8">
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold mb-1">Product ID</span>
        <input value="ini id productnya" readonly type="text" class="rounded-xl mb-1" placeholder="Choose Product ID">
      </div>
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold mb-1">Product Name</span>
        <input value="ini nama productnya" readonly type="text" class="rounded-xl mb-1">
      </div>
      <div class="flex flex-col my-1 mb-2">
        <span class="text-peach font-semibold mb-1">Product Promo</span>
        <div class="w-2/3 grid grid-cols-2 gap-2">
          <button class="w-full py-2 bg-darkGray text-peach border border-peach rounded-2xl font-semibold">Promo1</button>
          <button class="w-full py-2 bg-darkGray text-peach border border-peach rounded-2xl font-semibold">Promo1</button>
          <button class="w-full py-2 bg-darkGray text-peach border border-peach rounded-2xl font-semibold">Promo1</button>
          <button class="w-full py-2 bg-darkGray text-peach border border-peach rounded-2xl font-semibold">Promo1</button>
        </div>
      </div>



      <!-- PROMO TYPE 1 : BUY X, GET Y -->
      <div class="flex items-center my-1">
        <span class="text-peach font-semibold mb-1 mr-2">Buy Amount</span>
        <input value="" type="text" class="w-32 rounded-xl mb-1">
      </div>
      <div class="flex items-center my-1">
        <span class="text-peach font-semibold mb-1 mr-2">Get Amount</span>
        <input value="" type="text" class="w-32 rounded-xl mb-1">
      </div>
      
      <!-- PROMO TYPE 2 : %DISCOUNT -->
      <div class="flex items-center my-1">
        <span class="text-peach font-semibold mb-1 mr-2">Discount Percentage (%) </span>
        <input value="" type="text" class="w-32 rounded-xl mb-1">
      </div>
      
      <!-- PROMO TYPE 3 : RPDISCOUNT -->
      <div class="flex items-center my-1">
        <span class="text-peach font-semibold mb-1 mr-2">Discount Percentage (Rp) </span>
        <input value="" type="text" class="w-32 rounded-xl mb-1">
      </div>
      
      <!-- PROMO TYPE 4 : BUY X, DISCOUNT% -->
      <div class="flex items-center my-1">
        <span class="text-peach font-semibold mb-1 mr-2">Buy Amount</span>
        <input value="" type="text" class="w-32 rounded-xl mb-1">
      </div>
      <div class="flex items-center my-1">
        <span class="text-peach font-semibold mb-1 mr-2">Discount Percentage (Rp) </span>
        <input value="" type="text" class="w-32 rounded-xl mb-1">
      </div>



      <!-- CHOOSE STORE (STORE LIST) -->
      <div class="flex flex-col my-1">
        <div class="flex items-center mb-1">
          <span class="text-peach font-semibold mr-2">Store List</span>
          <input value="null" class="border border-peach bg-darkGray" type="checkbox">
        </div>
        
        <!-- each -->
         <ul class="font-semibold text-white ml-2">
          <li class="mb-1">
            <div class="flex items-center">
              <input value="null" class="border border-white bg-darkGray  mr-2" type="checkbox">
              <span class="">nama store</span>
            </div>
          </li>
          <li class="mb-1">
            <div class="flex items-center">
              <input value="null" class="border border-white bg-darkGray  mr-2" type="checkbox">
              <span class="">nama store</span>
            </div>
          </li>
          <li class="mb-1">
            <div class="flex items-center">
              <input value="null" class="border border-white bg-darkGray  mr-2" type="checkbox">
              <span class="">nama store</span>
            </div>
          </li>
         </ul>
         <!--  -->
      </div>

      <!-- TIME START END -->
      <div class="flex items-center my-1">
        <span class="text-peach font-semibold mb-1 mr-2">Time Start</span>
        <input type="date" class="rounded-xl mb-1 w-60">
      </div>
      <div class="flex items-center my-1">
        <span class="text-peach font-semibold mb-1 mr-4">Time End</span>
        <input type="date" class="rounded-xl mb-1 w-60">
      </div>


      <div class="flex mt-8 items-center justify-center">
        <button class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
        <button class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Add</button>
      </div>
    </div>
  </TaskModal> 
  {/if}