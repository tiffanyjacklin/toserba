<script>
   import TaskModal from '$lib/TaskModal.svelte';
   import MoneyInput from '$lib/MoneyInput.svelte';
   import MoneyConverter from '$lib/MoneyConverter.svelte';
   import DateConverter from '$lib/DateConverter.svelte';
   import { getFormattedDate, isInTimeRange } from '$lib/DateNow.js';
	import { goto } from '$app/navigation';
   import { onMount } from 'svelte';
   import { uri, userId, roleId, sessionId, totalAmount } from '$lib/uri.js';
   $: limit = 5; 
   $: offset = 0; 
   $: totalNotes = 10; 
   $: currentPage = 1; 
   $: totalPages = Math.ceil(totalNotes/limit);
   export let session_main_or_not = false;
   $: endDate = '';
   $: startDate = '';
   $: searchQuery = '';
   $: searchQuery_temp = '';
   let showFilter = false;

   function toggleFilter() {
      showFilter = !showFilter;
   }
   let filteredSessions = [];

   let user_otp = "";
   let selectedItem = null;
   let last_update_time = getFormattedDate();
   // let last_session = session.filter(s => s.user_id === Number(userId)).reduce((maxSession, currentSession) => (currentSession.session_id > maxSession.session_id) ? currentSession : maxSession, { session_id: -1 });
   
   // console.log(last_session);
   let cash1 = 0;
   let showModal = null; 
   let showModal12 = null; 
   let showTable = false;
   let actual_closing_cash = 0;
   let actual_difference = 0;
   let deposit_money = 0;
   let deposit_difference = 0;
   let closing_notes = "";
   let cashiers = [];
   let cashier_name = '';
   $: session.forEach(item => {
      item.actual_difference = item.actual_closing_cash - item.expected_closing_cash;
      item.deposit_difference = item.actual_closing_cash - item.deposit_money;
   });
   let session = [];
   async function fetchSession() {
      const response = await fetch(`http://${$uri}:8888/cashier/session/${startDate}/${endDate}/${cashier_name}/${searchQuery}/${limit}/${offset}`, {
         method: 'GET',
         headers: {
               'Content-Type': 'application/json'
         }
      });

      if (!response.ok) {
         console.error(' session fetch failed', response);
         return;
      }

      const data = await response.json();

      if (data.status !== 200) {
         console.error('Invalid fetch ', data);
         return;
      }
      totalNotes = data.total_rows;
      totalPages = Math.ceil(totalNotes/limit);
      session = data.data;
      filteredSessions = session;
   //   console.log(session);
   }
   async function fetchCashiers() {
      const response = await fetch(`http://${$uri}:8888/user/roles/data/1`, {
         method: 'GET',
         headers: {
               'Content-Type': 'application/json'
         }
      });

      if (!response.ok) {
         console.error(' session fetch failed', response);
         return;
      }

      const data = await response.json();

      if (data.status !== 200) {
         console.error('Invalid fetch ', data);
         return;
      }

      cashiers = data.data;
   //   console.log(session);
   }

   async function goToPage(page) {
      if (page < 1 || page > Math.ceil(totalNotes / limit)) return;

      currentPage = page;
      offset = (currentPage - 1) * limit;
      await fetchSession();
    }
   $: if ((searchQuery_temp !== searchQuery) ){
      console.log(searchQuery);
      fetchSession();
      searchQuery_temp = searchQuery;
    } else{
      searchQuery_temp = '';
    }

   onMount(async () => {
      await fetchSession();
      await fetchCashiers();
   });
   // INI BUTUH DIGANTI BUAT REDIRECT BALIK KE PAGE TRANSAKSI YA BOS!! BUTUH UPDATE
   async function backToTransaction(last_session){
      sessionId.set(String(last_session));
      closeModal();
      await fetchSession();
      goto(`/session_main`);
   }
   function isWithinThirtyMinutes(endTime) {
      const currentTime = new Date();
      const itemEndTime = new Date(endTime);

      // Add 30 minutes (30 * 60 * 1000 milliseconds) to the end time
      const endTimePlusThirtyMinutes = new Date(itemEndTime.getTime() + 30 * 60 * 1000);

      // Check if the current time is within the 30-minute window
      return currentTime <= endTimePlusThirtyMinutes;
   }
   function isTimeValid(closingTime) {
        return isInTimeRange(closingTime);
   }
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
   async function sendOTP() {
         const response = await fetch(`http://${$uri}:8888/cashier/session/edit/sendotp/${$userId}`, {
               method: 'PUT'
         });

         if (!response.ok) {
               console.error('PUT send otp gagal', response);
               return;
         }

         const data = await response.json();

         if (data.status !== 200) {
               console.error('Invalid PUT send otp', data);
               return;
         }
         console.log(data);
   }
   async function VerifOTP(session_id) {
      //   console.log("Sending OTP:", user_otp);  // Log the OTP value
        const response = await fetch(`http://${$uri}:8888/cashier/session/edit/verifotp/${$userId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
               user_otp,
            })
        });

        if (!response.ok) {
            console.error('PUT verif otp gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid PUT verif otp', data);
            Swal.fire({
               title: "Invalid OTP",
               text: "The inputted OTP is wrong. Please try again.",
               icon: "error",
               color: "white",
               background: "#364445",
               confirmButtonColor: '#F2AA7E'
            });
            return;
        }
        closeModal();

        showModal12 = session_id;

        console.log(data);
   }
   function validateAndSubmit(id) {
      if (actual_closing_cash <= 0) {
         Swal.fire({
         title: "Actual Closing Cash Invalid",
         text: "Actual Closing Cash harus lebih besar dari 0",
         icon: "error",
         color: "white",
         background: "#364445",
         confirmButtonColor: '#F2AA7E'
         });
         return;
      }
      
      if (deposit_money <= 0) {
         Swal.fire({
         title: "Deposit Money Invalid",
         text: "Deposit Money harus lebih besar dari 0",
         icon: "error",
         color: "white",
         background: "#364445",
         confirmButtonColor: '#F2AA7E'
         });
         return;
      }

      // Continue with the process (e.g., NewSession)
      // NewSession();
      EditSession(id);
   }
   async function EditSession(session_id, item) {
        try {
            const response = await fetch(`http://${$uri}:8888/cashier/session/edit/${session_id}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    "last_update_time": last_update_time, // Example for current time
                    "actual_closing_cash": item.actual_closing_cash,
                    "actual_difference": item.actual_difference,
                    "deposit_money": item.deposit_money,
                    "deposit_difference": item.deposit_difference,
                    "closing_notes": item.closing_notes
                })
            });

            if (!response.ok) {
                const errorDetails = await response.text();
                console.error('EditSession failed:', response.status, response.statusText, errorDetails);
                Swal.fire({
                    title: "Error",
                    text: `EditSession failed: ${response.statusText}`,
                    icon: "error",
                    confirmButtonColor: '#F2AA7E'
                });
                return;
            }

            // Handle successful response
            console.log('Session updated successfully');
            closeModal();
        } catch (error) {
            console.error('Request failed:', error);
            Swal.fire({
                title: "Error",
                text: `Request failed: ${error.message}`,
                icon: "error",
                confirmButtonColor: '#F2AA7E'
            });
        }
   }
   let transactionByID = [];
   async function fetchTransactionBySession(sessionIdnya) {
      const response = await fetch(`http://${$uri}:8888/cashier/session/transaction/${sessionIdnya}///////0/0`, {
         method: 'GET',
         headers: {
               'Content-Type': 'application/json'
         }
      });

      if (!response.ok) {
         console.error('transaction by id fetch failed', response);
         return;
      }

      const data = await response.json();

      if (data.status !== 200) {
         console.error('Invalid fetch transaction by id ', data);
         return;
      }

      transactionByID = data.data;
      // console.log(transactionByID);
   }
 </script>
 
 <div class={`mx-8 ${session_main_or_not ? '' : 'mt-[90px]'} mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] rounded-lg`}>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Session History</span>

    <!-- <form class="flex items-center max-w-lg mx-auto">    -->
       <label for="voice-search" class="sr-only">Search</label>
       <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
         <input 
         type="text" 
         id="voice-search" 
         class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
         placeholder="Search by Session ID or Cashier's name..."
         bind:value={searchQuery} />          
         <button on:click={toggleFilter}
              type="button" 
              class="absolute inset-y-0 end-0 flex items-center pe-3 ">
              <i class="fa-solid fa-sliders fa-xl mr-2"></i>
          </button>
          {#if showFilter}
              <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-fit  bg-gray-100 p-4 rounded-lg font-roboto">
                <span class="font-bold text-xl mb-1">Join Date Period</span>

                <div class="flex gap-x-4 w-full items-center">
                  <span class="font-semibold text-lg mb-4">From</span>
                  <input type="date" bind:value={startDate} class="rounded-xl w-32 mb-4 p-2 border" />
                  <span class="font-semibold text-lg mb-4">To</span>
                  <input type="date" bind:value={endDate} class="rounded-xl w-32 mb-4 p-2 border" />
                </div>

                <span class="font-bold text-xl mb-1">Cashier</span>
                <div class="flex gap-x-4 w-full items-center">
                  {#each cashiers as cashier}
                     <button on:click={() => {cashier_name = (cashier_name === '' || cashier_name !== cashier.user_id) ? cashier.user_id : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:bg-white hover:border hover:border-peach2 hover:text-peach2 ${cashier_name === cashier.user_id ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>{cashier.user_fullname}</button>

                  {/each}
               </div>

                <div class="flex justify-between font-semibold mt-4">
                    <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { startDate = ""; endDate = ""; cashier_name = ""; }}>Clear</button>
                    <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {fetchSession(); showFilter = false;}}>Apply</button>
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
    
   {#each filteredSessions as item}
   <div class="bg-darkGray border-8 border-darkGray rounded-lg w-[96%] my-5">
      <div class=" flex">
         <div class="w-4/5 p-3 text-darkGray bg-white rounded-tl-lg rounded-bl-lg shadow-[inset_0_0_5px_rgba(0,0,0,0.6)]">
            <p class="text-2xl font-bold mb-3">Session #{item.session_id}</p>
            <p class="font-semibold">Session start: 
               <DateConverter value={item.start_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
            </p>
            {#if item.end_time === "0000-00-00 00:00:00" || item.end_time === "0001-01-01T00:00:00Z"}
               <p class="font-semibold">Session close: -</p>
            {:else}
               <p class="font-semibold">Session close: 
                  <DateConverter value={item.end_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
               </p>
            {/if}
            
            <div class="flex items-center my-2">
               <i class="fa-regular fa-user fa-xl me-3" style="color: #364445;"></i>
               <span class="font-semibold">{item.user_fullname}</span>
            </div>
            {#if (item.actual_closing_cash === 0)}
               <div class="flex items-center my-2">
                  <i class="fa-solid fa-triangle-exclamation fa-xl me-3" style="color: #bf6a02;"></i>
                  <span class="font-bold text-peach2">WARNING: CLOSING CASH IS NOT INPUTTED!</span>
               </div>
            {/if}
            
         </div>
         <div class="w-1/5 min-w-1/5 bg-darkGray flex items-center">
   
            {#if (item.end_time && isWithinThirtyMinutes(item.end_time) && Number($roleId) === 1 && item.user_id === Number($userId))}
               <button 
                  on:click={async () => { 
                     handleClick(item.session_id); 
                     await sendOTP(); 
                  }} 
                  class="border-8 bg-peach2 border-peach2 mx-6 my-2 rounded-lg w-full">
                  <div class="bg-peach rounded-lg flex flex-col min-h-40 w-full items-center justify-center shadow-[inset_0_0_5px_rgba(0,0,0,0.6)]">
                     <span class="text-2xl text-darkGray mb-2 font-bold">Edit</span>
                     <div class="outline outline-[2px] rounded p-1.5 outline-[#364445]">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-7">
                           <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                        </svg>
                     </div>
                  </div>
               </button>
            {:else if ((item.end_time === "0000-00-00 00:00:00" || item.end_time === "0001-01-01T00:00:00Z") && Number($userId) === 1 && item.user_id === Number($userId))}
               <button 
                  on:click={() => backToTransaction(item.session_id)} 
                  class="border-8 bg-peach2 border-peach2 mx-6 my-2 rounded-lg w-full">
                  <div class="bg-peach rounded-lg flex flex-col min-h-40 w-full items-center justify-center shadow-[inset_0_0_5px_rgba(0,0,0,0.6)]">
                     <span class="text-2xl text-darkGray mb-2 font-bold">Continue</span>
                     <div class="outline outline-[2px] rounded p-1.5 outline-[#364445]">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-7">
                           <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                        </svg>
                     </div>
                  </div>
               </button>
            {:else}
               <button on:click={() => handleClick(item.session_id)} class="border-8 bg-peach2 border-peach2 mx-6 my-2 rounded-lg w-full">
                  <div class="bg-peach rounded-lg flex flex-col min-h-40 w-full items-center justify-center shadow-[inset_0_0_5px_rgba(0,0,0,0.6)]">
                     <span class="text-2xl text-darkGray mb-2 font-bold">View</span>
                     <div class="outline outline-[2px] rounded p-1.5 outline-[#364445]">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-7">
                           <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
                        </svg>
                     </div>
                  </div>
               </button>
            {/if}           
         </div>
      </div>
   </div>
   {/each}
   {#if filteredSessions.length === 0}
   <div class="justify-center w-full h-full flex rounded-xl py-4 my-3 ">
      No session found.
    </div>
   {/if}
   
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
   
   
   {#each session as item}
      {#if (showModal === item.session_id)}
         <TaskModal open={showModal === item.session_id} onClose={closeModal} color={"#3d4c52"}>
            <div class="flex items-center justify-center pt-8">
               <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Session #{item.session_id}</div>
            </div>
            
            {#if (item.end_time && isWithinThirtyMinutes(item.end_time))}
               <form on:submit|preventDefault={VerifOTP(item.session_id)}>
                  <div class="px-4 pb-4 flex flex-col">
                     <div class="my-10 flex flex-col">
                        <span class="text-peach font-bold text-lg mb-2">Enter 6-digit OTP code</span>
                        <input id="user_otp" name="user_otp" type="text" class="rounded-lg p-2 focus:ring-2 focus:ring-peach" bind:value={user_otp}>
                     </div>
                     <button type="submit" class="w-fit px-16 py-2 bg-peach text-darkGray font-bold text-2xl mx-auto rounded-lg">Edit</button>
                  </div>
               </form>
            {:else}
               <form class=" mt-8 p-4 md:p-5">
                  <div class="grid gap-3 font-roboto font-semibold">
                     <div class="flex justify-between">
                        <div class="text-[#f7d4b2]">Cashier</div>
                        <div class="text-white">{item.user_fullname}</div>
                     </div>
                     <div class="flex justify-between">
                        <div class="text-[#f7d4b2]">Start time</div>
                        <div class="text-white">
                              <DateConverter value={item.start_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                        </div>
                     </div>
                     <div class="flex justify-between">
                        <div class="text-[#f7d4b2]">Closing time</div>
                        <div class="text-white">
                              {#if item.end_time === "0000-00-00 00:00:00"}
                                 -
                              {:else}
                                 <DateConverter value={item.end_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                              {/if}
                        </div>
                     </div>
                     <div class="flex justify-between">
                        <div class="text-[#f7d4b2]">Opening cash</div>
                        <div class="text-white">Rp {item.opening_cash.toLocaleString()}</div>
                     </div>
                     <div class="flex justify-between">
                        <div class="text-[#f7d4b2]">Total Income
                           {#if transactionByID.length > 0}
                           <button on:click={toggleTable} class="ml-2">
                              {#if showTable}
                                 <i class="fa-solid fa-caret-up"></i>
                              {:else}
                                 <i class="fa-solid fa-caret-down"></i>
                              {/if}
                           </button>
                           {/if}
                        </div>
                        <div class="text-white">Rp {item.total_income.toLocaleString()}</div>
                     </div>
                     {#if showTable && transactionByID.length > 0}
                     <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
                        <table class="w-full text-sm text-left rtl:text-right">
                           <thead class="text-xs text-gray-700 uppercase bg-gray-100">
                                 <tr class="border-b-2 border-black">
                                    <th scope="col" class="px-6 py-3 text-sm font-bold">
                                       TRANSACTION ID
                                    </th>
                                    <th scope="col" class="px-6 py-3 text-sm font-bold">
                                       DATE
                                    </th>
                                    <th scope="col" class="px-6 py-3 text-sm font-bold">
                                       TIME
                                    </th>
                                    <th scope="col" class="px-6 py-3 text-sm font-bold">
                                       TOTAL
                                    </th>
                                 </tr>
                           </thead>
                           <tbody>
                              {#each transactionByID as transaction, i}
                                 <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                                    <th scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">
                                          {transaction.transaction_id}
                                    </th>
                                    <td class="px-6 py-4">
                                       <DateConverter value={transaction.transaction_timestamp} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                                    </td>
                                    <td class="px-6 py-4">
                                       <DateConverter value={transaction.transaction_timestamp} date={false} hour={true} second={false} ampm={true} monthNumber={false} dash={false} dateFirst={false}/>
                                    </td>
                                    <td class="px-6 py-4">
                                       <MoneyConverter value={transaction.transaction_total_price} currency={true} decimal={true}/>
                                    </td>
                                 </tr>
                              {/each}
                           </tbody>
                        </table>
                     </div>
                     {/if}
                     <div class="flex justify-between">
                        <div class="text-[#f7d4b2]">Expected closing cash</div>
                        <div class="text-white">Rp {item.expected_closing_cash.toLocaleString()}</div>
                     </div>
                     <div class="flex justify-between">
                        <div class="text-[#f7d4b2]">Actual closing cash</div>
                        <div class="text-white">Rp {item.actual_closing_cash.toLocaleString()}</div>
                     </div>
                     <div class="flex justify-between">
                        <div class="text-[#f7d4b2]">Actual difference</div>
                        <div class="text-white">Rp {item.actual_difference.toLocaleString()}</div>
                     </div>
                     <div class="flex justify-between">
                        <div class="text-[#f7d4b2]">Deposit money</div>
                        <div class="text-white">Rp {item.deposit_money.toLocaleString()}</div>
                     </div>
                     <div class="flex justify-between">
                           <div class="text-[#f7d4b2]">Deposit Difference</div>
                           <div class="text-white">Rp {item.deposit_difference.toLocaleString()}</div>
                     </div>
                     <div class="text-[#f7d4b2]">
                        <div class="pb-3">Opening notes</div>
                        <textarea id="additional_notes" rows="4" class="min-h-24	shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item.opening_notes.toLocaleString()}" readonly></textarea>                    
                     </div>
                     <div class="text-[#f7d4b2]">
                        <div class="pb-3">Closing notes</div>
                        <textarea id="additional_notes" rows="4" class="min-h-24	shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item.closing_notes.toLocaleString()}" readonly></textarea>                    
                     </div>

                     <div class="flex items-center justify-center">
                        <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                           Close
                        </button>
                     </div>
                  </div>
               </form>
            {/if}
         </TaskModal>
      {:else if (showModal12 === item.session_id)}
         <TaskModal open={showModal12} onClose={() => closeModal()} color={"#3d4c52"}>
            <div class="flex items-center justify-center pt-8">
               <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Session #{item.session_id}</div>
            </div>
            
            <form class="p-4 md:p-5" >
               <div class="grid gap-3 font-roboto font-semibold">
                  <div class="flex justify-between">
                     <div class="text-[#f7d4b2]">Cashier</div>
                     <div class="text-white">{item.user_fullname}</div>
                  </div>
                  <!-- part ini otomatis ya sob -->
                  <div class="flex justify-between">
                     <div class="text-[#f7d4b2]">Start time</div>
                     <div class="text-white">
                           <DateConverter value={item.start_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                     </div>
                  </div>
                  <div class="flex justify-between">
                     <div class="text-[#f7d4b2]">Closing time</div>
                     <div class="text-white">
                           {#if item.end_time === "0000-00-00 00:00:00"}
                              -
                           {:else}
                              <DateConverter value={item.end_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                           {/if}
                     </div>
                  </div>
                  <div class="flex justify-between">
                     <div class="text-[#f7d4b2]">Opening cash</div>
                     <div class="text-white"><MoneyConverter value={item.opening_cash} currency={true} decimal={true}/></div>
                  </div>
                  <div class="flex justify-between">
                     <div class="text-[#f7d4b2]">Total Income
                        {#if transactionByID.length > 0}
                        <button on:click={toggleTable} class="ml-2">
                           {#if showTable}
                              <i class="fa-solid fa-caret-up"></i>
                           {:else}
                              <i class="fa-solid fa-caret-down"></i>
                           {/if}
                        </button>
                        {/if}
                     </div>
                     <div class="text-white"><MoneyConverter value={item.total_income} currency={true} decimal={true}/></div>
                  </div>
            
                  {#if showTable && transactionByID.length > 0}
                  <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
                     <table class="w-full text-sm text-left rtl:text-right">
                        <thead class="text-xs text-gray-700 uppercase bg-gray-100">
                              <tr class="border-b-2 border-black">
                                 <th scope="col" class="px-6 py-3 text-sm font-bold">
                                    TRANSACTION ID
                                 </th>
                                 <th scope="col" class="px-6 py-3 text-sm font-bold">
                                    DATE
                                 </th>
                                 <th scope="col" class="px-6 py-3 text-sm font-bold">
                                    TIME
                                 </th>
                                 <th scope="col" class="px-6 py-3 text-sm font-bold">
                                    TOTAL
                                 </th>
                              </tr>
                        </thead>
                        <tbody>
                           {#each transactionByID as transaction, i}
                              <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                                 <th scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">
                                       {transaction.transaction_id}
                                 </th>
                                 <td class="px-6 py-4">
                                    <DateConverter value={transaction.transaction_timestamp} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                                 </td>
                                 <td class="px-6 py-4">
                                    <DateConverter value={transaction.transaction_timestamp} date={false} hour={true} second={false} ampm={true} monthNumber={false} dash={false} dateFirst={false}/>
                                 </td>
                                 <td class="px-6 py-4">
                                    <MoneyConverter value={transaction.transaction_total_price} currency={true} decimal={true}/>
                                 </td>
                              </tr>
                           {/each}
                        </tbody>
                     </table>
                  </div>
                  {/if}

                  <div class="flex justify-between">
                     <div class="text-[#f7d4b2]">Expected closing cash</div>
                     <div class="text-white"><MoneyConverter value={item.expected_closing_cash} currency={true} decimal={true}/></div>
                  </div>
                  <div class="flex justify-between">
                     <div class="text-[#f7d4b2]">Actual closing cash</div>
                        <MoneyInput bind:value={item.actual_closing_cash} />
                        </div>
                  <div class="flex justify-between">
                     <div class="text-[#f7d4b2]">Actual difference</div>
                     <div class="text-white"><MoneyConverter value={item.actual_difference} currency={true} decimal={true}/></div>
                  </div>
                  <div class="flex justify-between">
                     <div class="text-[#f7d4b2]">Deposit money</div>
                     <MoneyInput bind:value={item.deposit_money} />
                  </div>
                  <div class="flex justify-between">
                     <div class="text-[#f7d4b2]">Deposit Difference</div>
                     <div class="text-white"><MoneyConverter value={item.deposit_difference} currency={true} decimal={true}/></div>
                  </div>
                  <div class="text-[#f7d4b2]">
                     <div class="pb-3">Opening notes</div>
                     <textarea id="additional_notes" rows="4" class="min-h-24	shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item.opening_notes.toLocaleString()}" readonly></textarea>                    
                  </div>
                  <div class="text-[#f7d4b2]">
                     <div class="pb-3">Closing notes</div>
                     <textarea id="additional_notes" rows="4" class="min-h-24	shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item.closing_notes.toLocaleString()}"></textarea>                    
                  </div>
         
                  <div class="flex items-center justify-center">
                     <button
                     on:click={() => {
                        if (item.actual_closing_cash > 0 && item.deposit_money > 0) {
                          EditSession(item.session_id, item);
                        } else if (item.actual_closing_cash <= 0) {
                          Swal.fire({
                            title: "Actual Closing Cash Invalid",
                            text: "Actual Closing Cash should be above 0",
                            icon: "error",
                            color: "white",
                            background: "#364445",
                            confirmButtonColor: '#F2AA7E'
                          });
                        } else if (item.deposit_money <= 0) {
                          Swal.fire({
                            title: "Deposit Money Invalid",
                            text: "Deposit Money should be above 0",
                            icon: "error",
                            color: "white",
                            background: "#364445",
                            confirmButtonColor: '#F2AA7E'
                          });
                        }
                      }}
                        type="submit" 
                        class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center ">
                        Save
                     </button>
                  </div>
               </div>
            </form>
         </TaskModal>
      {/if}
      
   {/each}
  
   
 </div>
