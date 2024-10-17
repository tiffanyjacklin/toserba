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
    $: searchQuery = '';
    $: searchQueryAll = '';
    $: searchQueryTrans = '';
    $: searchQuery_temp = '';
    $: searchQueryAll_temp = '';
    $: searchQueryTrans_temp = '';
    $: start_date = '';
    $: end_date = '';
    $: start_price = 0;
    $: end_price = 999999999;
    $: showFilter = false;

    $: limit = 10; 
    $: offset = 0;
    $: currentPage = 1; 
    $: totalRows = 0;
    $: totalPages = Math.ceil(totalRows/limit);
    
    $: sessionNotVerified = [];
    $: filteredSessionsNot = [];
    $: all_session = [];
    $: filteredSessions = [];
    $: transactions = [];
    $: filteredTransactions = [];
    $: cashiers = [];
    $: cashier_name = '';
    
    let showModal = null; 
    let showModal12 = null; 
    let showTable = false;

    function clearVariable(){
        start_date = '';
        end_date = '';
        start_price = '';
        end_price = '';
        cashier_name = '';
        start_price = 0;
        end_price = 999999999;
    }

    function toggleTable() {
        showTable = !showTable;
    }

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

    function navigateToTransaction(transactionId) {
        const url = `/manage_cashier/${store_warehouse_id}/${transactionId}`;
        goto(url);
    }

    async function fetchCashiers() {
        const response = await fetch(`http://${$uri}:8888/user/store_warehouse/${store_warehouse_id}`, {
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
        
        let tmp = data.data;

        for (let i = 0; i < tmp.length; i++) {
            if (tmp[i].role_id == 1){
                cashiers.push(tmp[i])
            }
        }
      console.log(cashiers);
    }
  
    async function fetchSessionNotVerified() {
        console.log(`http://${$uri}:8888/sessions/not_verified/${store_warehouse_id}/${start_date}/${end_date}/${cashier_name}/${searchQuery}/${limit}/${offset}`)
      const response = await fetch(`http://${$uri}:8888/sessions/not_verified/${store_warehouse_id}/${start_date}/${end_date}/${cashier_name}/${searchQuery}/${limit}/${offset}`, {
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
     console.log("not",filteredSessionsNot);
   }
    
   async function fetchAllSWSession() {
    console.log(`http://${$uri}:8888/sessions/store_warehouse/${store_warehouse_id}/${start_date}/${end_date}/${cashier_name}/${searchQueryAll}/${limit}/${offset}`)
      const response = await fetch(`http://${$uri}:8888/sessions/store_warehouse/${store_warehouse_id}/${start_date}/${end_date}/${cashier_name}/${searchQueryAll}/${limit}/${offset}`, {
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
    totalPages = Math.ceil(totalRows/limit);
    all_session = data.data;
    filteredSessions = structuredClone(all_session);
    console.log("all session",data);
   }
    
   async function fetchTransactions() {
    console.log(`http://${$uri}:8888/transaction/store_warehouse/${store_warehouse_id}/${start_date}/${end_date}/${start_price}/${end_price}/''/${searchQueryTrans}/${limit}/${offset}`);
      const response = await fetch(`http://${$uri}:8888/transaction/store_warehouse/${store_warehouse_id}/${start_date}/${end_date}/${start_price}/${end_price}/''/${searchQueryTrans}/${limit}/${offset}`, {
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
      totalPages = Math.ceil(totalRows/limit);
      transactions = data.data;
      filteredTransactions = structuredClone(transactions);
     console.log("transaction",data);
   }

   let transactionByID = [];
   async function fetchTransactionBySession(sessionIdnya) {
      const response = await fetch(`http://${$uri}:8888/cashier/session/transaction/${sessionIdnya}/''/${limit}/${offset}`, {
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

    $: if ((searchQuery.length > 0) && searchQuery !== searchQuery_temp) {
      filteredSessionsNot = sessionNotVerified.filter(item => 
            item.Session.session_id.toString().includes(searchQuery) || 
            item.Session.user_fullname.toLowerCase().includes(searchQuery.toLowerCase())
        );
    } else {
        filteredSessionsNot = [...sessionNotVerified];
    }
    
    $: if ((searchQueryAll_temp !== searchQueryAll) ){
    //   console.log(searchQueryAll);
      fetchAllSWSession();
      searchQueryAll_temp = searchQueryAll;
    } else{
        searchQueryAll_temp = '';
      fetchAllSWSession();
    }
   
    $: if ((searchQueryTrans_temp !== searchQueryTrans) ){
      fetchTransactions();
      searchQueryTrans_temp = searchQueryTrans;
    } else{
      searchQueryTrans_temp = '';
    }

    onMount(async () => {
        fetchCashiers();
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
                <button on:click={async() => {tampilan = "session"; tampilan = tampilan; await fetchSessionNotVerified(); goToPage(1); clearVariable()}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Session Not Verified</button>
                <button on:click={async() => {tampilan = "session_all"; tampilan = tampilan; await fetchAllSWSession(); goToPage(1); clearVariable()}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">All Session</button>
                <button on:click={async() => {tampilan = "transaction"; tampilan = tampilan; await fetchTransactions(); goToPage(1); clearVariable()}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Transaction</button>
            {:else if tampilan == "session_all"}
                <button on:click={async() => {tampilan = "session"; tampilan = tampilan; await fetchSessionNotVerified(); goToPage(1); clearVariable()}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Session Not Verified</button>
                <button on:click={async() => {tampilan = "session_all"; tampilan = tampilan; await fetchAllSWSession(); goToPage(1); clearVariable()}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">All Session</button>
                <button on:click={async() => {tampilan = "transaction"; tampilan = tampilan; await fetchTransactions(); goToPage(1); clearVariable()}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Transaction</button>
            {:else if tampilan == "transaction"}
                <button on:click={async() => {tampilan = "session"; tampilan = tampilan; await fetchSessionNotVerified(); goToPage(1); clearVariable()}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Session Not Verified</button>
                <button on:click={async() => {tampilan = "session_all"; tampilan = tampilan; await fetchAllSWSession(); goToPage(1); clearVariable()}} class="mx-4 bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">All Session</button>
                <button on:click={async() => {tampilan = "transaction"; tampilan = tampilan; await fetchTransactions(); goToPage(1); clearVariable()}} class="mx-4 bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Transaction</button>
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
              placeholder="Search by Session ID or Cashier's name..."/>
        {:else if tampilan == "session_all"}
            <input 
            type="text" 
            id="voice-search" 
            class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
            placeholder="Search by Session ID or Cashier's name..."
            bind:value={searchQueryAll} />          
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
                    <input type="date" bind:value={start_date} class="rounded-xl w-32 mb-4 p-2 border" />
                    <span class="font-semibold text-lg mb-4">To</span>
                    <input type="date" bind:value={end_date} class="rounded-xl w-32 mb-4 p-2 border" />
                    </div>

                    <span class="font-bold text-xl mb-1">Cashier</span>
                    <div class="flex gap-x-4 w-full items-center">
                        {#each cashiers as cashier}
                            <button on:click={() => {cashier_name = (cashier_name === '' || cashier_name !== cashier.user_id) ? cashier.user_id : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:bg-white hover:border hover:border-peach2 hover:text-peach2 ${cashier_name === cashier.user_id ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>{cashier.user_fullname}</button>
                        {/each}
                    </div>
        
                    <div class="flex justify-between font-semibold mt-4">
                        <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { start_date = ""; end_date = ""; cashier_name = ""; }}>Clear</button>
                        <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {console.log(cashier_name); fetchAllSWSession(); showFilter = false;}}>Apply</button>
                    </div>
                </div>
            {/if}
        {:else if tampilan == "transaction"}
            <input 
            type="text" 
            id="voice-search" 
            bind:value={searchQueryTrans}
            class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
            placeholder="Search by Transaction ID or Cashier's name..."/>
            <button on:click={toggleFilter}
                type="button" 
                class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                <i class="fa-solid fa-sliders fa-xl mr-2"></i>
            </button>
            {#if showFilter}
                <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-fit  bg-gray-100 p-4 rounded-lg font-roboto">
                <span class="font-bold text-xl mb-1">Time Period</span>

                <div class="flex gap-x-4 w-full items-center">
                    <span class="font-semibold text-lg mb-4">From</span>
                    <input type="date" bind:value={start_date} class="rounded-xl w-32 mb-4 p-2 border" />
                    <span class="font-semibold text-lg mb-4">To</span>
                    <input type="date" bind:value={end_date} class="rounded-xl w-32 mb-4 p-2 border" />
                </div>
                {#if (String($sessionId) === String('') || String($sessionId) === String(0))}
                    <span class="font-bold text-xl mb-1">Cashier</span>
                    <div class="flex gap-x-4 w-full items-center">
                    {#each cashiers as cashier}
                        <button on:click={() => {cashier_name = (cashier_name === '' || cashier_name !== cashier.user_id) ? cashier.user_id : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:bg-white hover:border hover:border-peach2 hover:text-peach2 ${cashier_name === cashier.user_id ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>{cashier.user_fullname}</button>
                    {/each}
                    </div>
                {/if}
                <span class="font-bold text-xl mb-4">Price Range</span>
                <div class="flex gap-x-4 w-full items-center mt-2">
                    <span class="font-semibold text-lg ">From</span>
                    <MoneyInput bind:value={start_price} shadow={false}/>
                    <span class="font-semibold text-lg ">To</span>
                    <MoneyInput bind:value={end_price} shadow={false}/>
                </div>

                <div class="flex justify-between font-semibold mt-4">
                    <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { startDate = ""; endDate = ""; cashier_name = ""; startPrice = 0; endPrice = 999999999;}}>Clear</button>
                    <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {fetchTransactions(); showFilter = false;}}>Apply</button>
                </div>
                </div>
            {/if}
        {/if}
         </div>

        
        <nav class="my-8 flex justify-center">
            <ul class="flex items-center -space-x-px h-8 text-sm">
            {#if totalRows !== 0}
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
    
            {#if totalRows !== 0}
            <li>
                <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="{currentPage === (Math.ceil(totalRows / limit)) ? 'opacity-50 cursor-not-allowed' : 'hover:text-white hover:bg-black'} flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
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
                                    <td class="px-6 py-4">{transaction["UserData"].user_fullname}</td>
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
  
        <nav class="my-8 flex justify-center">
            <ul class="flex items-center -space-x-px h-8 text-sm">
            {#if totalRows !== 0}
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

            {#if totalRows !== 0}
            <li>
                <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="{currentPage === (Math.ceil(totalRows / limit)) ? 'opacity-50 cursor-not-allowed' : 'hover:text-white hover:bg-black'} flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
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