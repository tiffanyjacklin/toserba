<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import receipt from '$lib/assets/receipt-1.png';
    import { uri, userId, roleId, storeId, sw_name } from '$lib/uri.js';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';

    export let data;
    let store_warehouse_id = data.store_warehouse_id;
    let transfer_note_id = data.transfer_note_id;
    let showModal = false;
    let last_id = 0;
    $: tf_details = [];
    $: ori_tf_details = [];
    $: tf_note = [];
    $: sw_from = [];
    $: sw_to = [];
    $: sw_id_from = '';
    $: produk = [];
    $: product = [];
    $: filteredProduk = [];

    $: edit_id = 0;
    $: isSame = true;
    $: showAddProduct = false;
    $: showDropDown = false;

    $: productId = '';
    $: productName = '';
    $: filteredStock = [];
    $: searchQuery = '';
    
    let stocks = [];
    let all_stocks = [];
    let products_to_transfer = [];
    let expired_dates = []; 
    let showIDList = false;
    let showNameList = false;
    let pd_id = 0;
    let showBatchExpiredDate = false;

    function toggleIDList() {
      showIDList = !showIDList;
      showNameList = false;
    }
    function toggleNameList() {
      showNameList = !showNameList;
      showIDList = false;
    }
    function closeModal() {
      showModal = false;
    }
    function handleClick() {
      showModal = true;
    }
    function backToAddStock(){
      goto(`/manage_inventory/${store_warehouse_id}`);
    }
    async function toggleshowAddProduct(){
      showAddProduct = !showAddProduct;
      await fetchProducts();

    }
    async function getStockCanBeSent(product_idNya, exp_dateNya, batchNya) {
      console.log(product_idNya,sw_id_from,exp_dateNya,batchNya);
        const response = await fetch(`http://${$uri}:8888/products/stock/card/product/total_stock/${product_idNya}/${sw_id_from}/${exp_dateNya}/${batchNya}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all supplier fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch suppliers', data);
            return;
        }
        console.log(data.data);
        return data.data.product_stock;
    }
    async function getTransferNotesDetails() {
        const response = await fetch(`http://${$uri}:8888/orders/transfer/notes/detail/${transfer_note_id}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all supplier fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch suppliers', data);
            return;
        }
        tf_details = data.data;
        tf_details = await Promise.all(tf_details.map(async (detail) => {
            const stock_can_be_sent = await getStockCanBeSent(detail.product_detail_id, detail.expired_date, detail.batch);
            return {
                ...detail,
                stock_can_be_sent
            };
        }));
        last_id = tf_details.length > 0 ? tf_details.length - 1 : 0;    

        console.log("tf_details with stock_can_be_sent", tf_details);
        ori_tf_details = structuredClone(tf_details);
        console.log("tf_details with", ori_tf_details);

        // ori_tf_details = structuredClone(tf_details);

    }
    async function fetchTransferNote() {
        const response = await fetch(`http://${$uri}:8888/orders/transfer/notes/${transfer_note_id}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all supplier fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch suppliers', data);
            return;
        }
 
        tf_note = data.data;
        console.log(tf_note)

        let from = await getStoreWarehouse(tf_note.store_warehouse_from);
        let to = await getStoreWarehouse(tf_note.store_warehouse_to);

        sw_id_from = from.store_warehouse_id;
        console.log("dui",sw_id_from);
        tf_note.from_warehouse_name = from.store_warehouse_name;
        tf_note.from_warehouse_address = from.store_warehouse_address;
        
        tf_note.to_warehouse_name = to.store_warehouse_name;
        tf_note.to_warehouse_address = to.store_warehouse_address;
    }
    async function getStoreWarehouse(sw_id) {
        const response = await fetch(`http://${$uri}:8888/store_warehouses/${sw_id}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all supplier fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch suppliers', data);
            return;
        }
 
        return data.data;
    }
    // add products yg g ada di transfer note lama
    function toggleShowBatchExpiredDate(product_detail_idNya, quantityNya, unit_typeNya) {
      if (showBatchExpiredDate && pd_id === product_detail_idNya) {
        showBatchExpiredDate = false;
        expired_dates = [];
        pd_id = 0;
      } else {
        expired_dates = [];
        showBatchExpiredDate = true;
        pd_id = product_detail_idNya;
        fetchExpiredDate(product_detail_idNya, quantityNya, unit_typeNya);
      }
    }
    async function fetchExpiredDate(product_idNya, quantityNya, unit_typeNya) {

        const response = await fetch(`http://${$uri}:8888/orders/transfer/notes/check/${product_idNya}/${sw_id_from}/${quantityNya}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('Fetch expired date failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid expired date fetch', data);
            return;
        }

        console.log(data.data)
        expired_dates = data.data.map(item => ({
            expired_date: item.expired_date,
            product_batch: item.product_batch,
            product_stock: item.product_stock,
            unit_type: unit_typeNya
        }));
        console.log(expired_dates);
    }
    async function fetchProducts() {
        const response = await fetch(`http://${$uri}:8888/products/store_warehouse/${$userId}/${$roleId}///${searchQuery}/////0/0`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('Fetch stock opname failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid stock opname fetch', data);
            return;
        }

        stocks = [...data.data];  
        all_stocks = stocks.filter(item => item.ProductDetails.product_stock > 0);
        updateFilteredStock();
    }
    function updateFilteredStock() {
      filteredStock = checkProducts(all_stocks);
      console.log("Filtered Stock:", filteredStock);
    }
    function checkProducts(stockList) {
    let stockMap = new Map();

    // Combine product_detail_id from both products_to_transfer and tf_details
    const transferredProductIds = new Set([
        ...products_to_transfer.map(product => product.ProductDetails.product_detail_id),
        ...tf_details.map(detail => detail.product_detail_id)
    ]);

    stockList.forEach(stock => {
        const productId = stock.ProductDetails.product_detail_id;

        // Check if the product exists in the combined set and has stock
        if (stock.ProductDetails.product_stock > 0 && !transferredProductIds.has(productId)) {
            let existing = stockMap.get(productId);

            if (existing) {
                // If the product already exists in the map, add its stock to the existing entry
                existing.ProductDetails.product_stock += stock.ProductDetails.product_stock;
            } else {
                // Otherwise, add it to the map
                stockMap.set(productId, {
                    ...stock,
                    ProductDetails: {
                        ...stock.ProductDetails,
                        product_stock: stock.ProductDetails.product_stock
                    }
                });
            }
        }
    });

    // Return the products that are not in products_to_transfer and tf_details
    return Array.from(stockMap.values());
}

    function selectProduct(stock) {
        productId = stock.ProductDetails.product_detail_id;
        productName = stock.ProductDetails.product_name;
        updateFilteredStock();
        showIDList = false;
        showNameList = false;
    }
    function addProductToProductList(productIdnya, productNamenya) {
      let filteredProducts = filteredStock.filter(stock => 
          stock.ProductDetails.product_detail_id === productIdnya && 
          stock.ProductDetails.product_name.toLowerCase().includes(productNamenya.toLowerCase())
      );

      filteredProducts = filteredProducts.map(product => {
          const existingProduct = products_to_transfer.find(transfer =>
              transfer.ProductDetails.product_detail_id === product.ProductDetails.product_detail_id
          );

          if (!existingProduct) {
              return {
                  ...product,
                  quantity: 1
              };
          }
          return null;
      }).filter(product => product !== null);
      products_to_transfer = [...products_to_transfer, ...filteredProducts];
      product = [];
      productId = ''; 
      productName = '';
      updateFilteredStock();
    }
    function deleteProductFromList(product_id) {
        products_to_transfer = products_to_transfer.filter(stock => 
            stock.ProductDetails.product_detail_id !== product_id
        );
        updateFilteredStock();
    }
    async function prepareProductsForSending(products) {
        let preparedProducts = [];

        for (const product of products) {
            expired_dates = [];
            await fetchExpiredDate(product.ProductDetails.product_detail_id, product.quantity, product.ProductDetails.unit_type);

            if (Array.isArray(expired_dates) && expired_dates.length > 0) {
                expired_dates.forEach(item => {
                    preparedProducts.push({
                        product_detail_id: product.ProductDetails.product_detail_id,
                        quantity: item.product_stock,
                        expired_date: item.expired_date,
                        batch: item.product_batch
                    });
                });
            }
        }
        
        return preparedProducts;
    }
    let products_to_send_fix = [];
    async function addSendProducts() {
        products_to_send_fix = await prepareProductsForSending(products_to_transfer);
        console.log("Products to Send:", products_to_send_fix);

        if (products_to_send_fix.length === 0) {
            console.error('No products to send');
            return;      
        }

        const response = await fetch(`http://${$uri}:8888/orders/transfer/detail/add/product/${transfer_note_id}`, {
            method: 'POST',
            body: JSON.stringify(products_to_send_fix),
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('POST InsertProductToTransferNoteDetails failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid POST InsertProductToTransferNoteDetails response', data);
            return;
        }

        console.log("aa",data.data);
        products_to_transfer = [];
        await getTransferNotesDetails();
    }
      



    async function verifyAssignProduk(status) {
        const response = await fetch(`http://${$uri}:8888/orders/transfer/notes/verify/${transfer_note_id}/${status}`, {
            method: 'PUT',
            headers: {
                    'Content-Type': 'application/json',
                },
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
    }
    async function updateTFdetails(product_detail_id,quantity) {
      const response = await fetch(`http://${$uri}:8888/orders/transfer/detail/update/product/${transfer_note_id}/${product_detail_id}/${quantity}`, {
          method: 'PUT',
          headers: {
                  'Content-Type': 'application/json',
              },
      });

      if (!response.ok) {
          console.error('PUT quantity tf detail gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid put quantity tf detail', data);
          return;
      }
      console.log("update quantity detail:",data);
    }
    async function deleteTFDetails(product_detail_id, batchh, exp_date) {
      const response = await fetch(`http://${$uri}:8888/orders/transfer/detail/delete/product/${transfer_note_id}/${product_detail_id}/${batchh}/${exp_date}`, {
          method: 'DELETE',
          headers: {
                  'Content-Type': 'application/json',
              },
        //   body: JSON.stringify(atribut)
      });

      if (!response.ok) {
          console.error('DELETE transfer note details gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid DELETE transfer note details', data);
          return;
      }
      // console.log("DELETE add stock details:",data);
    }
    async function applyChanges(){
      if (!isSame){
        for (let i = 0; i < tf_details.length; i++) {
          if (tf_details[i].quantity != ori_tf_details[i].quantity){
            updateTFdetails(tf_details[i].product_detail_id, tf_details[i].quantity)
          }
        }
        ori_tf_details = structuredClone(tf_details);
        isSameWithOri();
      }
      if (products_to_transfer.length > 0){
        addSendProducts();
      }
    }
    function isSameWithOri(){
      isSame = true;
      for (let i = 0; i < tf_details.length; i++) {
            if (tf_details[i].quantity != ori_tf_details[i].quantity){
              isSame = false;
            }
        }
        console.log(isSame);
      return isSame;
    }
    onMount(async () => {
      await fetchTransferNote();
      await getTransferNotesDetails();
      await fetchProducts();
    });
   
  </script>

  <div class="mt-[90px] mx-8 mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={backToAddStock} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-4">Assign Product</span>       
    <div class="w-11/12 overflow-x-auto">
      <div class="flex flex-col my-4">
        <div class="my-2 flex flex-col">
          <span class="text-xl font-bold mb-1">Origin</span>
          <span class="text-xl">{tf_note.from_warehouse_name}, {tf_note.from_warehouse_address}</span>
        </div>
        <div class="my-2 flex flex-col">
          <span class="text-xl font-bold mb-1">Origin</span>
          <span class="text-xl">{tf_note.to_warehouse_name}, {tf_note.to_warehouse_address}</span>
        </div>
      </div>
    </div>
    <div class="w-11/12 overflow-x-auto shadow-md sm:rounded-lg">
        <table class="w-full text-sm text-left rtl:text-right">
          <thead class="text-xs text-gray-700 uppercase bg-gray-100">
            <tr class="border-b-2 border-black">
              <th scope="col" class="px-3 py-2 text-sm font-bold uppercase text-center">
                  No
              </th>
              <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                  Product Name
              </th>
              <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                  Batch - Expired Date
              </th>
              <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                  Stock
              </th>
              <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                Stock to Send
              </th>
              <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                Unit Type
              </th>
              <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                Action
              </th>
            </tr>
          </thead>
          <tbody>
            
            {#each tf_details as produk, i}
            <div class="hidden">{last_id = i}</div>
              <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                      {i+1}
                </th>
                <td class="px-1 py-2 text-center">
                  <span class="my-1">{produk.product_name}</span>
                </td>
                <td class="px-1 py-2 text-center">
                  {produk.batch} - {produk.expired_date}
                </td>
                <td class="px-1 py-2 text-center">
                  {produk.stock_can_be_sent}
                </td>
                <td class="px-1 py-2 text-center">
                  {#if edit_id == produk.transfer_note_detail_id}
                    <input step="10" bind:value={produk.quantity} max={produk.stock_can_be_sent} min={1} class="w-36 h-8 rounded-lg [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none" type="number">    
                  {:else}
                    {produk.quantity}
                  {/if}
                </td>
                <td class="px-1 py-2 text-center">
                  <span class="my-1">{produk.unit_type}</span>
                </td>
                <td class="px-1 py-2 text-center flex items-center justify-center">
                  <button on:click={() => {showModal = "Delete Confirmation";}} class="w-8 mx-1 p-1 bg-peach2 rounded-xl border border-darkGray">
                    <i class="fa-solid fa-trash-can"></i>                     
                  </button>
                  {#if edit_id == produk.transfer_note_detail_id}
                    <button on:click={() => {edit_id = 0; 
                        if (produk.quantity > produk.stock_can_be_sent){
                            produk.quantity = produk.stock_can_be_sent;
                        } else if (produk.quantity == 0){
                            produk.quantity = 1;
                        }; isSameWithOri();
                    }} class="w-8 mx-1 p-1 bg-peach rounded-xl border border-darkGray">
                      <i class="fa-solid fa-check"></i>                  
                    </button>
                  {:else}
                    <button on:click={() => edit_id = produk.transfer_note_detail_id} class="w-8 mx-1 p-1 bg-darkGray rounded-xl border border-darkGray">
                      <i class="fa-regular fa-pen-to-square" style="color: #FACFAD;"></i>                   
                    </button>
                  {/if}
                </td>
              </tr>
              {#if showModal === "Delete Confirmation" }
                <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
                  <div class="flex items-center justify-center pt-8 font-roboto">
                    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Delete Confirmation</div>
                  </div>
                  <form class="my-4 p-4 md:p-5 font-roboto text-xl">
                        <div class="text-[#ad9c8b] font-medium text-center mb-8">
                          Are you sure you want to delete 
                          <div class="m-4 text-peach">
                            <div>{produk.product_name}</div>
                            <div>Batch: {produk.batch} - {produk.expired_date}</div>
                          </div>
                          from transfer note?
                        </div>
                        <div class="flex items-center justify-center gap-4">
                            <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                              No
                            </button>
                            <button type="button" on:click={async() => {await deleteTFDetails(produk.product_detail_id, produk.batch, produk.expired_date); tf_details = []; await getTransferNotesDetails(); closeModal();}} 
                              class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                              Yes
                            </button>
                        </div>
                  </form>
                </TaskModal> 
              {/if}
              
              {#if showModal == "confirm_verify" }
                  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
                    <div class="flex items-center justify-center pt-8 font-roboto">
                      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Verify</div>
                    </div>
                    <form class="my-4 p-4 md:p-5 font-roboto text-xl">
                          <div class="text-[#ad9c8b] font-medium text-center mb-8">
                            Are you sure you want to verify the changes you've made?
                          </div>
                          <div class="flex items-center justify-center gap-4">
                              <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                                Back
                              </button>
                              <button type="button" on:click={async() => {await verifyAssignProduk(1); Swal.fire({
                                title: "Assign Product Diverify",
                                icon: "success",
                                color: "white",
                                background: "#364445",
                                confirmButtonColor: '#F2AA7E'
                              }); closeModal(); backToAddStock();}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                                Verify
                              </button>
                          </div>
                    </form>
                </TaskModal> 
              {/if}
              
              {#if showModal == "confirm_reject" }
                  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
                    <div class="flex items-center justify-center pt-8 font-roboto">
                      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Reject</div>
                    </div>
                    <form class="my-4 p-4 md:p-5 font-roboto text-xl">
                          <div class="text-[#f7d4b2] font-medium text-center mb-8">
                            Are you sure you want to verify the changes you've made?
                          </div>
                          <div class="flex items-center justify-center gap-4">
                              <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                                Back
                              </button>
                              <button type="button" on:click={async() => {await verifyAssignProduk(2); Swal.fire({
                                title: "Assign Produk Berhasil Direject",
                                icon: "success",
                                color: "white",
                                background: "#364445",
                                confirmButtonColor: '#F2AA7E'
                              }); closeModal(); backToAddStock();}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                                Reject
                              </button>
                          </div>
                    </form>
                </TaskModal> 
              {/if}

              {/each}
              {#each products_to_transfer as product, i}
              <tr class={(last_id + i + 1) % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                      {(last_id + i + 1)+1}
                </th>
                <td class="px-1 py-2 text-center">
                  {product.ProductDetails.product_name}
                </td>
                <td class="px-1 py-2 text-center ">
                  <div class="flex justify-center items-center ">
                    <button on:click={() => toggleShowBatchExpiredDate(product.ProductDetails.product_detail_id, product.quantity, product.ProductDetails.product_unit)} type="button" 
                      class="flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] hover:bg-[#F2AA7E] focus:ring-4 focus:outline-none font-semibold text-sm rounded-lg outline outline-[1px] px-3 py-1 text-center">
                      Show Details
                    </button>
                  </div>
                  {#if showBatchExpiredDate && pd_id === product.ProductDetails.product_detail_id}
                  <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute z-20 mt-2 w-1/4 bg-gray-100 p-4 rounded-lg font-roboto">
                    <span class="font-bold text-xl mb-4">Batch & Expired Date for {product.ProductDetails.product_name}</span>
                    <div class="mt-4 grid-cols-4 flex w-full flex-wrap">
                      <table class="w-full rounded-lg text-sm text-left rtl:text-right">
                        <thead class="text-xs text-gray-700 uppercase bg-white">
                          <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase">
                            No
                          </th>
                          <th scope="col" class="px-3 py-2 text-sm font-bold uppercase text-center">
                            Batch
                          </th>
                          <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase">
                            Expiry Date
                          </th>
                          <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase">
                            Stock
                          </th>
                          <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase">
                            Unit Type
                          </th>
                        </thead>
                        <tbody>
                          {#each expired_dates as exp_date, i}
                          <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                            <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                              {i+1}
                            </th>
                            <td class="px-1 py-2 text-center">
                              {exp_date.product_batch}
                            </td>
                            <td class="px-1 py-2 text-center">
                              <DateConverter value={exp_date.expired_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                            </td>
                            <td class="px-1 py-2 text-center">
                              {exp_date.product_stock}
                            </td>
                            <td class="px-1 py-2 text-center">
                              {exp_date.unit_type}
                            </td>
                          </tr>
                          {/each}
                        </tbody>
                      </table>
                    </div>
                    
                    <div class="flex justify-center font-semibold mt-4">
                        <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {toggleShowBatchExpiredDate(product.ProductDetails.product_detail_id, product.quantity, product.ProductDetails.product_unit)}}>Close</button>
                    </div>
                  </div>
                  {/if}
                </td>
                <td class="px-1 py-2 text-center">
                  {product.ProductDetails.product_stock}
                </td>
                <td class="px-1 py-2 text-center">
                  <input type="number" min={1} max={product.ProductDetails.product_stock} step="10" bind:value={product.quantity} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
                </td>
                <td class="px-1 py-2 text-center">
                  {product.ProductDetails.product_unit}
                </td>
                <td class="px-1 py-2 text-center">
                  <button on:click={() => deleteProductFromList(product.ProductDetails.product_detail_id)} class="w-8 mx-1 p-1 bg-peach2 rounded-xl border border-darkGray">
                    <i class="fa-solid fa-trash-can"></i>                     
                  </button>

                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>

      {#if tf_details.length >= 0}
          <div class="flex w-11/12 justify-end mt-4 mb-10">
            <button on:click={() => {tf_details = structuredClone(ori_tf_details); tf_details = tf_details; isSameWithOri(); products_to_transfer = [];}} class="mx-2 w-48 bg-darkGray text-peach border border-darkGray shadow py-1 rounded-2xl font-semibold text-xl">Reset</button>
            {#if !isSame || products_to_transfer.length > 0}
              <button on:click={async() => {await applyChanges(); }} class="mx-2 w-48 bg-peach text-darkGray border border-darkGray shadow py-1 rounded-2xl font-semibold text-xl">Apply Changes</button>
            {/if}
            <button on:click={() => {toggleshowAddProduct();}} class="mx-2 w-48 bg-peach2 text-darkGray border border-darkGray shadow py-1 rounded-2xl font-semibold text-xl"><i class="fa-solid fa-plus mr-1"></i>Add Product</button>
          </div>
        <hr class=" w-1/2 border-t-[1px] border-black  transform mb-8"/>

          {#if showAddProduct}
          <div class="relative mb-8 flex items-center justify-center w-full">
            <div class="rounded-lg w-1/3 p-4 outline outline-1 bg-white text-black gap-2">
              <div class="my-3">
                <div class="font-semibold">Product ID</div>
                <input type="text" bind:value={productId} on:click={toggleIDList} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>

                {#if filteredStock.length > 0 && showIDList}
                  <ul class="absolute w-1/4 bg-white shadow-md z-10">
                    {#each filteredStock as stock}
                      <li on:click={() => selectProduct(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.ProductDetails.product_detail_id} - {stock.ProductDetails.product_name}</li>
                    {/each}
                  </ul>
                {/if}
              </div>
              
              <div class="my-3">
                <div class="font-semibold">Product Name</div>
                <input type="text" bind:value={productName} on:click={toggleNameList} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>
                {#if filteredStock.length > 0 && showNameList}
                <ul class="absolute w-1/4  bg-white shadow-md z-10">
                  {#each filteredStock as stock}
                    <li on:click={() => selectProduct(stock)} class="p-2 cursor-pointer w-fit-content hover:bg-gray-200">{stock.ProductDetails.product_name} - {stock.ProductDetails.product_detail_id}</li>
                  {/each}
                </ul>
                {/if}
              </div>
              <div class="flex justify-center">
                <button on:click={() => addProductToProductList(productId, productName)} type="button" 
                  class="w-1/2 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#F2AA7E] outline outline-[1px] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg px-3 py-1 my-3 text-center">
                  Add
                </button>
              </div>
            </div>
          </div>
          {/if}

          <div class="flex justify-center mb-10">
            <button on:click={() => {showModal = "confirm_reject"; showModal = showModal;}} class="mx-6 w-48 bg-darkGray text-peach border border-darkGray shadow py-3 rounded-2xl font-semibold text-xl">Reject</button>
            <button on:click={() => {showModal = "confirm_verify"; showModal = showModal;}} class="mx-6 w-48 bg-peach2 text-darkGray border border-darkGray shadow py-3 rounded-2xl font-semibold text-xl">Verify</button>
          </div>
        {/if}
</div>


  
  
