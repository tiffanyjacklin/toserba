<script>
   import DateConverter from '$lib/DateConverter.svelte';
   import MoneyConverter from '$lib/MoneyConverter.svelte';
   import LineChart from '$lib/LineChart.svelte';
   import DonutChart from '$lib/DonutChart.svelte';
   import { onMount } from 'svelte';
   import { uri, userId, roleId } from '$lib/uri.js';
   // import Chart from 'svelte-frappe-charts';
	import { getFormattedDateNow, getThirtyDaysBefore, getDateCount } from '$lib/DateNow';
   import supermarket from "$lib/assets/supermarket.jpg";
   import money from "$lib/assets/money.svg";

   let showDateRange = false;

   $: endDate = getFormattedDateNow();
   $: startDate = getThirtyDaysBefore(endDate, 30);

   $: tampilan = 'dashboard';

   $: total_profit = 50000;
   $: last_month = 100000;
   $: profit_percentage = (((total_profit - last_month) / last_month) * 100).toFixed(2);

   $: this_month_qty = 15;
   $: last_month_qty = 20;
   $: qty_percentage = (((this_month_qty - last_month_qty) / last_month_qty) * 100).toFixed(2);
   $: this_month_profit = [];
   $: last_month_profit = [];
   $: all_profits = [];
   $: all_sw_profits = [];

   $: list_of_dates = [];
   $: list_of_profit1 = [];
   $: data_for_donut = [];
   $: searchQuery = '';
   $: searchQuery_temp = '';
   $: all_store_profit = [];

   $: total_pendapatan = 0;
   $: total_beban = 0;
   $: laba_kotor = 0;

   onMount(async () => {
      await changeDate(startDate, endDate);
   });
   $: if ((searchQuery_temp !== searchQuery) ){
      console.log(searchQuery);
      fetchAllSwProfitFilter(startDate, endDate);
      searchQuery_temp = searchQuery;
   } else{
      searchQuery_temp = '';
   }
   function toggleDateRange() {
      showDateRange = !showDateRange;
   }
   async function changeDate(start_date, end_date) {
      await updatePercentage(start_date, end_date);
      await fetchAllProfit(start_date, end_date);
      const { date_list, profits } = updateVariables(all_profits, 'line');
      list_of_dates = date_list;
      list_of_profit1 = profits;

      await fetchAllSWProfit(start_date, end_date);
      data_for_donut = [ ...updateVariablesSW(all_sw_profits) ];
      total_pendapatan = calculateTotalPendapatan(all_sw_profits);
      total_beban = 0;
      laba_kotor = total_pendapatan - total_beban;
      console.log("data_for_donut1",data_for_donut);
      await fetchAllSwProfitFilter(startDate, endDate);
   }
   function calculateTotalPendapatan(profitsArray) {
    let totalPendapatan = 0;

    profitsArray.forEach(item => {
        totalPendapatan += item.profit;
    });

    return totalPendapatan;
}

   async function updatePercentage(startDate, endDate){
      this_month_profit = await fetchProfit(startDate, endDate);
      
      const last_month_end = getThirtyDaysBefore(startDate, 1)
      const last_month_start = getThirtyDaysBefore(last_month_end, 30);

   
      last_month_profit = await fetchProfit(last_month_start, last_month_end);
         
      total_profit = this_month_profit.profit;
      last_month = last_month_profit.profit;
      profit_percentage = (((total_profit - last_month) / last_month) * 100).toFixed(2);

      this_month_qty = this_month_profit.TransactionDetails.quantity;
      last_month_qty = last_month_profit.TransactionDetails.quantity;
      qty_percentage = (((this_month_qty - last_month_qty) / last_month_qty) * 100).toFixed(2);
   }
   function updateVariables(quantities_profits, chart_type) {
      const date_list = quantities_profits.map(transaction => {
         const date = new Date(transaction.Transaction.transaction_timestamp);
         return date.toLocaleDateString('en-GB', {
               day: '2-digit',
               month: 'short',
               year: 'numeric'
         });
      });

      const profits = quantities_profits.map(transaction => transaction.TransactionDetails.total_price);
      // console.log(date_list);
      // console.log(profits);
      return { date_list, profits }; // Return as an object
   }
   function updateVariablesSW(quantities_profits) {
      const data_profits = [];

      quantities_profits.forEach(item => {
         const warehouseName = item.StoreWarehouses.store_warehouse_name;
         const profit = item.profit;

         // Find if there's already an entry for this warehouse in data_profits
         const existingEntry = data_profits.find(entry => entry.store_warehouse_name === warehouseName);

         if (existingEntry) {
               existingEntry.profit += profit; // Accumulate profits if the warehouse already exists
         } else {
               // Create a new entry for the warehouse if it doesn't exist yet
               data_profits.push({
                  store_warehouse_name: warehouseName,
                  profit: profit
               });
         }
      });
      console.log(data_profits);
      return data_profits; // Return array of objects
   }

   async function fetchProfit(start_date, end_date) {
      const response = await fetch(`http://${$uri}:8888/profit/sum/date/${start_date}/${end_date}`, {
         method: 'GET',
         headers: {
               'Content-Type': 'application/json'
         }
      });

      if (!response.ok) {
         console.error('get all current stock fetch failed', response);
         return;
      }

      const data = await response.json();

      if (data.status !== 200) {
         console.error('Invalid fetch current stock', data);
         return;
      }

      return data.data;  
   }
   async function fetchAllProfit(start_date, end_date) {
      const response = await fetch(`http://${$uri}:8888/profit/sum/all/date/${start_date}/${end_date}/0/0`, {
         method: 'GET',
         headers: {
               'Content-Type': 'application/json'
         }
      });

      if (!response.ok) {
         console.error('get all current stock fetch failed', response);
         return;
      }

      const data = await response.json();

      if (data.status !== 200) {
         console.error('Invalid fetch current stock', data);
         return;
      }

      all_profits = [...data.data];  
   }
   async function fetchAllSWProfit(start_date, end_date) {
      const response = await fetch(`http://${$uri}:8888/profit/sum/all/store/${start_date}/${end_date}/0/0`, {
            method: 'GET',
            headers: {
               'Content-Type': 'application/json'
            }
      });

      if (!response.ok) {
            console.error('get all current stock fetch failed', response);
            return;
      }

      const data = await response.json();

      if (data.status !== 200) {
            console.error('Invalid fetch current stock', data);
            return;
      }

      all_sw_profits = [...data.data];  
      console.log("all_sw_profits",all_sw_profits);
   }
   async function fetchAllSwProfitFilter(start_date, end_date) {
        const response = await fetch(`http://${$uri}:8888/profit/sum/all/store/${start_date}/${end_date}/${searchQuery}/0/0`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });
  
        if (!response.ok) {
            console.error('get all current stock fetch failed', response);
            return;
        }
  
        const data = await response.json();
  
        if (data.status !== 200) {
            console.error('Invalid fetch current stock', data);
            return;
        }
  
        all_store_profit = [...data.data];  
        console.log("all_store_profit",all_store_profit);
   }
 </script>

