<script>
   import DateConverter from '$lib/DateConverter.svelte';
   import MoneyConverter from '$lib/MoneyConverter.svelte';

   export let data;
   const { stock_card } = data; 

</script>
<div class="w-[56rem] relative overflow-x-auto shadow-md sm:rounded-lg " id="printTarget">
    <table class="w-full text-sm text-left rtl:text-right printable-table">
      <thead class="text-xs text-gray-700 uppercase bg-gray-100">
        <tr class="border-b-2 border-black">
          <th scope="col" class="px-3 py-2 text-sm font-bold uppercase text-center">
              No
          </th>
          <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
              Batch
          </th>
          <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
              Expiry Date
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
            Reason
          </th>
          <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
            Date
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
              {stock.product_batch}
            </td>
            <td class="px-1 py-2 text-center">
              <DateConverter value={stock.expired_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
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
              {stock.stock_description}
            </td>
            <td class="px-1 py-2 text-center">
              <DateConverter value={stock.stock_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>