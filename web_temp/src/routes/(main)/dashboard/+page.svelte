<script>
   import DateConverter from '$lib/DateConverter.svelte';
   import MoneyConverter from '$lib/MoneyConverter.svelte';

   import { onMount } from 'svelte';
   import { uri, userId, roleId } from '$lib/uri.js';
   // import FrappeChart from 'svelte-frappe-charts';
	import { getFormattedDate, getThirtyDaysBefore } from '$lib/DateNow';

   let showDateRange = false;

   $: endDate = getFormattedDate();
   $: startDate = getThirtyDaysBefore();

   $: tampilan = 'dashboard';

   $: total_profit = 87000000;
   $: last_month_profit = 90000000;
   $: profit_percentage = (((total_profit - last_month_profit) / last_month_profit) * 100).toFixed(2);

   $: this_month_qty = 15;
   $: last_month_qty = 20;
   $: qty_percentage = (((this_month_qty - last_month_qty) / last_month_qty) * 100).toFixed(2);

   function toggleDateRange() {
      showDateRange = !showDateRange;
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
                <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { endDate = getFormattedDate(); startDate = getThirtyDaysBefore(); }}>Clear</button>
                <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => { showDateRange = false; }}>Apply</button>
            </div>
         </div>
         {/if}
      <div class="grid grid-cols-3 gap-4 mt-4">
         <div class="">
            <div
               class="w-full y-full items-center border border-black rounded-xl py-2 px-4">
               <div class="text-zinc-400 text-center text-lg font-semibold">Total Profit</div>
               <div class="flex text-[#3d4c52] justify-center items-center gap-x-2 text-3xl font-black">
                  <MoneyConverter value={total_profit} currency={true} decimal={true}></MoneyConverter>
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
               <div class="text-black text-center text-xl font-semibold">Sales by Store Location</div>
               <div class="flex font-semibold text-[#3d4c52] items-center gap-x-2">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                     <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                  </svg>
                  <DateConverter value={startDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                  -
                  <DateConverter value={endDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
               </div>
               <div class="text-zinc-400 text-start text-lg font-semibold">Date Range</div>
               <div class="flex font-semibold text-[#3d4c52] items-center gap-x-2">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                     <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                  </svg>
                  <DateConverter value={startDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                  -
                  <DateConverter value={endDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
               </div>
               
               <div class="justify-center flex">
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
               <div class="text-black text-center text-xl font-semibold">Product Sales</div>
               <div class="flex font-semibold text-[#3d4c52] items-center gap-x-2">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                     <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                  </svg>
                  <DateConverter value={startDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                  -
                  <DateConverter value={endDate} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
               </div>
               <div class="justify-center flex">
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
   {:else if tampilan === 'sales by store locatiom'}
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
                <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { endDate = getFormattedDate(); startDate = getThirtyDaysBefore(); }}>Clear</button>
                <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => { showDateRange = false; }}>Apply</button>
            </div>
         </div>
         {/if}
      </div>
      
   {:else if tampilan === 'product sales'}
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
                <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { endDate = getFormattedDate(); startDate = getThirtyDaysBefore(); }}>Clear</button>
                <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => { showDateRange = false; }}>Apply</button>
            </div>
         </div>
         {/if}
      </div>
   {/if}
</div>
   