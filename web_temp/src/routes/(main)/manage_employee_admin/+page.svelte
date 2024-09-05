<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { getFormattedDate, isInTimeRange } from '$lib/DateNow.js';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId } from '$lib/uri.js';
    import user_pp from "$lib/assets/user.png";

    let searchQuery = '';
    $: tampilan = "manage";
    $: showModal = null;

    let handled_store = [];
    let users = [];

    let showFilter = false;

    function toggleFilter() {
        showFilter = !showFilter;
    }
   function handleClick(sessionId) {
      showModal = sessionId;
      fetchTransactionBySession(sessionId);
   }
   function closeModal() {
        showModal = null;
        showModal12 = null;
   }

   async function fetchUsers(){
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
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Employees</span>

        <div class="w-11/12 flex items-center">
            <div class="relative w-9/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg mr-4">
                <input 
                    type="text" 
                    id="voice-search" 
                    bind:value={searchQuery}
                    class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                    placeholder="Search..."/>
                <button on:click={toggleFilter}
                    type="button" 
                    class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                    <i class="fa-solid fa-sliders fa-xl mr-2"></i>
                </button>
                {#if showFilter}
                    <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-3/4 bg-gray-100 p-4 rounded-lg font-roboto">
                    <span class="font-bold text-xl mb-1">Join Date</span>
                    <div class="flex">
                        <div class="w-1/2 flex items-center justify-end pr-2">
                            <label class="block font-semibold text-gray-700 mr-2">From</label>
                            <input type="date" class="w-32 p-2 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] rounded-xl" />
                        </div>
                        <div class="w-1/2 flex items-center">
                            <label class="block font-semibold text-gray-700 mr-2">to</label>
                            <input type="date" class="w-32 p-2 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] rounded-xl" />
                        </div>
                    </div>

                    <span class="font-bold text-xl mb-1">Role</span>
                    <div class="flex w-full flex-wrap">
                        <button class="w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 focus:border-peach2 focus:text-peach2">AWFAWFAWGAWGAW</button>
                        <button class="w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 focus:border-peach2 focus:text-peach2">wkwkwkw</button>
                        <button class="w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 focus:border-peach2 focus:text-peach2">gogogolgoglgolgoggllogoglggsgsfsfsgsaga</button>
                    </div>
                    
                    <span class="font-bold text-xl mb-1">Gender</span>
                    <div class="flex w-full flex-wrap">
                        <button class="w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 focus:border-peach2 focus:text-peach2">Male</button>
                        <button class="w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 focus:border-peach2 focus:text-peach2">Female</button>
                    </div>
                    
                    <div class="flex justify-between font-semibold mt-4">
                        <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { startDate = ''; endDate = ''; }}>Clear</button>
                        <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={toggleDatePicker}>Apply</button>
                    </div>
                    </div>
                {/if}
            </div>
            <div class="relative w-3/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-xl">
                <button on:click={() => {showModal = "add_employee"}} class="w-full py-4 rounded-xl bg-peach font-semibold text-lg text-darkGray border-2 border-darkGray"><i class="fa-solid fa-plus mr-2"></i>Add New Employee</button>
            </div>
        </div>
         
        <div class="w-11/12 my-10">
            <div class="grid grid-cols-4 gap-x-2 gap-y-4">
                {#if tampilan == "manage"}
                    <button on:click={() => {tampilan = "manage"; tampilan = tampilan;}} class="bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Manage Employee</button>
                {:else}
                    <button on:click={() => {tampilan = "manage"; tampilan = tampilan;}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Manage Employee</button>
                {/if}
                {#if tampilan == "edit"}
                    <button on:click={() => {tampilan = "edit"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Edit Role & Privilege</button>
                {:else}
                    <button on:click={() => {tampilan = "edit"; tampilan = tampilan;}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Edit Role & Privilege</button>
                {/if}
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

      {#if tampilan == "manage"}
      <button class="w-[96%] my-5 font-roboto">
        <div class="relative overflow-x-auto sm:rounded-lg">
          <!-- {#each all_produk as product} -->
                <div class="flex items-center border-2 rounded-xl ml-auto border-gray-700 m-3">                        
                    <div class="m-4 w-1/12 flex">
                        <img class="rounded-lg border border-darkGray" src={user_pp} alt="">
                    </div>
                    <div class="flex flex-col items-start font-semibold text-lg">
                        <span class="">INI NAMANYA</span>
                        <span class="">INI ROLENYA</span>
                        <span class="">Join Date: XX/XX/20XX</span>
                    </div>
                </div>
            <!-- {/each} -->
        </div>
    </button>
     {:else if tampilan == "edit"}
     <div class="w-[96%] my-5 font-roboto">
        <div class="relative overflow-x-auto sm:rounded-lg">
          <!-- {#each all_produk as product} -->
                <div class="flex items-center border-2 rounded-xl ml-auto border-gray-700 m-3 pr-4">                        
                    <div class="m-4 w-1/12 flex">
                        <img class="rounded-lg border border-darkGray" src={user_pp} alt="">
                    </div>
                    <div class="w-9/12 flex flex-col font-semibold text-lg">
                        <span class="">NAMA ROLE</span>
                        <span class="">Default XXX</span>
                    </div>
                    <div class="w-2/12 flex justify-end items-center">
                        <button on:click={() => goto(``)} class="p-4 bg-peach text-darkGray rounded-xl flex items-center"><svg width="56" height="54" viewBox="0 0 56 54" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M2.33594 27C2.33594 27 11.6693 9 28.0026 9C44.3359 9 53.6693 27 53.6693 27C53.6693 27 44.3359 45 28.0026 45C11.6693 45 2.33594 27 2.33594 27Z" stroke="#3E4E50" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M28.0026 33.75C31.8686 33.75 35.0026 30.7279 35.0026 27C35.0026 23.2721 31.8686 20.25 28.0026 20.25C24.1366 20.25 21.0026 23.2721 21.0026 27C21.0026 30.7279 24.1366 33.75 28.0026 33.75Z" stroke="#3E4E50" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                                                       
                          </button>
                      </div>
                </div>
            <!-- {/each} -->
        </div>
     </div>
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

   <!-- ADD NEW EMPLOYEE -->
{#if showModal == "add_employee" }
<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Choose Product</div>
  </div>
  <div class="flex flex-col justify-center p-8">
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Employee Full Name</span>
      <input type="text" value="nama employee baru" class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
    </div>
    <div class="flex flex-col my-2">
        <span class="text-peach font-semibold mb-1">Employee Role</span>
        <select class="w-full p-2 rounded-xl">
            <option value="">Cashier</option>
            <option value="" >Admin</option>
        </select>
    </div>
    <div class="flex my-2">
        <div class="flex flex-col my-2 w-1/2 pr-1">
            <span class="text-peach font-semibold mb-1">Employee Email</span>
            <input type="text" value="Employee Email" class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
        <div class="flex flex-col my-2 w-1/2 pl-1">
            <span class="text-peach font-semibold mb-1">Employee Phone</span>
            <input type="text" value="Employee Phone" class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
    </div>
    <div class="flex my-2">
        <div class="flex flex-col my-2 w-1/2 pr-1">
            <span class="text-peach font-semibold mb-1">Employee Username</span>
            <input type="text" value="Employee Username" class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
        <div class="flex flex-col my-2 w-1/2 pl-1">
            <span class="text-peach font-semibold mb-1">Employee Password</span>
            <input type="text" value="Employee Password" class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
    </div>
    <div class="flex flex-col my-2">
        <span class="text-peach font-semibold mb-1">Employee Address</span>
        <textarea rows="4" type="text" value="nama employee baru" class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2"></textarea>
    </div>
    <div class="flex my-2">
        <div class="flex flex-col my-2 w-1/2 pr-1">
            <span class="text-peach font-semibold mb-1">Employee Gender</span>
            <select class="p-2 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                <option value="male">Male</option>
                <option value="female">Female</option>
            </select>        </div>
        <div class="flex flex-col my-2 w-1/2 pl-1">
            <span class="text-peach font-semibold mb-1">Employee Birthday</span>
            <input type="date" class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
    </div>

    <div class="flex flex-col my-1">
      <span class="text-peach font-semibold mb-1">Assigned Location</span>
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
    </div>
    <div class="flex mt-8 items-center justify-center">
      <button class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
      <button class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Add</button>
    </div>
  </div>
</TaskModal> 
{/if}