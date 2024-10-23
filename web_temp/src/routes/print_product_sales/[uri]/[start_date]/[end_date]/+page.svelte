<script>
   import DateConverter from '$lib/DateConverter.svelte';
   import MoneyConverter from '$lib/MoneyConverter.svelte';

   export let data;
   const { all_store_profit, startDate, endDate, total_pendapatan, total_beban, laba_kotor } = data; 

</script>

<div class="w-[56rem] items-center border border-black rounded-xl py-2 px-4 my-4" id="printTarget">
    <div class="printable-section w-full h-full">
       
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
              <div class="text-end"><MoneyConverter value={total_pendapatan} currency={true} decimal={true}/></div>
          </div>
          <div class="text-start">Beban Pokok</div>
          <div class="flex justify-between indent-4">
              <div class="text-start">Beban Pokok</div>
              <div class="text-end flex">(<MoneyConverter value={total_beban} currency={true} decimal={true}/>)</div>
          </div>
          <hr class="my-4">
          <div class="flex justify-between font-bold">
              <div class="text-start">Total dari Beban Pokok</div>
              <div class="text-end flex indent-4">(<MoneyConverter value={total_beban} currency={true} decimal={true}/>)</div>
          </div>
          <div class="flex justify-between font-bold">
              <div class="text-start">Laba Kotor</div>
              {#if laba_kotor < 0}
              <div class="text-end flex indent-4">(<MoneyConverter value={Math.abs(laba_kotor)} currency={true} decimal={true}/>)</div>
              {:else}
              <div class="text-end"><MoneyConverter value={laba_kotor} currency={true} decimal={true}/></div>
              {/if}
          </div>
      </div>
    </div>
 </div>