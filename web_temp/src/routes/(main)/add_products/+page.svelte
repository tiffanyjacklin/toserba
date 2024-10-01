<script>
  import TaskModal from '$lib/TaskModal.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
   import { getFormattedDateSpecial, getFormattedDateSpecialWithValue } from '$lib/DateNow.js';
   import MoneyConverter from '$lib/MoneyConverter.svelte';
  import { onMount } from 'svelte';
  import { uri, userId, roleId, storeId, sw_name } from '$lib/uri.js';
  import { get } from 'svelte/store';
  import { goto } from '$app/navigation';
  storeId.set('');
  let dateNow = getFormattedDateSpecial({
    date: true,
    hour: false,
    second: false,
    ampm: false,
    monthNumber: true,
    dash: false,
    dateFirst: false
  });

  let showIDList = false;
  let showNameList = false;
  function toggleIDList() {
    showIDList = !showIDList;
    showNameList = false;
  }

  function toggleNameList() {
    showNameList = !showNameList;
    showIDList = false;
  }
  // console.log(dateNow);
  let back = true;
  let delivery_order_supplier = '';
  let supplier_name = '';
  let supplier_id = '';
  let productId = '';
  let productName = '';
  let expired_date = '';
  let quantity = '';
  let batch = '';
  let unit_type = '';
  let section_placement = '';
  let stores = [];
  let all_stores = [];
  let stocks = [];
  let all_stocks = [];
  let warehouse = [];
  $: filteredStock = [];
  $: expiredDateOfSelectedProduct = [];
  let product = [];
  let suppliers = [];

  // let stock_card = [];
  let searchQuery = '';
  let showModal = null; 
  let showTable = false;
  let showSupplier = false;
  let showAddProduct = false;
  let products_to_be_added = [];

  function handleClick(id, backNya) {
    showModal = id;
    back = backNya;
  }
  function closeModal() {
    showModal = null;
    back = true;
  }
  function toggleBack(){
    back = !back;
  }
  function toggleTable(product_id) {
    showTable = !showTable;
  }
  function toggleProductAdd() {
    showAddProduct = !showAddProduct;
  }
  function toggleSupplier() {
    showSupplier = !showSupplier;
  }
  onMount(async () => {
    await fetchWarehouse(); 
    await fetchSupplier();
  });
  async function fetchSupplier() {
      const response = await fetch(`http://${$uri}:8888/suppliers/all/${supplier_name}/0/0`, {
          method: 'GET',
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('get all produk fetch failed', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid fetch last', data);
          return;
      }

      suppliers = [...data.data];  
      console.log(suppliers);
  }
  async function fetchWarehouse() {
      const response = await fetch(`http://${$uri}:8888/store_warehouses/${$userId}/${$roleId}/''/0/0`, {
          method: 'GET',
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('get all produk fetch failed', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid fetch last', data);
          return;
      }

      warehouse = data.data;  
      // all_stores = [...stores];
      // console.log(warehouse);
  }
  async function fetchAllProductsFromSupplier() {
      const response = await fetch(`http://${$uri}:8888/products/supplier/${supplier_id}/0/0`, {
          method: 'GET',
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('get all produk fetch failed', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid fetch last', data);
          return;
      }

      stocks = [...data.data];  
      all_stocks = [...stocks];
  }
  function filterSupplier(value){
    suppliers = suppliers.filter(supplier => supplier.supplier_name.toLowerCase().includes(value.toLowerCase()));
  }
  function filterStock(value, type) {
    if (type === 'id') {
      all_stocks = stocks.filter(stock => String(stock.ProductDetails.product_detail_id).includes(value));
    } else {
      all_stocks = stocks.filter(stock => stock.ProductDetails.product_name.toLowerCase().includes(value.toLowerCase()));
    }
  }
  async function selectSupplier(supplier) {
    supplier_id = supplier.supplier_id;
    supplier_name = supplier.supplier_name;
    back = false;
    await fetchAllProductsFromSupplier();
  }
  function selectProduct(stock) {
    productId = stock.ProductDetails.product_detail_id;
    productName = stock.ProductDetails.product_name;
    unit_type = stock.ProductDetails.product_unit;
  }
  // function selectProductExp(stock) {
  //     expired_date = stock.expired_date;

  //     all_stocks = stocks.filter(item => 
  //         item.expected_stock > 0     
  //     );
  //     filteredStock = filterOldestStock(all_stocks);
  //     expiredDateOfSelectedProduct = [];
  // }
  // function filterOldestStock(all_stockss) {
  //   let stockMap = new Map();

  //   const filteredForTransfer = all_stockss.filter(stock => {
  //       return !products_to_be_added.some(transfer =>
  //           transfer.product_name === stock.product_name &&
  //           transfer.batch === stock.batch
  //       );
  //   });

  //   filteredForTransfer.forEach(stock => {
  //       let existing = stockMap.get(stock.product_name);

  //       if (!existing || isOlder(stock.expired_date, existing.expired_date)) {
  //           stockMap.set(stock.product_name, stock);
  //       }
  //   });

  //   return Array.from(stockMap.values());
  // }
  function isOlder(date1, date2) {
    // Convert "0000-00-00" to a very old date
    if (date1 === "0000-00-00") return true;
    if (date2 === "0000-00-00") return false;

    // Compare actual dates
    return new Date(date1) < new Date(date2);
  }
  function addProductToProductList() {
    // console.log(productId, productName, batch, expired_date, quantity, section_placement)
    let product = {
      product_detail_id: Number(productId),
      product_name: productName,
      batch: batch,
      expired_date: expired_date,
      quantity: quantity,
      unit_type: unit_type,
      section_placement: section_placement,
    };

    products_to_be_added = [...products_to_be_added, product];

    productId = ''; 
    productName = '';
    expired_date = '';
    section_placement = '';
    unit_type = '';
    batch = '';
    quantity = '';

    all_stocks = [...stocks];
    closeModal();
  }
  $: if (supplier_name != searchQuery){
    fetchSupplier();
    searchQuery = supplier_name;
  } else{
    searchQuery = '';
  }
  $: if (productId !== '' && productName.length > 0) {
      showIDList = false;
      showNameList = false;
  }
  $: if (String(productId).length > 0) {
    filterStock(productId, 'id');
  } else {
    all_stocks = [...stocks];
  }
  $: if (productName.length > 0) {
    filterStock(productName, 'name');
  } else {
    all_stocks = [...stocks];
  }
  $: if (productId === '' && productName.length === '') {
    all_stocks = [...stocks];
  }
  
  let temp = [];
  function deleteProductFromList(product_id, expired_dateNya, batchNya) {
    console.log(products_to_be_added);
    console.log(product_id, expired_dateNya, batchNya);
      products_to_be_added = products_to_be_added.filter(stock => 
        !(stock.product_detail_id === product_id && 
          stock.expired_date === expired_dateNya && 
          stock.batch === batchNya)
      );
  }
  function filterProductForSubtract(products){
    return products.map(product => ({
        product_detail_id: product.product_detail_id,
        quantity: product.quantity,
        section_placement: product.section_placement,
        expired_date: product.expired_date,
        batch: product.batch
    }));
  }
  let products_to_send_fix = [];

  function filterProductForAdding(products){
    return products.map(product => ({
        product_detail_id: product.product_detail_id,
        quantity: product.quantity,
        expired_date: product.expired_date,
        section_placement: product.section_placement,
        batch: product.batch
    }));
  }
  let products_to_add_fix = [];

  async function addProducts(){
    products_to_add_fix = filterProductForAdding(products_to_be_added);
    // console.log(products_to_add_fix);

    const response = await fetch(`http://${$uri}:8888/orders/supplier/add/${$userId}/${$roleId}`, {
      method: 'POST',
      body: JSON.stringify(products_to_add_fix)
    });

    if (!response.ok) {
      console.error('POST add products gagal', response);
      return;
    }

    const data = await response.json();

    if (data.status !== 200) {
      console.error('Invalid post add products', data);
      return;
    }
    // console.log("insert products detail",data);

    const add_products_details = String(data.data[0].add_stock_id);
    // console.log(add_products_details);
    // console.log(delivery_order_supplier, supplier_id);
    const updateUrl = `http://${$uri}:8888/orders/supplier/update/${add_products_details}`;
    // console.log('Update URL:', updateUrl);

    const response2 = await fetch(updateUrl, {
      method: 'PUT',
      body: JSON.stringify({
        delivery_order_supplier: delivery_order_supplier,
        supplier_id: supplier_id,
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    });

    if (!response2.ok) {
      console.error('PUT add products failed', response2);
      return;
    }

    const data2 = await response2.json();

    if (data2.status !== 200) {
      console.error('Invalid put add products', data2);
      return;
    }

    // console.log("Updated add products detail", data2);
    delivery_order_supplier = '';
    supplier_id = '';
    products_to_be_added = [];
    // goto(`/products`);
  }
  
  // Convert 'yyyy-mm-dd' to 'dd/mm/yyyy'
  function formatDateToDisplay(date) {
    if (!date) return '';
    const [year, month, day] = date.split('-');
    return `${day}/${month}/${year}`;
  }

  // Convert 'dd/mm/yyyy' to 'yyyy-mm-dd'
  function formatDateToISO(date) {
    if (!date) return '';
    const [day, month, year] = date.split('/');
    return `${year}-${month}-${day}`;
  }

  function handleDateChange(event) {
    const inputDate = event.target.value; // 'dd/mm/yyyy'
    expired_date = formatDateToISO(inputDate); // Convert to 'yyyy-mm-dd'
  }
  let sn_bind = supplier_name;
  function focusSupplierInput(event) {
    if (event.key === 'Enter') {
      sn_bind.focus();
    }
  }
  let do_bind = delivery_order_supplier;
  function focusDOInput(event) {
    if (event.key === 'Enter') {
      do_bind.focus();
    }
  }

</script>
<div class="select-none font-roboto text-[#364445] mx-8 mt-[90px] mb-10 flex flex-col items-center justify-center bg-white shadow-[0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
  <div class="flex flex-col w-full pb-10 justify-center shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="flex mt-10 justify-between mx-10 relative ">
      <div class="absolute inset-0 text-center "> 
        <span class="text-4xl font-bold font-roboto text-[#364445]">Add Products</span>
      </div>      
    </div>
    <div class="relative mt-8 items-center w-full ">
      <div class="rounded-lg p-4 bg-white text-black gap-2">
        <div class="flex justify-between gap-8 mx-4">
          <div class="w-full">
            <label for="password" class="select-none leading-6  block no-underline my-1 font-semibold ">Delivery Order Number</label>
            <div class="relative">
              <input type="text" required
                bind:value={delivery_order_supplier} on:keydown={focusSupplierInput} bind:this={do_bind}
                class="focus:ring-2 h-8 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full px-6 py-2 text-md leading-6 text-slate-900 rounded-3xl" >
            </div>
          </div>
          
          <div class="w-full">
            <label for="password" class="select-none leading-6  block no-underline my-1 font-semibold ">Supplier</label>
            <div class="relative">
              <input type="text" required
                bind:value={supplier_name} on:click={toggleSupplier} on:focus={toggleSupplier} on:keydown={focusDOInput} bind:this={sn_bind}
                class="focus:ring-2 h-8  focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full px-6 py-2 text-md leading-6 text-slate-900 rounded-3xl" >
                {#if suppliers.length > 0 && showSupplier && !suppliers.some(supplier => supplier.supplier_name.toLowerCase() === supplier_name.toLowerCase())}
                <ul class="absolute w-1/4  bg-white shadow-md z-10" >
                  {#each suppliers as supplier}
                    <li on:click={() => selectSupplier(supplier)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{supplier.supplier_name}</li>
                  {/each}
                </ul>
                {/if}
            </div>
          </div>
        </div>
        <div class="flex justify-between gap-8 mx-4">
          <div class="w-full">
            <label for="password" class="select-none leading-6  block no-underline my-1 font-semibold ">Date</label>
            <div class="relative">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="stroke-[2px] absolute h-5 w-5 top-1.5 left-4 text-[#3d4c52]">
                <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
              </svg>
              <input type="text" readonly required
                bind:value={dateNow}
                class="focus:ring-2 h-8 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full px-12 py-2 text-sm leading-6 text-slate-900 rounded-3xl" >
            </div>
          </div>
          <div class="w-full">
          </div>
        </div>
        
    <div class=" outline outline-[1px] rounded-2xl mx-4 px-8 pt-4 pb-8 font-semibold text-xl mt-8 ">
      <div class="text-base">
        Products
      </div>
      <table class="w-full text-sm text-left rtl:text-right">
        <thead class="text-xs text-gray-700 uppercase bg-white">
          <tr class="border-b-2 border-black">
            <th scope="col" class="px-3 py-2 text-sm font-bold uppercase text-center">
              No
            </th>
            <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
              Product Name
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Batch
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Expired Date
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Stock In
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Unit Type
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Section Placement
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Action
            </th>
          </tr>
        </thead>
        <tbody>
          {#each products_to_be_added as product, i}
            <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
              <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                    {i+1}
              </th>
              <td class="px-1 py-2 text-center">
                {product.product_name}
              </td>
              <td class="px-1 py-2 text-center">
                {product.batch}
              </td>
              <td class="px-1 py-2 text-center">
                <DateConverter value={product.expired_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
              </td>
              <td class="px-1 py-2 text-center">
                {product.quantity}
              </td>
              <td class="px-1 py-2 text-center">
                {product.unit_type}
              </td>
              <td class="px-1 py-2 text-center">
                {product.section_placement}
              </td>
              <td class="px-1 py-2 text-center">
                <button on:click={() => deleteProductFromList(product.product_detail_id, product.expired_date, product.batch)} type="button" 
                  class="mt-2 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] hover:bg-[#F2AA7E] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg outline outline-[1px] px-3 py-3 text-center">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                    <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                  </svg>
                </button>
              </td>
            </tr>
          {/each}
        </tbody>
      </table>
      <div class=" relative flex items-end justify-end text-black mt-8 w-full">
        <button on:click={() => handleClick(1, true)} type="button" 
          class="z-10 flex items-center justify-center text-black bg-[#f7d4b2] hover:bg-[#F2AA7E] outline outline-[1px] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] focus:ring-4 focus:outline-none font-semibold text-base rounded-2xl px-3 py-1 text-center"
          disabled={stocks.length === 0}
          >
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="3" stroke="currentColor" class="size-3 mr-2">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
          </svg>
          Add Product
        </button>
      </div>
    </div>
   
  </div>
</div>
<div>
    <!-- Suppliers:
    {#each suppliers as supplier}
    {supplier.supplier_id}, {supplier.supplier_name} & 
    {/each}
    <br>
    All Suppliers:
    {#each suppliers as supplier}
    {supplier.supplier_id}, {supplier.supplier_name} & 
    {/each}
    <br>
    Stocks:
    {#each stocks as stock}
      {stock.ProductDetails.product_detail_id}, {stock.ProductDetails.product_name} & 
    {/each}
    <br>
    All Stocks:
    {#each all_stocks as stock}
      {stock.ProductDetails.product_detail_id}, {stock.ProductDetails.product_name} & 
    {/each}
    <br>
    Filtered for Double Value:
    {#each filteredStock as stock}
      {stock.ProductDetails.product_detail_id}, {stock.ProductDetails.product_name} & 
    {/each}
    <br>
    Product to Transfer:
    {#each products_to_be_added as stock}
      {stock.product_detail_id}, {stock.product_name} & 
    {/each}
    <br> -->
    <!-- Expired Date of Selected Product:
    {#each expiredDateOfSelectedProduct as stock}
      {stock.ProductDetails.product_detail_id}, {stock.ProductDetails.product_name}, {stock.ProductDetails.pro} & 
    {/each}
    <br>
    ShowModal: {showModal}
    <br>
    Back: {back} -->
</div>
    
    <div class="flex items-center justify-center my-2">
      <button on:click={() => addProducts()} type="button" 
        class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] flex items-center justify-center text-black bg-[#f7d4b2] hover:bg-[#F2AA7E] outline outline-[1px] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] focus:ring-4 focus:outline-none font-semibold text-lg rounded-2xl px-16 py-1 my-3 text-center"
        disabled={products_to_be_added.length === 0}>
        Submit
      </button>
    </div>
  </div>
</div>

{#if showModal === 1}

<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Add Product</div>
  </div>
      
  <form class="my-4 p-4 md:p-5 font-roboto text-sm font-medium">
    <div>
      <div class="my-3">
        <div class="text-[#f7d4b2] mb-1">Product ID</div>
        <input type="text" bind:value={productId} on:click={toggleIDList} class="rounded-2xl w-full h-8 px-4"/>
        {#if all_stocks.length > 0 && showIDList}
          <ul class={`${all_stocks.length > 5 ? 'h-40' : 'h-fit'} mt-2 overflow-y-auto absolute w-1/4 bg-white shadow-md z-10`}>
            {#each all_stocks as stock}
              <li on:click={() => selectProduct(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.ProductDetails.product_detail_id} - {stock.ProductDetails.product_name}</li>
            {/each}
          </ul>
        {/if}
      </div>
      
      <div class="my-3">
        <div class="text-[#f7d4b2] mb-1">Product Name</div>
        <input type="text" bind:value={productName} on:click={toggleNameList} class="rounded-2xl w-full h-8 px-4"/>
        {#if all_stocks.length > 0 && showNameList}
        <ul class={`${all_stocks.length > 5 ? 'h-24' : 'h-fit'} mt-2 overflow-y-auto absolute w-1/4  bg-white shadow-md z-10`}>
          {#each all_stocks as stock}
            <li on:click={() => selectProduct(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.ProductDetails.product_name} - {stock.ProductDetails.product_detail_id}</li>
          {/each}
        </ul>
        {/if}
      </div>
    </div>
    {#if productId !== '' && productName !== '' && !back}
    <div>
      <div class="flex items-center justify-between gap-4">
        <div class="my-3 w-1/2">
          <div class="text-[#f7d4b2] mb-1">Product Batch</div>
          <input type="text" required
              bind:value={batch}
              class="focus:ring-2 h-8 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full px-4 py-2 text-md leading-6 text-slate-900 rounded-3xl" >
        </div>
        <div class="my-3 w-1/2">
          <div class="text-[#f7d4b2] mb-1">Product Expired Date</div>
          <input
            type="date"
            bind:value={expired_date}
            placeholder="dd/mm/yyyy"
            class="rounded-2xl w-full h-8 px-4"
          />
        </div>
      </div>
        
     
      <div class="flex items-center justify-between gap-4">
        <div class="my-3 w-1/2">
          <div class="text-[#f7d4b2] mb-1">Product Stock</div>
          <input type="number" required
              bind:value={quantity} min={0}
              class="focus:ring-2 h-8 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full px-4 py-2 text-md leading-6 text-slate-900 rounded-3xl">

        </div>

        <div class="my-3 w-1/2">
          <div class="text-[#f7d4b2] mb-1">Product Unit</div>
            <input type="text" bind:value={unit_type} class="rounded-2xl w-full h-8 px-4" readonly/>
        </div>
      </div>
      
      <div class="my-3">
        <div class="text-[#f7d4b2] mb-1">Location</div>
        <input type="text" bind:value={section_placement} class="rounded-2xl w-full h-8 px-4"/>
      </div>
    </div>
    {/if}
    <div class="flex items-center justify-center gap-8 mt-8">
      
      {#if back}
      <button type="button" on:click={() => closeModal()} class="mt-2 h-8 flex w-1/3 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline outline-[1px] hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-2xl text-xl px-4 py-1.5 text-center">
        Back
      </button>
      <button type="button" on:click={() => toggleBack()} class="mt-2 h-8 flex w-1/3 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-2xl text-xl px-4 py-1.5 text-center"
        disabled={productId === '' || productName === ''}>
        Submit
      </button>
      {:else}
      <button type="button" on:click={() => toggleBack()} class="mt-2 h-8 flex w-1/3 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline outline-[1px] hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-2xl text-xl px-4 py-1.5 text-center">
        Back
      </button>
      <button type="button" on:click={() => handleClick(2, false)} class="mt-2 h-8 flex w-1/3 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-2xl text-xl px-4 py-1.5 text-center">
        Submit
      </button>
      {/if}
    </div>
  </form>
</TaskModal> 

{:else if showModal === 2 }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Submit</div>
    </div>
    <form class="my-4 p-4 md:p-5 font-roboto text-xl">
          <div class="text-[#f7d4b2] font-medium text-center mb-8">
            Are you sure you want to submit the changes you've made?
          </div>
          <div class="flex items-center justify-center gap-4">
              <button type="button" on:click={() => handleClick(1, false)} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                Back
              </button>
              <button type="button" on:click={() => addProductToProductList()} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                Submit
              </button>
          </div>
    </form>
  </TaskModal> 
{/if}