<div class="mx-8 font-roboto mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
   {#if tampilan === 'dashboard'}
      <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Dashboard</span>
      <div class="relative w-11/12 rounded-lg">
         <button on:click={toggleDateRange}
            type="button" 
            class=" items-center border border-black rounded-xl py-2 px-4">
            <div class="text-zinc-400 text-start text-lg font-semibold">Date Range</div>
            <div class="flex font-semibold text-[#3d4c52] items-center gap-x-2">
               <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
               </svg>
               <DateConverter value={startDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
               -
               <DateConverter value={endDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
            </div>
            
         </button>
         {#if showDateRange}
            <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute left-0 z-10 mt-2 w-3/5 bg-gray-100 p-4 rounded-lg font-roboto">
               
               <div class="">
               <div class="font-bold text-xl mb-1 flex justify-between">
                     <div>Transactions Period</div>
                     <div>
                        <button on:click={() => {endDate = getFormattedDateNow(); startDate = getThirtyDaysBefore(endDate, 30); showDateRange = false; }}>
                           <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                              <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
                           </svg>
                        </button>
                  </div>
               </div>
               <div class="flex gap-x-4 w-full items-center">
                  <span class="font-semibold text-lg mb-4">From</span>
                  <input type="date" bind:value={startDate} class="rounded-xl w-32 mb-4 p-2 border" />
                  <span class="font-semibold text-lg mb-4">To</span>
                  <input type="date" bind:value={endDate} class="rounded-xl w-32 mb-4 p-2 border" />
               </div>
               </div>
               
               <div class="flex justify-between font-semibold mt-4">
                  <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { endDate = getFormattedDateNow(); startDate = getThirtyDaysBefore(endDate, 30); }}>Clear</button>
                  <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={async () => { changeDate(startDate, endDate); showDateRange = false; }}>Apply</button>
               </div>
            </div>
            {/if}
         <div class="grid grid-cols-3 gap-4 mt-4">
            <div class="">
               <div class="w-full y-full items-center border border-black rounded-xl py-2 px-4">
                  <div class="text-zinc-400 text-center text-lg font-semibold">Total Profit</div>
                  <div class="flex text-[#3d4c52] justify-center items-center gap-x-2 text-3xl font-black">
                     <MoneyConverter bind:value={total_profit} currency={true} decimal={true}></MoneyConverter>
                  </div>
                  {#if profit_percentage > 0}
                  <div class="flex justify-center items-center text-green-400  gap-x-2">
                     <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="size-5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 10.5 12 3m0 0 7.5 7.5M12 3v18" />
                     </svg>
                     <div class="text-lg font-bold">{profit_percentage} %</div>
                  </div>
                  {:else if profit_percentage < 0}
                  <div class="flex justify-center items-center text-red-400  gap-x-2">
                     <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="size-5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 13.5 12 21m0 0-7.5-7.5M12 21V3" />
                     </svg>
                     <div class="text-lg font-bold">{Math.abs(profit_percentage)} %</div>
                  </div>
                  {:else}
                  <div class="flex justify-center items-center text-green-400 gap-x-2">
                     <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="size-5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M5 12h14" />
                     </svg>
                     <div class="text-lg font-bold">{profit_percentage} %</div>
                  </div>
                  {/if}
                  <div class="text-zinc-400 text-center text-sm font-semibold">compared to 30 days ago</div>
               </div>
            </div>
            <div class="">
               <div
                  class="w-full y-full items-center border border-black rounded-xl py-2 px-4">
                  <div class="text-zinc-400 text-center text-lg font-semibold">Total Products Sold</div>
                  <div class="flex text-[#3d4c52] justify-center items-center gap-x-2 text-3xl font-black">
                     {this_month_qty} units
                  </div>
                  {#if qty_percentage > 0}
                  <div class="flex justify-center items-center text-green-400  gap-x-2">
                     <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="size-5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4.5 10.5 12 3m0 0 7.5 7.5M12 3v18" />
                     </svg>
                     <div class="text-lg font-bold">{qty_percentage} %</div>
                  </div>
                  {:else if qty_percentage < 0}
                  <div class="flex justify-center items-center text-red-400  gap-x-2">
                     <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="size-5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 13.5 12 21m0 0-7.5-7.5M12 21V3" />
                     </svg>
                     <div class="text-lg font-bold">{Math.abs(qty_percentage)} %</div>
                  </div>
                  {:else}
                  <div class="flex justify-center items-center text-green-400 gap-x-2">
                     <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="size-5">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M5 12h14" />
                     </svg>
                     <div class="text-lg font-bold">{qty_percentage} %</div>
                  </div>
                  {/if}
                  <div class="text-zinc-400 text-center text-sm font-semibold">compared to 30 days ago</div>
               </div>
            </div>
            <div class="row-span-2">

               <div
                  class="w-full y-full items-center border border-black rounded-xl py-2 px-4 justify-center">
                  <div class="text-black text-center text-2xl font-bold mt-4">Sales by Store Location</div>
                  {#if Object.keys(data_for_donut).length > 0}
                     <DonutChart data_temp={data_for_donut} samping_bawah="bawah"/>
                  {/if}
                  <div class="justify-center flex my-8">
                     <button 
                     on:click={() => tampilan = 'sales by store location'}
                     type="button" 
                     class="h-10 px-4 w-40 inline-flex items-center justify-center font-bold rounded-3xl bg-[#3d4c52] text-white hover:shadow-2xl">
                     View Details
                     </button>
                  </div>
               </div>
            </div>
            <div class="col-span-2">

               <div 
                  class="w-full y-full items-center border border-black rounded-xl py-2 px-4 justify-center">
                  <div class="text-black text-center text-2xl font-bold mt-4">Product Sales</div>
                  <div class="flex justify-center">
                     {#if list_of_profit1.length > 0 && list_of_dates.length > 0}
                        <LineChart data={list_of_profit1} dates={list_of_dates} />
                     {/if}
                  </div>
                  <div class="justify-center flex my-4">
                     <button 
                     on:click={() => tampilan = 'product sales'}
                     type="button" 
                     class="h-10 px-4 w-40 inline-flex items-center justify-center font-bold rounded-3xl bg-[#3d4c52] text-white hover:shadow-2xl">
                     View Details
                     </button>
                  </div>
               </div>
            </div>

         </div>
      </div>
   {:else if tampilan === 'sales by store location'}
   <div class="relative w-11/12 rounded-lg">
      <div class="flex mt-10 justify-between mx-4 relative">
         <button type="button" on:click={() => tampilan = 'dashboard'} class="text-lg font-semibold z-10 hover:text-[#f2b082]">
           <i class="fa-solid fa-angle-left"></i>
           Back
         </button>
       </div> 

      <button on:click={toggleDateRange}
         type="button" 
         class=" items-center border border-black rounded-xl py-2 px-4 mt-4">
         <div class="text-zinc-400 text-start text-lg font-semibold">Date Range</div>
         <div class="flex font-semibold text-[#3d4c52] items-center gap-x-2">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
               <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
            </svg>
            <DateConverter value={startDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
            -
            <DateConverter value={endDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
         </div>
      </button>
         
      {#if showDateRange}
          <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute left-0 z-10 mt-2 w-3/5 bg-gray-100 p-4 rounded-lg font-roboto">
            
            <div class="">
              <div class="font-bold text-xl mb-1 flex">
                Transactions Period
              </div>
              <div class="flex gap-x-4 w-full items-center">
                <span class="font-semibold text-lg mb-4">From</span>
                <input type="date" bind:value={startDate} class="rounded-xl w-32 mb-4 p-2 border" />
                <span class="font-semibold text-lg mb-4">To</span>
                <input type="date" bind:value={endDate} class="rounded-xl w-32 mb-4 p-2 border" />
              </div>
            </div>
            
            
            <div class="flex justify-between font-semibold mt-4">
               <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { endDate = getFormattedDateNow(); startDate = getThirtyDaysBefore(endDate, 30); }}>Clear</button>
               <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={async () => { changeDate(startDate, endDate); showDateRange = false; }}>Apply</button>
            </div>
         </div>
         {/if}
         <div class="items-center border border-black rounded-xl py-2 px-4 my-4">
            <div class="text-black text-center text-3xl font-bold mt-4">Sales by Store Location</div>
            {#if Object.keys(data_for_donut).length > 0}
               <DonutChart data_temp={data_for_donut} samping_bawah="samping"/>
            {/if}
         </div>

         <div>
            <label for="voice-search" class="sr-only">Search</label>
            <div class="relative w-full shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
                  <input 
                  bind:value={searchQuery} 
                  type="text" id="voice-search" 
                  class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                  placeholder="Search store..."/>
            </div>

            {#each all_store_profit as sw}
            <button class="w-full h-full flex border-2 rounded-xl ml-auto border-gray-700 my-3 hover:bg-gray-200" type="button" disabled>                        
               <div class="m-4 w-1/12 flex items-center">
               <img class="rounded-lg aspect-square" src={supermarket} alt="">
               </div>
               <div class="py-4 w-11/12">
               <div class="font-bold justify-start whitespace-nowrap flex items-center">
                     <div class="">{sw.StoreWarehouses.store_warehouse_type}</div>
                     <div class="capitalize mx-1">{sw.StoreWarehouses.store_warehouse_name}</div>
                  </div>
                  <div class="font-semibold flex justify-start">
                     {sw.StoreWarehouses.store_warehouse_address}
                  </div>
                  <div class="flex text-[#17b978] gap-x-2 items-center font-bold">
                     <img class="rounded-lg aspect-square h-6 w-6 " src={money}  alt="">
                     <MoneyConverter bind:value={sw.profit} currency={true} decimal={true}></MoneyConverter>
                     <div>({getDateCount(startDate, endDate)} days)</div>
                  </div>
               </div>
            </button>
            {/each}
            {#if all_store_profit.length === 0}
            <div class="justify-center w-full h-full flex border-2 rounded-xl py-4 border-gray-400 my-3 ">
               No store profit found.
             </div>
            {/if}
         </div>
      </div>
      
   {:else if tampilan === 'product sales'}
   <div class="relative w-11/12 rounded-lg">
      <div class="flex mt-10 justify-between mx-4 relative">
         <button type="button" on:click={() => tampilan = 'dashboard'} class="text-lg font-semibold z-10 hover:text-[#f2b082]">
           <i class="fa-solid fa-angle-left"></i>
           Back
         </button>
       </div> 

      <button on:click={toggleDateRange}
         type="button" 
         class=" items-center border border-black rounded-xl py-2 px-4 mt-4">
         <div class="text-zinc-400 text-start text-lg font-semibold">Date Range</div>
         <div class="flex font-semibold text-[#3d4c52] items-center gap-x-2">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
               <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
            </svg>
            <DateConverter value={startDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
            -
            <DateConverter value={endDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
         </div>
      </button>
      {#if showDateRange}
          <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute left-0 z-10 mt-2 w-3/5 bg-gray-100 p-4 rounded-lg font-roboto">
            
            <div class="">
              <div class="font-bold text-xl mb-1 flex">
                Transactions Period
              </div>
              <div class="flex gap-x-4 w-full items-center">
                <span class="font-semibold text-lg mb-4">From</span>
                <input type="date" bind:value={startDate} class="rounded-xl w-32 mb-4 p-2 border" />
                <span class="font-semibold text-lg mb-4">To</span>
                <input type="date" bind:value={endDate} class="rounded-xl w-32 mb-4 p-2 border" />
              </div>
            </div>
            
            <div class="flex justify-between font-semibold mt-4">
               <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { endDate = getFormattedDateNow(); startDate = getThirtyDaysBefore(endDate, 30); }}>Clear</button>
               <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={async () => { changeDate(startDate, endDate); showDateRange = false; }}>Apply</button>
            </div>
         </div>
         {/if}
         <div class=" items-center border border-black rounded-xl py-2 px-4 my-4">
            <div class="text-black text-center text-3xl font-bold mt-4">Product Sales</div>
            <div class="flex justify-center">
               {#if list_of_profit1.length > 0 && list_of_dates.length > 0}
                  <LineChart data={list_of_profit1} dates={list_of_dates} width={800}/>
               {/if}
            </div>
         </div>
         <div class="items-center border border-black rounded-xl py-2 px-4 my-4">
            <div class="printable-section w-full h-full">
               <button disabled
                  class=" items-center justify-start border border-black rounded-xl py-2 px-4 mt-2">
                  <div class="text-zinc-400 text-start text-lg font-semibold">Date Range</div>
                  <div class="flex font-semibold text-[#3d4c52] items-center gap-x-2">
                     <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                     </svg>
                     <DateConverter value={startDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                     -
                     <DateConverter value={endDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                  </div>
               </button>
               <div class="w-4/5 mx-auto justify-center items-center m-8">
                  <div class="font-bold text-center">
                      <div>PT. TOSERBA X</div>
                      <div>LABA RUGI</div>
                      <DateConverter value={startDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false} />
                      -
                      <DateConverter value={endDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false} />
                  </div>
                  <hr class="border border-black my-4">
                  <div class="text-start">Pendapatan</div>
                  {#each all_store_profit as sw}
                  <div class="flex justify-between indent-4">
                      <div class="text-start">Pendapatan {sw.StoreWarehouses.store_warehouse_name}</div>
                      <div class="text-end"><MoneyConverter bind:value={sw.profit} currency={true} decimal={true}/></div>
                  </div>
                  {/each}
                  <hr class="my-4">
                  <div class="font-bold">
                      <div class="text-start">Total dari Pendapatan</div>
                      <div class="text-end"><MoneyConverter bind:value={total_pendapatan} currency={true} decimal={true}/></div>
                  </div>
                  <div class="text-start">Beban Pokok</div>
                  <div class="flex justify-between indent-4">
                      <div class="text-start">Beban Pokok</div>
                      <div class="text-end flex">(<MoneyConverter bind:value={total_beban} currency={true} decimal={true}/>)</div>
                  </div>
                  <hr class="my-4">
                  <div class="flex justify-between font-bold">
                      <div class="text-start">Total dari Beban Pokok</div>
                      <div class="text-end"><MoneyConverter bind:value={total_beban} currency={true} decimal={true}/></div>
                  </div>
                  <div class="flex justify-between font-bold">
                      <div class="text-start">Laba Kotor</div>
                      <div class="text-end"><MoneyConverter bind:value={laba_kotor} currency={true} decimal={true}/></div>
                  </div>
              </div>
              
            </div>
            <div class="flex items-center justify-start my-2">
               <button type="button" on:click={() => window.print()} class="border border-black mt-2 flex w-40 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-md py-1.5 text-center">
                 <div class="w-2/12 flex justify-center ml-6">
                   <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                     <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096m-.72-.096L17.66 18m0 0 .229 2.523a1.125 1.125 0 0 1-1.12 1.227H7.231c-.662 0-1.18-.568-1.12-1.227L6.34 18m11.318 0h1.091A2.25 2.25 0 0 0 21 15.75V9.456c0-1.081-.768-2.015-1.837-2.175a48.055 48.055 0 0 0-1.913-.247M6.34 18H5.25A2.25 2.25 0 0 1 3 15.75V9.456c0-1.081.768-2.015 1.837-2.175a48.041 48.041 0 0 1 1.913-.247m10.5 0a48.536 48.536 0 0 0-10.5 0m10.5 0V3.375c0-.621-.504-1.125-1.125-1.125h-8.25c-.621 0-1.125.504-1.125 1.125v3.659M18 10.5h.008v.008H18V10.5Zm-3 0h.008v.008H15V10.5Z" />
                   </svg>
                 </div>
                 <div class="w-10/12 text-start ml-2">
                   Print report
                 </div>
               </button>
             </div>
         </div>
      </div>
   {/if}
</div>
   