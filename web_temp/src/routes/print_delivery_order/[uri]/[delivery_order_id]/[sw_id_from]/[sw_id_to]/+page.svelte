<script>
   import DateConverter from '$lib/DateConverter.svelte';

   export let data;
   const { from, to, delivery_order, delivery_order_details} = data; 

</script>

    <div class="font-roboto text-xs m-4 outline text-black outline-[1px] rounded p-4 w-[32rem]" id="printTarget">
      <div class="font-medium">
        SURAT JALAN
      </div>
      <hr class="w-full border-t-[0.5px] my-2 border-black "/>
      <div class="flex justify-between">
        <div class="w-4/12 items-start">
          <div class="font-bold text-4xl">LOGO</div>
        </div>
        <div class="w-6/12 ">
          <div class="font-normal">{from.store_warehouse_name}</div>
          <div class="font-normal">{from.store_warehouse_address}</div>
        </div>
        <div class="w-3/12 items-start">
          <div class="flex justify-between">
            <div class="font-semibold">No</div>
            <div>
              {delivery_order.delivery_order_id}
            </div>
          </div>
          <div class="flex justify-between">
            <div class="font-semibold">Tgl</div>
            <div>
              <DateConverter value={delivery_order.order_timestamp} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
            </div>
          </div>
        </div>
      </div>
      <hr class="w-full border-t-[0.5px] my-2 border-black "/>
      <div>
        <div class="font-semibold">Penerima</div>
        <div class="font-normal">{to.store_warehouse_name}</div>
        <div class="font-normal">{to.store_warehouse_address}</div>
      </div>
      <div>
        <table class="border-collapse w-full text-sm text-left rtl:text-right printable-table">
          <thead class="text-xs text-gray-700 uppercase ">
            <tr class="border border-black text-xs font-bold uppercase text-center">
              <th scope="col" class="border border-black px-2 py-1">No</th>
              <th scope="col" class="border border-black px-1 py-1">Nama Produk</th>
              <th scope="col" class="border border-black px-1 py-1">Jumlah</th>
              <th scope="col" class="border border-black px-1 py-1">Satuan</th>
              <th scope="col" class="border border-black px-1 py-1">Nomor Batch</th>
              <th scope="col" class="border border-black px-1 py-1">Expiry Date</th>
            </tr>
          </thead>
          <tbody>
            {#each delivery_order_details as detail, i}
              <tr class="border border-black bg-white text-sm font-normal text-center">                        
                <th scope="row" class="border border-black px-2 py-1 text-gray-900 whitespace-nowrap">
                  {i+1}
                </th>
                <td class="border border-black px-1 py-1">{detail.product_name}</td>
                <td class="border border-black px-1 py-1">{detail.quantity}</td>
                <td class="border border-black px-1 py-1">{detail.unit_type}</td>
                <td class="border border-black px-1 py-1">{detail.batch}</td>
                <td class="border border-black px-1 py-1">
                  <DateConverter value={detail.expired_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
      <hr class="w-full border-t-[0.5px] mt-2 border-black "/>
      <div class="flex justify-center">
        <div class="flex justify-center gap-10 text-center mt-2">
          <div class="">
            <div class="font-semibold">Penerima:</div>
            <div class="mt-12">(...............................)</div>
          </div>
          <div class="">
            <div class="font-semibold">Pengirim:</div>
            <div class="mt-12">(...............................)</div>
          </div>
        </div>
      </div>
    </div>