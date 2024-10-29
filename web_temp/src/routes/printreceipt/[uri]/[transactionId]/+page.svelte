<script>
  import MoneyConverter from '$lib/MoneyConverter.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
  import { onMount } from 'svelte';
  
  export let data;
  const { transaction, payment_method, cashier_id, store_warehouse, transaction_detail, user } = data;

  // console.log("test", transaction_detail);
  $: total_free = 0;
  $: total_discount = 0;
  $: countFreeItem();
  function countFreeItem(){
      for (let i = 0; i < transaction_detail.length; i++) {
          if (transaction_detail[i].quantity_free > 0){
              total_free += transaction_detail[i].quantity_free;
          }
          total_discount += transaction_detail[i].discount_price;
      }
  }
</script>
<div class="w-[40rem]  mx-8 bg-white p-3 font-roboto text-lg" id="printTarget">
    <div class="flex justify-center my-2 uppercase text-center">
      {store_warehouse.StoreWarehouses.store_warehouse_name}
    </div>
    <div class="flex justify-center uppercase text-center">
      {store_warehouse.StoreWarehouses.store_warehouse_address}
    </div>
    <div>
      ========================================================================
    </div>
    <div class="flex justify-between">
      <div>BON {transaction.transaction_id}</div>
      <div>Kasir: {user.user_fullname}</div>
    </div>
    <div>
      ========================================================================
    </div>
    {#each transaction_detail as detail}
      <div class="flex">
        <div class="uppercase w-5/12 font-semibold">
          {detail.product_detail_name}
        </div>
        <div class="flex w-1/12 justify-end">
          {detail.quantity}
        </div>
        <div class="flex w-3/12 justify-end">
            <MoneyConverter value={detail.sell_price} currency={false} decimal={false}></MoneyConverter>
        </div>
        <div class="flex w-3/12 justify-end">
            <MoneyConverter value={detail.sell_price * detail.quantity} currency={false} decimal={false}></MoneyConverter>
        </div>
      </div>
      {#if detail.quantity_free > 0}
        <div class="flex">
          <div class="pl-8 uppercase w-5/12">
              FREE
          </div>
          
          <div class="flex w-1/12 justify-end">
            {#if detail.quantity_free > 0}
              {detail.quantity_free}
            {/if}
          </div>
          <div class="flex w-3/12 justify-end">
            <MoneyConverter value={detail.sell_price} currency={false} decimal={false}></MoneyConverter>
          </div>
          <div class="flex w-3/12 justify-end">
              <MoneyConverter value={detail.discount_price} currency={false} decimal={false}></MoneyConverter>
          </div>
        </div>
      {/if}
      {#if detail.discount_price}
      <div class="flex justify-between">
        <div class="pl-8 uppercase w-5/12">
            DISCOUNT
        </div>
        
        <div class="flex w-1/12 justify-end">

        </div>
        <div class="flex w-3/12 justify-end">

        </div>
        <div class="flex w-3/12 justify-end">
            {#if detail.discount_price !== 0}-{/if}<MoneyConverter value={detail.discount_price} currency={false} decimal={false}></MoneyConverter>
        </div>
      </div>
      {/if}
    {/each}
    <div>
      ========================================================================
    </div>
    <div class="flex justify-between my-2">

        <div class="w-5/12">
          Total item
        </div>
        <div class="flex w-1/12 justify-end">
          {transaction.transaction_total_item + total_free}
        </div>
        <div class="flex w-3/12 justify-end">

        </div>
        <div class="flex w-3/12 justify-end">
          <MoneyConverter value={transaction.transaction_total_price + total_discount} currency={false} decimal={false}></MoneyConverter>
        </div>

    </div>
    <div class="flex justify-between my-2">

        <div class="w-5/12">
          Total discount
        </div>
        <div class="flex w-1/12 justify-end">
          
        </div>
        <div class="flex w-3/12 justify-end">

        </div>
        <div class="flex w-3/12 justify-end">
          {#if total_discount !== 0}-{/if}<MoneyConverter value={total_discount} currency={false} decimal={false}></MoneyConverter>          
        </div>

    </div>
    <div class="flex justify-between my-2">
      <div>
        Total belanja
      </div>
      <div>
          <MoneyConverter value={transaction.transaction_total_price} currency={false} decimal={false}></MoneyConverter>
      </div>
    </div>
    <div class="flex justify-between my-2">
      <div>
        {payment_method.payment_method_name}
      </div>
      <div>
          <MoneyConverter value={transaction.transaction_payment} currency={false} decimal={false}></MoneyConverter>
      </div>
    </div>
    {#if (Number(transaction.transaction_change) > 0)}
    <div class="flex justify-between my-2">
      <div>
        Kembalian
      </div>
      <div>
          <MoneyConverter value={transaction.transaction_change} currency={false} decimal={false}></MoneyConverter>
      </div>
    </div>
    {/if}
    <div>
      ========================================================================
    </div>
    <div class="flex justify-center my-2">
      Tgl. <DateConverter value={transaction.transaction_timestamp} date={true} hour={true} second={true} ampm={false} monthNumber={true} dash={true} dateFirst={true}/>
    </div>
</div>
