<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
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
    let searchQueryAll = '';
    let searchQueryTrans = '';

    $: limit = 10; 
    $: offset = 0;
    $: currentPage = 1; 
    $: totalRows = 0;
    
    let sessionNotVerified = [];
    let filteredSessionsNot = [];
    let all_session = [];
    let filteredSessions = [];
    let transactions = [];
    let filteredTransactions = [];
    
    let showModal = null; 
    let showModal12 = null; 
    let showTable = false;

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
  
    async function fetchSessionNotVerified() {
      const response = await fetch(`http://${$uri}:8888/sessions/not_verified`, {
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

      sessionNotVerified = data.data;
      filteredSessionsNot = structuredClone(sessionNotVerified);
    //   filteredSessions = data.data;
    //  console.log("not",filteredSessionsNot);
   }
    
   async function fetchAllSWSession() {
      const response = await fetch(`http://${$uri}:8888/sessions/store_warehouse/${store_warehouse_id}/${limit}/${offset}`, {
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

    totalRows = data.data.length;
    all_session = data.data;
    filteredSessions = structuredClone(all_session);
    console.log("all session",data);
   }
    
   async function fetchTransactions() {
      const response = await fetch(`http://${$uri}:8888/transaction/store_warehouse/${store_warehouse_id}/${limit}/${offset}`, {
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

      totalRows = data.total_rows;
      transactions = data.data;
      filteredTransactions = structuredClone(transactions);
     console.log("transaction",data);
   }

   let transactionByID = [];
   async function fetchTransactionBySession(sessionIdnya) {
      const response = await fetch(`http://${$uri}:8888/cashier/session/transaction/${sessionIdnya}/''/100/0`, {
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
    //   console.log(transactionByID);
   }

   async function verifySession(session_id, actual_closing_cash, deposit_money) {
        const response = await fetch(`http://${$uri}:8888/sessions/verify/${session_id}`, {
            method: 'PUT',
            headers: {
                    'Content-Type': 'application/json',
                },
            body: JSON.stringify({
                actual_closing_cash,
                deposit_money
            })
        });

        if (!response.ok) {
            console.error('PUT verify session gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid put verify session', data);
            return;
        }
        console.log("verify session :",data);
      }
   
    async function verify(session_id, actual_closing_cash, deposit_money) {
        await verifySession(session_id,actual_closing_cash,deposit_money)
        Swal.fire({
                      title: "Session Berhasil di verify",
                      icon: "success",
                      color: "white",
                      background: "#364445",
                      confirmButtonColor: '#F2AA7E'
                    });
        closeModal();
      }

    async function goToPage(page) {
        if (page < 1 || page > Math.ceil(totalRows / limit)) return;

        currentPage = page;
        offset = (currentPage - 1) * limit;
        if (tampilan == "session_all"){
            await fetchAllSWSession();
        } else if (tampilan == "transaction"){
            await fetchTransactions();
        }
    }

    $: if (searchQuery.length > 0) {
        filteredSessionsNot = sessionNotVerified.filter(item => 
            item.Session.session_id.toString().includes(searchQuery) || 
            item.Session.user_fullname.toLowerCase().includes(searchQuery.toLowerCase())
        );
    } else {
        filteredSessionsNot = [...sessionNotVerified];
    }
    
    $: if (searchQueryAll.length > 0) {
        filteredSessions = all_session.filter(item => 
            item.Session.session_id.toString().includes(searchQueryAll) || 
            item.Session.user_fullname.toLowerCase().includes(searchQueryAll.toLowerCase())
        );
    } else {
        filteredSessions = [...all_session];
    }
   
    $: if (searchQueryTrans.length > 0) {
        filteredTransactions = transactions.filter(item => 
            item.Transaction.transaction_id.toString().includes(searchQueryTrans)
        );
    } else {
        filteredTransactions = [...transactions];
    }

    onMount(async () => {
      await fetchSessionNotVerified();
    //   await fetchTransactions();
    //   await fetchAllSWSession();
    });

  </script>
  
   <div class="mt-[90px] mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={() => goto('/manage_cashier')} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Cashier</span>
      
    <div class="w-11/12 my-10">
        <div class="flex">
            {#if tampilan == "session"}
                <button on:click={async() => {tampilan = "session"; tampilan = tampilan; await fetchSessionNotVerified();}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Session Not Verified</button>
                <button on:click={async() => {tampilan = "session_all"; tampilan = tampilan; await fetchAllSWSession()}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">All Session</button>
                <button on:click={async() => {tampilan = "transaction"; tampilan = tampilan; await fetchTransactions()}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Transaction</button>
            {:else if tampilan == "session_all"}
                <button on:click={async() => {tampilan = "session"; tampilan = tampilan; await fetchSessionNotVerified();}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Session Not Verified</button>
                <button on:click={async() => {tampilan = "session_all"; tampilan = tampilan; await fetchAllSWSession()}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">All Session</button>
                <button on:click={async() => {tampilan = "transaction"; tampilan = tampilan; await fetchTransactions()}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Transaction</button>
            {:else if tampilan == "transaction"}
                <button on:click={async() => {tampilan = "session"; tampilan = tampilan; await fetchSessionNotVerified();}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Session Not Verified</button>
                <button on:click={async() => {tampilan = "session_all"; tampilan = tampilan; await fetchAllSWSession()}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">All Session</button>
                <button on:click={async() => {tampilan = "transaction"; tampilan = tampilan; await fetchTransactions()}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Transaction</button>
            {/if}
        </div>    
    </div>

         <label for="voice-search" class="sr-only">Search</label>
         <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
        {#if tampilan == "session"}
          <input 
              type="text" 
              id="voice-search" 
              bind:value={searchQuery}
              class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
              placeholder="Search..."/>
        {:else if tampilan == "session_all"}
            <input 
                type="text" 
                id="voice-search" 
                bind:value={searchQueryAll}
                class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                placeholder="Search..."/>
        {:else if tampilan == "transaction"}
            <input 
                type="text" 
                id="voice-search" 
                bind:value={searchQueryTrans}
                class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                placeholder="Search..."/>
        {/if}
         </div>

         <nav class="my-8">
            <ul class="flex items-center -space-x-px h-8 text-sm">
              {#if totalRows !== 0}
              <li>
                <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                  <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                    <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
                  </svg>
                  Previous
                </a>
              </li>
              {/if}
          
              <!-- Pagination Links -->
              {#each Array(Math.ceil(totalRows / limit)) as _, i}
                <li>
                  <a href="#" on:click|preventDefault={() => goToPage(i + 1)} class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">{i + 1}</a>
                </li>
              {/each}
          
              {#if totalRows !== 0}
              <li>
                <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                  Next
                  <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                    <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
                  </svg>
                </a>
              </li>
               {/if}
            </ul>
          </nav>

      {#if tampilan == "session"}
        {#each filteredSessionsNot as item}
        <div class="bg-darkGray border-8 border-darkGray rounded-lg w-[96%] my-5">
            <div class=" flex">
                <div class="w-4/5 p-3 text-darkGray bg-white rounded-tl-lg rounded-bl-lg shadow-[inset_0_0_5px_rgba(0,0,0,0.6)]">
                <p class="text-2xl font-bold mb-3">Session #{item["Session"].session_id}</p>
                <p class="font-semibold">Session start: 
                    <DateConverter value={item["Session"].start_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                </p>
                {#if item["Session"].end_time === "0000-00-00 00:00:00" || item["Session"].end_time === "0001-01-01T00:00:00Z"}
                    <p class="font-semibold">Session close: -</p>
                {:else}
                    <p class="font-semibold">Session close: 
                        <DateConverter value={item["Session"].end_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                    </p>
                {/if}
                
                <div class="flex items-center my-2">
                    <i class="fa-regular fa-user fa-xl me-3" style="color: #364445;"></i>
                    <span class="font-semibold">{item["UserData"].user_fullname}</span>
                </div>
                {#if (item["Session"].actual_closing_cash === 0)}
                    <div class="flex items-center my-2">
                        <i class="fa-solid fa-triangle-exclamation fa-xl me-3" style="color: #bf6a02;"></i>
                        <span class="font-bold text-peach2">WARNING: CLOSING CASH IS NOT INPUTTED!</span>
                    </div>
                {/if}
                
                </div>
                <div class="w-1/5 min-w-1/5 bg-darkGray flex items-center">
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
                </div>
            </div>
        </div>
        {/each}
        {#each sessionNotVerified as item}
            {#if (showModal == item["Session"].session_id)}
                <TaskModal open={showModal === item["Session"].session_id} onClose={closeModal} color={"#3d4c52"}>
                    <div class="flex items-center justify-center pt-8">
                    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Session #{item["Session"].session_id}</div>
                    </div>
                    <form class=" mt-8 p-4 md:p-5">
                        <div class="grid gap-3 font-roboto font-semibold">
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Cashier</div>
                                <div class="text-white">{item["UserData"].user_fullname}</div>
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
                                    {#if item.end_time === "0000-00-00 00:00:00"}
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
                                <MoneyInput bind:value={item["Session"].actual_closing_cash} />
                                <!-- <div class="text-white">Rp {item["Session"].actual_closing_cash.toLocaleString()}</div> -->
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Actual difference</div>
                                <div class="text-white">Rp {item["Session"].actual_difference.toLocaleString()}</div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Deposit money</div>
                                <MoneyInput bind:value={item["Session"].deposit_money} />
                                <!-- <div class="text-white">Rp {item.deposit_money.toLocaleString()}</div> -->
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Deposit Difference</div>
                                <div class="text-white">Rp {item["Session"].deposit_difference.toLocaleString()}</div>
                            </div>
                            <div class="text-[#f7d4b2]">
                                <div class="pb-3">Opening notes</div>
                                <textarea id="additional_notes" rows="4" class="min-h-24 shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item["Session"].opening_notes.toLocaleString()}" readonly></textarea>                    
                            </div>
                            <div class="text-[#f7d4b2]">
                                <div class="pb-3">Closing notes</div>
                                <textarea id="additional_notes" rows="4" class="min-h-24 shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item["Session"].closing_notes.toLocaleString()}" readonly></textarea>                    
                            </div>
                            
                            <!-- <div class="text-[#f7d4b2] flex items-center pb-3">
                                <div class="mr-3">Verified</div>
                                {#if item.status_verify == 1}
                                    <input type="checkbox" checked value={item.status_verify} class="w-4 h-4 text-peach bg-darkGray border-peach focus:ring-peach">
                                {:else}
                                    <input type="checkbox" value={item.status_verify} class="w-4 h-4 text-peach bg-darkGray border-peach focus:ring-peach">
                                {/if}
                            </div> -->

                            <div class="flex items-center justify-center">
                                <button type="button" on:click={async() => {await verify(item["Session"].session_id, item["Session"].actual_closing_cash,item["Session"].deposit_money); await fetchSessionNotVerified(); goto(`/manage_cashier/${store_warehouse_id}`);}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                                 Verify
                                </button>
                            </div>
                        </div>
                    </form>
                </TaskModal>
            {/if}
        {/each}
      {:else if tampilan == "session_all"}
      {#each filteredSessions as item}
        <div class="bg-darkGray border-8 border-darkGray rounded-lg w-[96%] my-5">
            <div class=" flex">
                <div class="w-4/5 p-3 text-darkGray bg-white rounded-tl-lg rounded-bl-lg shadow-[inset_0_0_5px_rgba(0,0,0,0.6)]">
                <p class="text-2xl font-bold mb-3">Session #{item["Session"].session_id}</p>
                <p class="font-semibold">Session start: 
                    <DateConverter value={item["Session"].start_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                </p>
                {#if item["Session"].end_time === "0000-00-00 00:00:00" || item["Session"].end_time === "0001-01-01T00:00:00Z"}
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
                </div>
            </div>
        </div>
        {/each}
        {#each all_session as item}
            {#if (showModal == item["Session"].session_id)}
                <TaskModal open={showModal === item["Session"].session_id} onClose={closeModal} color={"#3d4c52"}>
                    <div class="flex items-center justify-center pt-8">
                    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Session #{item["Session"].session_id}</div>
                    </div>
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
                                    {#if item.end_time === "0000-00-00 00:00:00"}
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
                                <!-- <MoneyInput bind:value={item["Session"].actual_closing_cash} /> -->
                                <div class="text-white">Rp {item["Session"].actual_closing_cash.toLocaleString()}</div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Actual difference</div>
                                <div class="text-white">Rp {item["Session"].actual_difference.toLocaleString()}</div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Deposit money</div>
                                <!-- <MoneyInput bind:value={item["Session"].deposit_money} /> -->
                                <div class="text-white">Rp {item["Session"].deposit_money.toLocaleString()}</div>
                            </div>
                            <div class="flex justify-between">
                                <div class="text-[#f7d4b2]">Deposit Difference</div>
                                <div class="text-white">Rp {item["Session"].deposit_difference.toLocaleString()}</div>
                            </div>
                            <div class="text-[#f7d4b2]">
                                <div class="pb-3">Opening notes</div>
                                <textarea id="additional_notes" rows="4" class="min-h-24 shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item["Session"].opening_notes.toLocaleString()}" readonly></textarea>                    
                            </div>
                            <div class="text-[#f7d4b2]">
                                <div class="pb-3">Closing notes</div>
                                <textarea id="additional_notes" rows="4" class="min-h-24 shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " value="{item["Session"].closing_notes.toLocaleString()}" readonly></textarea>                    
                            </div>
                            
                            <!-- <div class="text-[#f7d4b2] flex items-center pb-3">
                                <div class="mr-3">Verified</div>
                                {#if item.status_verify == 1}
                                    <input type="checkbox" checked value={item.status_verify} class="w-4 h-4 text-peach bg-darkGray border-peach focus:ring-peach">
                                {:else}
                                    <input type="checkbox" value={item.status_verify} class="w-4 h-4 text-peach bg-darkGray border-peach focus:ring-peach">
                                {/if}
                            </div> -->

                            <div class="flex items-center justify-center">
                                <button type="button" on:click={async() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                                 Close
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
  
      <nav class="my-8">
        <ul class="flex items-center -space-x-px h-8 text-sm">
          {#if totalRows !== 0}
          <li>
            <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
              <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
              </svg>
              Previous
            </a>
          </li>
          {/if}
      
          <!-- Pagination Links -->
          {#each Array(Math.ceil(totalRows / limit)) as _, i}
            <li>
              <a href="#" on:click|preventDefault={() => goToPage(i + 1)} class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">{i + 1}</a>
            </li>
          {/each}
      
          {#if totalRows !== 0}
          <li>
            <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
              Next
              <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
              </svg>
            </a>
          </li>
           {/if}
        </ul>
      </nav>
       
   </div>