<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import receipt from '$lib/assets/receipt-1.png';
    import { goto } from '$app/navigation';
    import { uri, userId, roleId, sessionId, privileges} from '$lib/uri.js';
    import { onMount } from 'svelte';
    import exportPDF from '$lib/exportPDF.js';
    import { getFormattedDateForPrint } from '$lib/DateNow.js';
    import user_pp from "$lib/assets/user.png";

    export let data;
    let store_warehouse_id = data.store_warehouse_id;
    let product_id = data.product_detail_id;
    $: product = [];
    let user_pp_fetched = '';
    let showAddProduct = false;
    let products_to_transfer = [];
    let showBatchExpiredDate = false;
    $: stock_bundle = 1;
    $: productId = '';
    $: productName = '';
    $: filteredStock = [];
    $: maxstock_bundleQty = 1;
    let editMode = false;
    let products = [];
    let product_sorts = [];
    let categories = [];
    let sell_price = 0;
    let buy_price = 0;
    let current_stock = [];
    let stock_card = [];
    let ProductDetails = [];
    let ProductCategories = [];
    let Suppliers = [];
    let expired_dates = []; 
    let tampilan = '';
    let showModal = false;
    let showTable = false;
    let showTable1 = false;
    $: searchQuery_temp = '';
    let warehouse = [];
      
    let stocks = [];
    let all_stocks = [];
    let showIDList = false;
    let showNameList = false;
    let pd_id = 0;
    

    let questions = [
      { id: 1, text: `Yes.` },
      { id: 2, text: `No.` }
    ];
    let section_placement = '';
	  let selected = '';
    
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
    
    function toggleProductAdd() {
      showAddProduct = !showAddProduct;
    }
    function toggleTable(product_id) {
      showTable = !showTable;
    }
    function toggleTable1(product_id) {
      console.log(store_warehouse_id);
      showTable1 = !showTable1;
    }
    let add_stock_details = [];
    let ori_add_stock_details = [];

    $: edit_id = 0;
    $: isSame = true;
    
  async function fetchWarehouse() {
      const response = await fetch(`http://${$uri}:8888/store_warehouses/${store_warehouse_id}`, {
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
      console.log(warehouse);
  }
  async function fetchProducts() {
      const response = await fetch(`http://${$uri}:8888/products/store_warehouse/${$userId}/${$roleId}/${store_warehouse_id}///${searchQuery_temp}/////0/0`, {
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
    const transferredProductIds = new Set(products_to_transfer.map(product => product.ProductDetails.product_detail_id));

    stockList.forEach(stock => {
        if (stock.ProductDetails.product_stock > 0 && !transferredProductIds.has(stock.ProductDetails.product_detail_id)) {
            let existing = stockMap.get(stock.ProductDetails.product_detail_id);
            if (existing) {
                existing.ProductDetails.product_stock += stock.ProductDetails.product_stock;
            } else {
                stockMap.set(stock.ProductDetails.product_detail_id, {
                    ...stock,
                    ProductDetails: {
                        ...stock.ProductDetails,
                        product_stock: stock.ProductDetails.product_stock
                    }
                });
            }
        }
    });

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
    checkMaxValidstock_bundle();
    updateBuySellPrice();
  }
  function deleteProductFromList(product_id) {
      products_to_transfer = products_to_transfer.filter(stock => 
          stock.ProductDetails.product_detail_id !== product_id
      );
      updateFilteredStock();
      checkMaxValidstock_bundle();
      updateBuySellPrice();
  }
    async function getAddStocktDetails() {
        const response = await fetch(`http://${$uri}:8888/orders/supplier/detail/${add_stock_id}/''/100/0`, {
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
 
        let tmp = data.data;

        for (let i = 0; i < tmp.length; i++) {
            let ProductDetails = await getProductDetail(tmp[i].product_detail_id);
            tmp[i].product_name = ProductDetails.product_name;
            tmp[i].product_unit = ProductDetails.product_unit;
        }

        add_stock_details = tmp;
        ori_add_stock_details = structuredClone(tmp);

        console.log("add_Stock_details", add_stock_details);
    }
    
    async function getProductDetail(product_id) {
      console.log(product_id);
        const response = await fetch(`http://${$uri}:8888/products/all/${product_id}`, {
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
        ProductDetails = data.data[0].ProductDetails;
        ProductCategories = data.data[0].ProductCategories;
        Suppliers = data.data[0].Suppliers;

        console.log(product);
    }
    async function fetchStockCard(product_id) {
    // store_warehouse/:product_id/:storewarehouse_id/:limit/:offset
      const response = await fetch(`http://${$uri}:8888/products/stock/card/product/store_warehouse/${product_id}/${store_warehouse_id}/0/0`, {
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

      stock_card = [...data.data];  
  }
  async function fetchCurrentStock(product_id, sw_id) {
    console.log(`http://${$uri}:8888/products/stock/opname/data/store_warehouse/${sw_id}////${product_id}/////0/0`);
    // /products/stock/opname/data/store_warehouse/:sw_id/:product_name/:batch/:unit_type/:product_id/:expired_date/:category/:product_sort/:asc/:limit/:offset
    console.log(`http://${$uri}:8888/products/stock/opname/data/store_warehouse/${product_id}/${sw_id}/0/0`);
      const response = await fetch(`http://${$uri}:8888/products/stock/opname/data/store_warehouse/${product_id}/${sw_id}/0/0`, {
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

      current_stock = [...data.data];  
      console.log("current_stock", current_stock);
  }
  async function fetchProductPhotos(product_photo_fetched){
    const response = await fetch(`http://${$uri}:8888/file/${product_photo_fetched}`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    });

    if (!response.ok) {
        console.error('fetch user pp failed', response);
        return;
    }

      // Instead of expecting a JSON response, we handle the image as a blob
      const blob = await response.blob();

      // Convert the blob to an object URL so it can be used as the image source
      user_pp_fetched =  URL.createObjectURL(blob);
  }
    async function verifyAddStock(add_stock_id,status) {
        const response = await fetch(`http://${$uri}:8888/orders/supplier/verify/${add_stock_id}/${status}`, {
            method: 'PUT',
            headers: {
                    'Content-Type': 'application/json',
                },
            // body: JSON.stringify({
            //     actual_closing_cash,
            //     deposit_money
            // })
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
        // console.log("verify session :",data);
      }

    async function updateAddStock(atribut) {
      const response = await fetch(`http://${$uri}:8888/orders/supplier/update/stock/${add_stock_id}`, {
          method: 'PUT',
          headers: {
                  'Content-Type': 'application/json',
              },
          body: JSON.stringify(atribut)
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
      console.log("update detail add:",data);
     }
    
    async function deleteAddStockDetails(atribut) {
      const response = await fetch(`http://${$uri}:8888/orders/supplier/detail/${add_stock_id}`, {
          method: 'DELETE',
          headers: {
                  'Content-Type': 'application/json',
              },
          body: JSON.stringify(atribut)
      });

      if (!response.ok) {
          console.error('DELETE add stock details gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid DELETE add stock details', data);
          return;
      }
      // console.log("DELETE add stock details:",data);
     }

    async function applyChanges(){
      for (let i = 0; i < add_stock_details.length; i++) {
            if (add_stock_details[i].quantity != ori_add_stock_details[i].quantity){
              let atribut = {
                product_detail_id : add_stock_details[i].product_detail_id,
                expired_date : add_stock_details[i].expired_date,
                batch : add_stock_details[i].batch,
                quantity : add_stock_details[i].quantity,
              }
              console.log("atribut", JSON.stringify(atribut))
              updateAddStock(atribut)
            }
        }
        ori_add_stock_details = structuredClone(add_stock_details);
        isSameWithOri();
    }

    function isSameWithOri(){
      isSame = true;
      for (let i = 0; i < add_stock_details.length; i++) {
            if (add_stock_details[i].quantity != ori_add_stock_details[i].quantity){
              isSame = false;
            }
        }
        console.log(isSame);
      return isSame;
    }

    async function insertNotif(descriptionnya,type){
      console.log(descriptionnya);
      const response = await fetch(`http://${$uri}:8888/notifications/add`, {
          method: 'POST',
          body: JSON.stringify({
              user_id: Number($userId),
              roles_id: Number($roleId),
              description: descriptionnya,
              notification_type_id: type
          })
      });

      if (!response.ok) {
          console.error('POST new notif gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid post new notif', data);
          return;
      }
    }
    async function fetchExpiredDate(product_idNya, quantityNya, unit_typeNya) {
      console.log(`http://${$uri}:8888/orders/transfer/notes/check/${product_idNya}/${store_warehouse_id}/${quantityNya}`);
      const response = await fetch(`http://${$uri}:8888/orders/transfer/notes/check/${product_idNya}/${store_warehouse_id}/${quantityNya}`, {
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
    async function checkMaxValidstock_bundle(){
      maxstock_bundleQty = Infinity; // Start with the highest possible value

      for (const product of products_to_transfer) {
          const productStock = Number(product.ProductDetails.product_stock);
          const qty = Number(product.quantity);

          // If stock_bundle exceeds productStock, limit stock_bundle to productStock

          // Calculate bundleQty based on the limited stock bundle
          const bundleQty = Math.floor((productStock / qty));

          console.log(`For product with productStock ${productStock} and qty ${qty}:`);
          console.log(`Calculated bundleQty: ${bundleQty}, effectivestock_bundle: ${stock_bundle}`);

          // Set maxstock_bundleQty to the lowest bundleQty found
          if (bundleQty < maxstock_bundleQty) {
              maxstock_bundleQty = bundleQty;
          }
      }

      // Final check to ensure maxstock_bundleQty does not exceed the stock bundle
      if (stock_bundle > maxstock_bundleQty) {
          stock_bundle = maxstock_bundleQty;
      }
      console.log(maxstock_bundleQty);
      updateBuySellPrice();
    }
    async function updateBuySellPrice() {
        buy_price = 0;
        sell_price = 0;

        for (const product of products_to_transfer) {
            const buyPrice = Number(product.ProductDetails.buy_price);
            const sellPrice = Number(product.ProductDetails.sell_price);
            const qty = Number(product.quantity); 

            buy_price += buyPrice * qty; 
            sell_price += sellPrice * qty; 
        }
    }

    $: if ((productName !== searchQuery_temp || productId !== searchQuery_temp)){
      if (productName !== ''){
        searchQuery_temp = productName;
      }
      if (productId !== ''){
        searchQuery_temp = productId;
      }
      fetchProducts();
    } else{
      searchQuery_temp = '';
    }
    $: if (productName === '' && productId === ''){
      searchQuery_temp = '';
      fetchProducts();
    }
    
    async function prepareProductsForSending(products) {
      let preparedProducts = {
          new_product_batch: new Date().toISOString().slice(2, 19).replace(/[-T:]/g, ""), // YYMMDDHHmmss format
          stock_bundle: Number(stock_bundle),
          buy_price: Number(buy_price),
          sell_price: Number(sell_price),
          product_bundle_detail_id: Number(product_id),
          product_bundling: [],
          display: 0,
          section_placement: section_placement,

      };

      for (const product of products) {
          expired_dates = [];
          await fetchExpiredDate(product.ProductDetails.product_detail_id, product.quantity * stock_bundle, product.ProductDetails.unit_type);

          if (Array.isArray(expired_dates) && expired_dates.length > 0) {
              expired_dates.forEach(item => {
                  preparedProducts.product_bundling.push({
                      product_detail_id: Number(product.ProductDetails.product_detail_id),
                      qty_subtracts: Number(item.product_stock),
                      expiry_date: item.expired_date,
                      product_batch: item.product_batch
                  });
              });
          }
      }

      return preparedProducts;
  }

  let products_to_send_fix = [];
  async function sendProducts() {
      products_to_send_fix = await prepareProductsForSending(products_to_transfer);
      console.log("Products to Send:", products_to_send_fix);

      if (products_to_send_fix.length === 0) {
          console.error('No products to send');
          return;      
      }

      const response = await fetch(`http://${$uri}:8888/products/stock/bundle/${store_warehouse_id}`, {
          method: 'POST',
          body: JSON.stringify(products_to_send_fix),
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('POST transfer note failed', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid POST transfer note response', data);
          return;
      }

      tampilan = "";
      showModal = false;
      await getProductDetail(product_id);
      await fetchStockCard(product_id);
      await fetchCurrentStock(product_id, store_warehouse_id);
      await fetchProductPhotos(ProductDetails.product_photo);
  }
  async function resetVariables(){
    productId = '';
    productName = '';
  }

    onMount(async () => {
      await getProductDetail(product_id);
      await fetchStockCard(product_id);
      await fetchCurrentStock(product_id, store_warehouse_id);
      await fetchProductPhotos(ProductDetails.product_photo);
      await fetchProducts();
      await fetchWarehouse();
    });
  </script>

  <div class="mt-[90px] mx-8 mb-10 pb-10 p-3 flex flex-col items-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={backToAddStock} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">{ProductDetails.product_name}</span>      
    <div class="w-full  justify-start items-center mb-4 px-8 flex gap-x-2 gap-y-4">
      {#if tampilan == "add_stock"}
          <button on:click={async() => {tampilan = ""; tampilan = tampilan; editMode = false; }} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">View</button>
      {:else}
      <button on:click={async() => {tampilan = ""; tampilan = tampilan; editMode = false; }} class="bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">View</button>
      {/if}
      {#if tampilan == "add_stock"}
          <button on:click={async() => {tampilan = "add_stock"; tampilan = tampilan; editMode = false; }} class="bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Add Stock</button>
      {:else}
          <button on:click={async() => {tampilan = "add_stock"; tampilan = tampilan; editMode = false; }} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Add Stock</button>
      {/if}
  </div>
  {#if tampilan !== "add_stock"}
  <div class="flex w-full mb-10">
      <div class="flex flex-col w-2/3 font-semibold text-darkGray pl-8">
          <div class="flex flex-col my-2">
              <span class="text-peach2">Product ID</span>
              <span class="">{ProductDetails.product_detail_id}</span>
          </div>
          <div class="flex flex-col my-2">
              <span class="text-peach2">Product Code</span>
              <span class="">{ProductDetails.product_code}</span>
          </div>
          <div class="flex flex-col my-2">
              <span class="text-peach2">Product Name</span>
              <span class="">{ProductDetails.product_name}</span>
          </div>
          <div class="flex flex-col my-2">
              <span class="text-peach2">Product Brand</span>
              <span class="">{Suppliers.supplier_name}</span>
          </div>
          <div class="flex flex-col my-2">
            <span class="text-peach2">Product Type</span>
            <span class="">{ProductCategories.product_category_name}</span>
          </div>
          <div class="flex flex-col my-2">
            <span class="text-peach2">Date Added</span>
            <DateConverter value={ProductDetails.product_timestamp} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
          </div>
          <div class="">
            <div class="text-peach2 my-2">Current Stock
              <button on:click={() => toggleTable1(ProductDetails.product_detail_id)} class="ml-2">
                {#if showTable1}
                  <i class="fa-solid fa-caret-up"></i>
                {:else}
                  <i class="fa-solid fa-caret-down"></i>
                {/if}
              </button>
            </div>
          {#if showTable1 && current_stock.length > 0}
            <div class="relative overflow-x-auto shadow-md w-fit rounded-lg">
              <table class="w-fit rounded-lg text-sm text-left rtl:text-right">
                <thead class="text-xs text-gray-700 uppercase bg-gray-100">
                  <tr class="border-b-2 border-black">
                    <th scope="col" class="px-3 py-2 text-sm font-bold uppercase text-center">
                      Batch
                    </th>
                    <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                      Expiry Date
                    </th>
                    <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                      Stock
                    </th>
                    <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                      Unit Type
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {#each current_stock as stock, i}
                    <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                      <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                        {stock.batch}
                      </th>
                      <td class="px-1 py-2 text-center">
                        <DateConverter value={stock.expired_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                      </td>
                      <td class="px-1 py-2 text-center">
                        {stock.expected_stock}
                      </td>
                      <td class="px-1 py-2 text-center">
                        {stock.unit_type}
                      </td>
                    </tr>
                  {/each}
                </tbody>
              </table>
            </div>
          {/if}
          </div>
          <!-- <div class="my-2">
            <div class="text-peach2">Last Inventory Taking</div>
            <div class="">{ProductDetails.product_name}</div>
          </div> -->
          <div class="my-2">
            <div class="text-peach2">
              Stock Card
              <button on:click={() => toggleTable(ProductDetails.product_detail_id)} class="ml-2">
                {#if showTable}
                   <i class="fa-solid fa-caret-up"></i>
                {:else}
                   <i class="fa-solid fa-caret-down"></i>
                {/if}
             </button>
            </div>
            {#if showTable && stock_card.length > 0}
            <div class="printable-section">
              <div class="relative overflow-x-auto shadow-md sm:rounded-lg ">
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
            </div>
            <div class=" flex items-center justify-start">
              <button type="button" 
              on:click={() => exportPDF(window.location.origin+`/print_stock_card/${$uri}/${ProductDetails.product_detail_id}/${store_warehouse_id}`, `StockCard_${ProductDetails.product_detail_id}_${warehouse.store_warehouse_name}_PrintedOn${getFormattedDateForPrint()}`, 190)}
              class="mt-2 flex w-56 items-center justify-start text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-md py-1.5 text-center">
                <div class="w-2/12 flex justify-center ml-2">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096m-.72-.096L17.66 18m0 0 .229 2.523a1.125 1.125 0 0 1-1.12 1.227H7.231c-.662 0-1.18-.568-1.12-1.227L6.34 18m11.318 0h1.091A2.25 2.25 0 0 0 21 15.75V9.456c0-1.081-.768-2.015-1.837-2.175a48.055 48.055 0 0 0-1.913-.247M6.34 18H5.25A2.25 2.25 0 0 1 3 15.75V9.456c0-1.081.768-2.015 1.837-2.175a48.041 48.041 0 0 1 1.913-.247m10.5 0a48.536 48.536 0 0 0-10.5 0m10.5 0V3.375c0-.621-.504-1.125-1.125-1.125h-8.25c-.621 0-1.125.504-1.125 1.125v3.659M18 10.5h.008v.008H18V10.5Zm-3 0h.008v.008H15V10.5Z" />
                  </svg>
                </div>
                <div class="w-10/12 text-start ml-2">
                  Print stock card
                </div>
              </button>
            </div>
            {/if}
          </div>

          <div class="flex flex-col my-2">
            <span class="text-peach2">Buy Price</span>
            <MoneyConverter value={ProductDetails.buy_price} currency={true} decimal={true}></MoneyConverter>
          </div>
          <div class="flex flex-col my-2">
            <span class="text-peach2">Sell Price</span>
            <MoneyConverter value={ProductDetails.sell_price} currency={true} decimal={true}></MoneyConverter>
          </div>
          <div class="flex flex-col my-2">
            <span class="text-peach2">Minimum Stock</span>
            <span class="">{ProductDetails.min_stock}</span>
          </div>
      </div>
      <div class="flex flex-col w-1/3">
        <div class="flex flex-col my-2">
          <span class="text-peach font-semibold mb-1">Product Picture</span>
            {#if user_pp_fetched !== ''}
              <img src={user_pp_fetched} class="w-40 rounded-xl border border-darkGray" alt="Profile Picture">
            {:else}
              <img src={user_pp} class="w-40 rounded-xl border border-darkGray" alt="Default Picture">
            {/if}
        </div>
      </div>
  </div>
  {:else}
    <div class="w-full p-10 font-semibold text-xl mt-5 ">
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
              Batch & Expired Date
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Stock
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Stock / Bundling
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Total Stock Subtract
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Buy Price
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Sell Price
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Unit Type
            </th>
            <th scope="col" class="px-1 py-2 text-sm font-bold uppercase text-center">
              Action
            </th>
          </tr>
        </thead>
        <tbody>
          {#each products_to_transfer as product, i}
            <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
              <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                    {i+1}
              </th>
              <td class="px-1 py-2 text-center">
                {product.ProductDetails.product_name}
              </td>
              <td class="px-1 py-2 text-center ">
                <div class="flex justify-center">
                  <button on:click={() => toggleShowBatchExpiredDate(product.ProductDetails.product_detail_id, product.quantity * stock_bundle, product.ProductDetails.product_unit)} type="button" 
                    class="mt-2 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] hover:bg-[#F2AA7E] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg outline outline-[1px] px-3 py-1 text-center">
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
                <input 
                  type="text"
                  max={product.ProductDetails.product_stock / stock_bundle} 
                  min={1} 
                  bind:value={product.quantity}
                  class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"
                  on:change={checkMaxValidstock_bundle}
                  on:input={(e) => {
                    const input = e.target;
              
                    // Store the current cursor position
                    const cursorPos = input.selectionStart;
              
                    // Remove all characters except digits and decimal points
                    let cleanedValue = input.value.replace(/[^0-9.]/g, '');
              
                    // If there's more than one decimal point, keep only the first
                    const parts = cleanedValue.split('.');
                    if (parts.length > 2) {
                      cleanedValue = parts[0] + '.' + parts.slice(1).join('');
                    }
              
                    // Update the product quantity with the cleaned value
                    product.quantity = cleanedValue;
              
                    // Ensure the value doesn't exceed expected_stock or go below 0
                    const numericValue = parseFloat(cleanedValue);
                    if (numericValue > (product.ProductDetails.product_stock / stock_bundle)) {
                      product.quantity = (product.ProductDetails.product_stock / stock_bundle).toString(); // Set to max
                    } else if (numericValue < 1) {
                      product.quantity = '1'; // Set to min
                    } else {
                      product.quantity = numericValue ? numericValue.toString() : ''; // Set to valid value or empty if NaN
                    }
              
                    // Restore cursor position
                    input.setSelectionRange(cursorPos, cursorPos);
                    checkMaxValidstock_bundle();
                  }}
                />
              </td>
              <td class="px-1 py-2 text-center">
                {product.quantity * stock_bundle}
              </td>
              <td class="px-1 py-2 text-center">
                {product.ProductDetails.buy_price}
              </td>
              <td class="px-1 py-2 text-center">
                {product.ProductDetails.sell_price}
              </td>
              <td class="px-1 py-2 text-center">
                {product.ProductDetails.product_unit}
              </td>
              <td class="px-1 py-2 text-center">
                <button on:click={() => deleteProductFromList(product.ProductDetails.product_detail_id)} type="button" 
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
      {#if products_to_transfer.length > 0}
      <div class="w-[32rem] my-4">
        <div class="px-1 py-2 w-full grid grid-cols-3 items-center">
          <span class="text-base px-4 col-span-2">Stock for This Bundle Product: </span>
          <input 
            type="text"
            bind:value={stock_bundle}
            max={maxstock_bundleQty} 
            min={1} 
            class="rounded-lg h-8 w-full text-end py-1"
            on:input={(e) => {
              const input = e.target;
              const cursorPos = input.selectionStart;
              let cleanedValue = input.value.replace(/[^0-9.]/g, '');
              const parts = cleanedValue.split('.');
              if (parts.length > 2) {
                cleanedValue = parts[0] + '.' + parts.slice(1).join('');
              }
              stock_bundle = cleanedValue;
              const numericValue = parseFloat(cleanedValue);
              if (numericValue > maxstock_bundleQty) {
                stock_bundle = maxstock_bundleQty.toString();
              } else if (numericValue < 1) {
                stock_bundle = '1'; 
              } else {
                stock_bundle = numericValue ? numericValue.toString() : ''; 
              }
              input.setSelectionRange(cursorPos, cursorPos);
            }}
          />
        </div>
        <div class="px-1 py-2 w-full grid grid-cols-3 items-center">
          <span class="text-base px-4 col-span-2">Total Buy Price: </span>
          <span class="text-base w-full pr-3 text-end py-2"><MoneyConverter value={buy_price} currency={true} decimal={false} ></MoneyConverter></span>
        </div>
        <div class="px-1 py-2 w-full grid grid-cols-3 text-left items-center">
          <span class="text-base px-4 col-span-2">Total Sell Price: </span>
          <MoneyInput bind:value={sell_price} shadow={false} end={true}/>
        </div>
        <div class="px-1 py-2 w-full grid grid-cols-3  items-center">
          <span class="text-base px-4 col-span-2">Section Placement: </span>
          <input bind:value={section_placement} type="text" class="rounded-lg font-semibold text-sm w-full h-8 text-end py-1" />
        </div>
        <!-- <div class="px-1 py-2 flex items-center justify-between">
          <span class="text-base px-4">Display: </span>
          <select class="px-2 font-semibold text-sm rounded-lg w-20 h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"  bind:value={selected} onchange={() => (answer = '')}>
            {#each questions as question}
              <option class="" value={question}>
                {question.text}
              </option>
            {/each}
          </select>
        </div> -->
      </div>
      {/if}
    </div>
    <div class="relative flex items-center justify-center w-full">
      <!-- Horizontal Line behind the button -->
      <hr class="absolute w-1/2 border-t-[1px] border-black  top-1/2 transform -translate-y-1/2"/>
    
      <!-- Button in front of the line -->
      <button on:click={toggleProductAdd} type="button" 
        class="z-10 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#F2AA7E] outline outline-[1.5px] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg px-3 py-3 text-center">
        
        <!-- SVG Icon -->
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
          <path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" />
        </svg>
    
      </button>
    </div>
    {#if showAddProduct}
    <div class="relative mt-8 flex items-center justify-center w-full">
      <div class="rounded-lg w-1/3 p-4 outline outline-1 bg-white text-black gap-2">
        <button class="" on:click={resetVariables}>Reset</button>
        <div class="my-3">
          <div class="font-semibold">Product ID</div>
          <input type="text" bind:value={productId} on:click={toggleIDList} class="rounded-lg w-full h-8 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)]"/>

          {#if filteredStock.length > 0 && showIDList}
            <ul class={`${filteredStock.length > 5 ? 'h-40' : 'h-fit'} mt-2 overflow-y-auto absolute w-1/4 bg-white shadow-md z-10`}>
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
          <ul class={`${filteredStock.length > 5 ? 'h-40' : 'h-fit'} mt-2 overflow-y-auto absolute w-1/4 bg-white shadow-md z-10`}>
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

    <div class="flex items-center justify-center my-8">
      <button on:click={() => handleClick()} type="button" 
        class="mt-2 flex items-center justify-center bg-[#3d4c52] text-[#F2AA7E] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] hover:bg-darkGray focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg px-12 py-3 text-center"
        >
        Submit
      </button>
    </div>
  {/if}
      
  </div>

  {#if showModal}
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Submit</div>
    </div>
    <form class="my-4 p-4 md:p-5 font-roboto text-xl">
          <div class="text-[#f7d4b2] font-medium text-center mb-8">
            Are you sure you want to submit the assignment to an admin for review?
          </div>
          <div class="flex items-center justify-center gap-4">
              <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                Back
              </button>
              <button type="button" on:click={() => sendProducts()} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                Submit
              </button>
          </div>
    </form>
  </TaskModal> 
{/if}


  
  
