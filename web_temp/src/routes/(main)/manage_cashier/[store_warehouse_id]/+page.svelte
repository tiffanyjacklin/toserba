<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { getFormattedDate, isInTimeRange } from '$lib/DateNow.js';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId } from '$lib/uri.js';

    export let data;
    let store_warehouse_id = data.store_warehouse_id;

    $: tampilan = "session"
    let searchQuery = '';
    
    let session = [];
    let filteredSessions = [];
    let transactions = [];
    let filteredTransactions = [];
  
    let user_otp = "";
    let last_update_time = getFormattedDate();
    
    let cash1 = 0;
    let showModal = null; 
    let showModal12 = null; 
    let showTable = false;
    let actual_closing_cash = 0;
    let actual_difference = 0;
    let deposit_money = 0;
    let deposit_difference = 0;
    let closing_notes = "";

    $: session.forEach(item => {
        item.actual_difference = item.actual_closing_cash - item.expected_closing_cash;
        item.deposit_difference = item.actual_closing_cash - item.deposit_money;
    });

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

    function navigateToTransaction(transactionId) {
        const url = `/manage_cashier/${store_warehouse_id}/${transactionId}`;
        goto(url);
    }
  
    onMount(async () => {
      await fetchSession();
      await fetchTransactions();
    });
  
    async function fetchSession() {
      const response = await fetch(`http://${$uri}:8888/sessions/store_warehouse/${store_warehouse_id}`, {
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

      session = data.data;
      filteredSessions = session;
    //   filteredSessions = data.data;
     console.log("session",filteredSessions);
   }
    
   async function fetchTransactions() {
      const response = await fetch(`http://${$uri}:8888/transaction/store_warehouse/${store_warehouse_id}`, {
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

      transactions = data.data;
      filteredTransactions = transactions;
    //   filteredSessions = data.data;
     console.log("transaction",filteredTransactions);
   }

   function isWithinThirtyMinutes(endTime) {
      const currentTime = new Date();
      const itemEndTime = new Date(endTime);

      // Add 30 minutes (30 * 60 * 1000 milliseconds) to the end time
      const endTimePlusThirtyMinutes = new Date(itemEndTime.getTime() + 30 * 60 * 1000);

      // Check if the current time is within the 30-minute window
      return currentTime <= endTimePlusThirtyMinutes;
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
      const response = await fetch(`http://${$uri}:8888/cashier/session/transaction/${sessionIdnya}`, {
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
      console.log(transactionByID);
   }

  </script>
  
   <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={() => goto('/manage_cashier')} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Cashier</span>
      
    <div class="w-11/12 my-10">
        <div class="flex">
            {#if tampilan == "session"}
                <button on:click={() => {tampilan = "session"; tampilan = tampilan;}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-48 py-2 rounded-2xl border-2 border-darkGray">Session</button>
                <button on:click={() => {tampilan = "transaction"; tampilan = tampilan;}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-48 py-2 rounded-2xl border-2 border-darkGray">Transaction</button>
            {:else if tampilan == "transaction"}
                <button on:click={() => {tampilan = "session"; tampilan = tampilan;}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-48 py-2 rounded-2xl border-2 border-darkGray">Session</button>
                <button on:click={() => {tampilan = "transaction"; tampilan = tampilan;}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-48 py-2 rounded-2xl border-2 border-darkGray">Transaction</button>
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

      {#if tampilan == "session"}
        {#each filteredSessions as item}
        <div class="bg-darkGray border-8 border-darkGray rounded-lg w-[96%] my-5">
            <div class=" flex">
                <div class="w-4/5 p-3 text-darkGray bg-white rounded-tl-lg rounded-bl-lg shadow-[inset_0_0_5px_rgba(0,0,0,0.6)]">
                <p class="text-2xl font-bold mb-3">Session #{item["Session"].session_id}</p>
                <p class="font-semibold">Session start: 
                    <DateConverter value={item["Session"].start_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                </p>
                {#if item.end_time === "0000-00-00 00:00:00" || item.end_time === "0001-01-01T00:00:00Z"}
                    <p class="font-semibold">Session close: -</p>
                {:else}
                    <p class="font-semibold">Session close: 
                        <DateConverter value={item["Session"].end_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                    </p>
                {/if}
                
                <div class="flex items-center my-2">
                    <i class="fa-regular fa-user fa-xl me-3" style="color: #364445;"></i>
                    <span class="font-semibold">{item["Session"].user_fullname}</span>
                </div>
                {#if (item["Session"].actual_closing_cash === 0)}
                    <div class="flex items-center my-2">
                        <i class="fa-solid fa-triangle-exclamation fa-xl me-3" style="color: #bf6a02;"></i>
                        <span class="font-bold text-peach2">WARNING: CLOSING CASH IS NOT INPUTTED!</span>
                    </div>
                {/if}
                
                </div>
                <div class="w-1/5 min-w-1/5 bg-darkGray flex items-center">
                {#if item["Session"].end_time && isWithinThirtyMinutes(item["Session"].end_time)}
                    <button 
                        on:click={async () => { 
                            handleClick(item["Session"].session_id); 
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
                {:else if ((item["Session"].end_time === "0000-00-00 00:00:00" || item["Session"].end_time === "0001-01-01T00:00:00Z") && item["Session"].user_id === Number($userId))}
                    <button 
                        on:click={() => backToTransaction(item["Session"].session_id)} 
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
                    <button on:click={() => {handleClick(item["Session"].session_id)}} class="border-8 bg-peach2 border-peach2 mx-6 my-2 rounded-lg w-full">
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
        {#each session as item}
            {#if (showModal == item["Session"].session_id)}
                <TaskModal open={showModal === item["Session"].session_id} onClose={closeModal} color={"#3d4c52"}>
                    <div class="flex items-center justify-center pt-8">
                    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Session #{item.session_id}</div>
                    </div>
                    {#if (item["Session"].end_time && isWithinThirtyMinutes(item["Session"].end_time))}
                    <form on:submit|preventDefault={VerifOTP(item["Session"].session_id)}>
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
                                <div class="text-white">{item["Session"].user_fullname}</div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Start time</div>
                                <div class="text-white">
                                    <DateConverter value={item["Session"].start_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                                </div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Closing time</div>
                                <div class="text-white">
                                    {#if item["Session"].end_time === "0000-00-00 00:00:00"}
                                        -
                                    {:else}
                                        <DateConverter value={item["Session"].end_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                                    {/if}
                                </div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Opening cash</div>
                                <div class="text-white">Rp {item["Session"].opening_cash.toLocaleString()}</div>
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
                                <div class="text-white">Rp {item["Session"].total_income.toLocaleString()}</div>
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
                                <div class="text-white">Rp {item["Session"].expected_closing_cash.toLocaleString()}</div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Actual closing cash</div>
                                <div class="text-white">Rp {item["Session"].actual_closing_cash.toLocaleString()}</div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Actual difference</div>
                                <div class="text-white">Rp {item["Session"].actual_difference.toLocaleString()}</div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Deposit money</div>
                                <div class="text-white">Rp {item["Session"].deposit_money.toLocaleString()}</div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Deposit Difference</div>
                                <div class="text-white">Rp {item["Session"].deposit_difference.toLocaleString()}</div>
                            </div>
                            <div class="text-[#f7d4b2]">
                                <div class="pb-3">Opening notes</div>
                                <textarea id="additional_notes" rows="4" class="min-h-24	shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item["Session"].opening_notes.toLocaleString()}" readonly></textarea>                    
                            </div>
                            <div class="text-[#f7d4b2]">
                                <div class="pb-3">Closing notes</div>
                                <textarea id="additional_notes" rows="4" class="min-h-24	shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item["Session"].closing_notes.toLocaleString()}" readonly></textarea>                    
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
            {:else if (showModal12 == item["Session"].session_id)}
                <TaskModal open={showModal12} onClose={() => closeModal()} color={"#3d4c52"}>
                    <div class="flex items-center justify-center pt-8">
                    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Session #{item["Session"].session_id}</div>
                    </div>
                    
                    <form class="p-4 md:p-5" >
                    <div class="grid gap-3 font-roboto font-semibold">
                        <div class="flex justify-between">
                            <div class="text-[#f7d4b2]">Cashier</div>
                            <div class="text-white">{item["Session"].user_fullname}</div>
                        </div>
                        <!-- part ini otomatis ya sob -->
                        <div class="flex justify-between">
                            <div class="text-[#f7d4b2]">Start time</div>
                            <div class="text-white">
                                <DateConverter value={item["Session"].start_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                            </div>
                        </div>
                        <div class="flex justify-between">
                            <div class="text-[#f7d4b2]">Closing time</div>
                            <div class="text-white">
                                {#if item["Session"].end_time === "0000-00-00 00:00:00"}
                                    -
                                {:else}
                                    <DateConverter value={item["Session"].end_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                                {/if}
                            </div>
                        </div>
                        <div class="flex justify-between">
                            <div class="text-[#f7d4b2]">Opening cash</div>
                            <div class="text-white"><MoneyConverter value={item["Session"].opening_cash} currency={true} decimal={true}/></div>
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
                            <div class="text-white"><MoneyConverter value={item["Session"].expected_closing_cash} currency={true} decimal={true}/></div>
                        </div>
                        <div class="flex justify-between">
                            <div class="text-[#f7d4b2]">Actual closing cash</div>
                                <MoneyInput bind:value={item["Session"].actual_closing_cash} />
                                </div>
                        <div class="flex justify-between">
                            <div class="text-[#f7d4b2]">Actual difference</div>
                            <div class="text-white"><MoneyConverter value={item.actual_difference} currency={true} decimal={true}/></div>
                        </div>
                        <div class="flex justify-between">
                            <div class="text-[#f7d4b2]">Deposit money</div>
                            <MoneyInput bind:value={item["Session"].deposit_money} />
                        </div>
                        <div class="flex justify-between">
                            <div class="text-[#f7d4b2]">Deposit Difference</div>
                            <div class="text-white"><MoneyConverter value={item["Session"].deposit_difference} currency={true} decimal={true}/></div>
                        </div>
                        <div class="text-[#f7d4b2]">
                            <div class="pb-3">Opening notes</div>
                            <textarea id="additional_notes" rows="4" class="min-h-24	shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item["Session"].opening_notes.toLocaleString()}" readonly></textarea>                    
                        </div>
                        <div class="text-[#f7d4b2]">
                            <div class="pb-3">Closing notes</div>
                            <textarea id="additional_notes" rows="4" class="min-h-24	shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item["Session"].closing_notes.toLocaleString()}"></textarea>                    
                        </div>
                
                        <div class="flex items-center justify-center">
                            <button
                            on:click={() => {
                                if (item["Session"].actual_closing_cash > 0 && item["Session"].deposit_money > 0) {
                                EditSession(item["Session"].session_id, item);
                                } else if (item["Session"].actual_closing_cash <= 0) {
                                Swal.fire({
                                    title: "Actual Closing Cash Invalid",
                                    text: "Actual Closing Cash should be above 0",
                                    icon: "error",
                                    color: "white",
                                    background: "#364445",
                                    confirmButtonColor: '#F2AA7E'
                                });
                                } else if (item["Session"].deposit_money <= 0) {
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
      {:else if tampilan == "transaction"}
        <div class="w-[96%] my-5">
            <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
                <table class="w-full text-sm text-left rtl:text-right">
                    <thead class="text-xs text-gray-700 uppercase bg-gray-5">
                        <tr class="border-b-2 border-black">
                            <th scope="col" class="px-6 py-3 text-sm font-bold">TRANSACTION ID</th>
                            <th scope="col" class="px-6 py-3 text-sm font-bold">DATE</th>
                            <th scope="col" class="px-6 py-3 text-sm font-bold">TIME</th>
                            <th scope="col" class="px-6 py-3 text-sm font-bold">TOTAL</th>
                            <th scope="col" class="px-6 py-3 text-sm font-bold">RESPONSIBLE PERSON</th>
                            <th scope="col" class="px-6 py-3 text-sm font-bold">DETAIL</th>
                        </tr>
                    </thead>
                    <tbody>
                        {#if filteredTransactions.length === 0}
                            <tr>
                                <td colspan="6" class="text-center py-4">No transactions found.</td>
                            </tr>
                        {:else}
                            {#each filteredTransactions as transaction, i}
                            <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                                <th scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">{transaction["Transaction"].transaction_id}</th>
                                <td class="px-6 py-4">
                                    <DateConverter value={transaction["Transaction"].transaction_timestamp} date={true} hour={false} dash={false} monthNumber={true}/>
                                </td>
                                <td class="px-6 py-4">
                                    <DateConverter value={transaction["Transaction"].transaction_timestamp} date={false} hour={true} ampm={true} second={false} />
                                </td>
                                <td class="px-6 py-4">
                                    <MoneyConverter value={transaction["Transaction"].transaction_total_price} currency={true} decimal={true}></MoneyConverter>
                                </td>
                                <td class="px-6 py-4">{transaction["Transaction"].transaction_user}</td>
                                <td class="py-2">
                                    <button class="py-2.5 border border-darkGray bg-peach rounded-lg font-bold text-darkGray w-full" on:click={() => navigateToTransaction(transaction["Transaction"].transaction_id)}>View</button>
                                </td>  
                            </tr>
                            {/each}
                        {/if}
                    </tbody>
                </table>
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