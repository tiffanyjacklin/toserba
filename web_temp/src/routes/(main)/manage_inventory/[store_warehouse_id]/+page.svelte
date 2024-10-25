<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    // import DateNow from '$lib/DateNow';
    import { getFormattedDate, isInTimeRange, getFormattedDateForPrint } from '$lib/DateNow.js';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId } from '$lib/uri.js';
    import img_produk from "$lib/assets/produk.png";
    import exportPDF from '$lib/exportPDF.js';

    export let data;

    let store_warehouse_id = data.store_warehouse_id;
    let sw_name_print = '';
    $: tampilan = "products"
    let searchQuery_product = '';
    let searchQuery_stock = '';
    let searchQuery_verify = '';
    let searchQuery_category = '';
    let searchQuery_temp = '';
    let showModal = null; 
    let showTable = false;

    $: limit = 10; 
    $: offset = 0;
    $: currentPage = 1; 
    $: totalRows = 0;
    $: totalPages = Math.ceil(totalRows/limit);

    //BUAT FILTER
    let start_date = '';
    let end_date = '';
    let category = '';
    let unit_type = '';
    let start_price = 0;
    let end_price = 999999999;

    let showFilter = false;
    
    //PRODUCTS
    let products = [];
    let all_produk = [];
    let product_category = [];
    let suppliers = [];
    let stock_card_product = [];
    $: current_stock = [];

    // STOCK HISTORY
    let stock_card_history = [];
    let filtered_stock_card_history = [];

    //VERIFY ADD SUBTRACT
    let verify_add = [];
    let verify_subtract = [];

    //ASSIGN PRODUK
    let assign_product = [];

    // ADD NEW PRODUK
    let product_photo_fetched = '';
    let files;
    let imageUrl = '';
    let product_name = "";
    let product_code = "";
    let product_category_id = "";
    let supplier_id;
    let buy_price;
    let sell_price;
    let min_stock;
    let product_unit = "";
    let showTable1 = false;

    //ADD NEW CATEGORY
    let new_category_name = '';
    let filtered_product_category =[];

    $: tampilan_modal = "";
    
    $: if (files && (files.length > 0 || files !== '') ) {
      // Get the first file (for the avatar input)
      const file = files[0];

      // Check if the file is an image (optional)
      if (file && (file.type.startsWith('image/'))) {
        // Create an object URL for the image file
        imageUrl = URL.createObjectURL(file);
      } else {
        imageUrl = ''; // Clear the image URL if the file is not an image
      }
    }

    function handleClick(id) {
      showModal = id;
      console.log(id)
    }
    function closeModal() {
        showModal = null;
    }
    function toggleFilter() {
      showFilter = !showFilter;
    }
    async function toggleTable(id) {
        showTable = !showTable;
        if (showTable){
        await fetchStockCard(id);
        } else {
        stock_card_product = [];
        }
    }
    
    async function toggleTable1(id, sw_id) {
      showTable1 = !showTable1;
      if (showTable1){
        await fetchCurrentStock(id, store_warehouse_id);
      } else {
      stock_card_product = [];
      }
    }
    async function fetchCurrentStock(product_id, sw_id) {
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
      console.log(current_stock);
    }
    async function fetchProduk() {
        const response = await fetch(`http://${$uri}:8888/products/store_warehouse/${$userId}/${$roleId}/${store_warehouse_id}/${start_price}/${end_price}/${searchQuery_product}/${category}/${unit_type}/''/''/${limit}/${offset}`, {
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

        totalRows = data.total_rows;
        totalPages = Math.ceil(totalRows/limit);
        products = [...data.data];  
        all_produk = [...products];
        // console.log(all_produk);
    }

  async function fetchStockCard(product_id) {
    console.log(`http://${$uri}:8888/products/stock/card/product/store_warehouse/${product_id}/${store_warehouse_id}/0/0`);
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

      stock_card_product = [...data.data];  
  }

  async function fetchProductCategory() {
        const response = await fetch(`http://${$uri}:8888/products/category`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all product category fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch product category', data);
            return;
        }
 
        product_category = data.data;
        filtered_product_category = structuredClone(product_category);
        // console.log("product_category",product_category)
    }
  
    async function fetchSuppliers() {
        const response = await fetch(`http://${$uri}:8888/suppliers/all/''/100/0`, {
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
 
        suppliers = data.data;
        // console.log(suppliers);
    }
    
    async function fetchStockCardHistory() {
        const response = await fetch(`http://${$uri}:8888/products/stock/card/product/store_warehouse/${store_warehouse_id}/${start_date}/${end_date}/${category}/${unit_type}/''/${searchQuery_stock}/${limit}/${offset}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all stock card history fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch stock card history', data);
            return;
        }
        
        totalRows = data.total_rows;
        totalPages = Math.ceil(totalRows/limit);
        stock_card_history = data.data;
        filtered_stock_card_history = structuredClone(stock_card_history);
        // console.log("stockcard History",data);
    }

    async function fetchAddVerify() {
        const response = await fetch(`http://${$uri}:8888/orders/supplier/verify/0/''/${limit}/${offset}`, {
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
        
        totalRows = data.total_rows;
        totalPages = Math.ceil(totalRows/limit);
        verify_add = data.data;
        // console.log("verify_add : ",verify_add)
    }
    
    async function fetchSubtractVerify() {
        const response = await fetch(`http://${$uri}:8888/products/stock/subtract/verify/0/''/${limit}/${offset}`, {
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
 
        // verify_subtract = data.data;
        totalRows = data.total_rows;
        totalPages = Math.ceil(totalRows/limit);
        let tmp = data.data;

        for (let i = 0; i < tmp.length; i++) {
          let ProductDetails = await getProductDetail(tmp[i].product_detail_id);
          // console.log(ProductDetails);

            tmp[i].product_name = ProductDetails.product_name;
            tmp[i].product_stock = ProductDetails.product_stock;
            tmp[i].product_unit = ProductDetails.product_unit;
            
            let sw_name = await getStoreWarehouse(tmp[i].store_warehouse_id);
            tmp[i].sw_name = sw_name;
        }

        verify_subtract = tmp;
        // console.log(verify_subtract)
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
 
        let nama_wr = data.data.store_warehouse_name ;
        return nama_wr;
    }
    
    async function getAddStockDetails(add_stock_id) {
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
 
        let details = data.data;
        // console.log("length", details.length);
        return details.length;
    }

    async function AddNewProduct() {
        const response = await fetch(`http://${$uri}:8888/products/add`, {
            method: 'POST',
            body: JSON.stringify([{
              product_code,
              product_category_id,
              product_name,
              supplier_id,
              buy_price,
              sell_price,
              min_stock,
              product_unit
            }])
        });

        if (!response.ok) {
            console.error('POST add new product gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid post add new product', data);
            return;
        }
        console.log("post new add product berhasil ",data);
        if (files && (files.length > 0 || files !== '')){
          await addProductPhoto(data.data[0].product_detail_id, files);
        }
      }
    
    async function addProductPhoto(product_id, files) {
      const formData = new FormData();
      formData.append('folder', 'product_details');
      formData.append('file', files[0]); 
      formData.append('id', product_id);
      formData.append('kolom_id', 'product_detail');
      formData.append('kolom_name', 'product_photo');

      const response = await fetch(`http://${$uri}:8888/file/upload`, {
          method: 'POST',
          body: formData
      });

      if (!response.ok) {
          console.error('POST add pp new product gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid POST pp new product', data);
          return;
      }
      console.log("Add pp new product berhasil");
      files = '';
    }
    async function AddNewCategory() {
      console.log(JSON.stringify([{
            product_category_name: new_category_name
          }]));
      const response = await fetch(`http://${$uri}:8888/products/category/add`, {
          method: 'POST',
          body: JSON.stringify([{
            product_category_name: new_category_name
          }])
      });

      if (!response.ok) {
          console.error('POST add new category gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid post add new category', data);
          return;
      }
    }

    async function editProduct(product_id,atribut) {
      const response = await fetch(`http://${$uri}:8888/products/edit/${product_id}`, {
          method: 'PUT',
          headers: {
                  'Content-Type': 'application/json',
              },
          body: JSON.stringify(atribut)
      });

      if (!response.ok) {
          console.error('PUT product details gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid put product details', data);
          return;
      }
      console.log("product details :",data);
      if (files && (files.length > 0 || files !== '')){
        await addProductPhoto(product_id, files);
      }
    }
    
    async function editSubtractReq(subtract_stock_id,atribut) {
      const response = await fetch(`http://${$uri}:8888/products/stock/subtract/update/stock/${subtract_stock_id}`, {
          method: 'PUT',
          headers: {
                  'Content-Type': 'application/json',
              },
          body: JSON.stringify(atribut)
      });

      if (!response.ok) {
          console.error('PUT subtract req details gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid put subtract req details', data);
          return;
      }
      console.log("product details :",data);
    }

    $: editMode = false;

  function getCategoryId(category_name){
    let categoryId = 0;
    let tmp_category = product_category.find((category) => category.product_category_name == category_name);
    console.log("tmp_category", tmp_category);
    categoryId = tmp_category.product_category_id;
    return categoryId;
  }
  
  function getSupplierId(supplier_name){
    let supplierId = 0;
    let tmp_supplier = suppliers.find((supplier) => supplier.supplier_name == supplier_name);
    console.log("tmp_supplier", tmp_supplier)
    supplierId = tmp_supplier.supplier_id;
    return supplierId;
  }

  async function getProductDetail(product_id) {
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
        // console.log(data.data[0].ProductDetails.product_name
        // if (get == "name"){
        //   return data.data[0].ProductDetails.product_name;
        // } else if (get == "unit"){
        //   return data.data[0].ProductDetails.product_unit;
        // } else {
        //   return data.data[0].ProductDetails.product_stock;
        // }
        return data.data[0].ProductDetails
  }
  async function fetchProductPhoto(product_id){
      const response = await fetch(`http://${$uri}:8888/file/${product_id}`, {
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
    product_photo_fetched = URL.createObjectURL(blob);
  }
  async function fetchAssign() {
        const response = await fetch(`http://${$uri}:8888/orders/transfer/notes/verify/0/${store_warehouse_id}/''/${limit}/${offset}`, {
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

        totalRows = data.total_rows;
        totalPages = Math.ceil(totalRows/limit);
        assign_product = data.data;
        console.log("assign_product",assign_product)
  }

  async function verifySubtractStock(subtract_stock_id,status) {
        const response = await fetch(`http://${$uri}:8888/products/stock/subtract/verify/${subtract_stock_id}/${status}`, {
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
            console.error('PUT verify subtract req gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid put verify subtract req', data);
            return;
        }
        // console.log("verify session :",data);
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

  function clearVariable(){
        start_date = '';
        end_date = '';
        category = '';
        unit_type = '';
        start_price = 0;
        end_price = 999999999;
    }


    //HANDLE SEARCH BAR
    //products
    $: if ((searchQuery_temp !== searchQuery_product) ){
        console.log(searchQuery_product);
        fetchProduk();
        searchQuery_temp = searchQuery_product;
      } else{
        searchQuery_temp = '';
        fetchProduk();
      }

    //stock history
    $: if ((searchQuery_temp !== searchQuery_stock) ){
        console.log(searchQuery_stock);
        fetchStockCardHistory();
        searchQuery_temp = searchQuery_stock;
      } else{
        searchQuery_temp = '';
      }
    
      //search category
    $: if (searchQuery_category.length > 0) {
      filtered_product_category = product_category.filter(item => 
        item.product_category_name.toLowerCase().includes(searchQuery_category.toLowerCase())
    );
    } else {
      filtered_product_category = [...product_category];
    }

    async function goToPage(page) {
        if (page < 1 || page > Math.ceil(totalRows / limit)) return;

        currentPage = page;
        offset = (currentPage - 1) * limit;

        if(tampilan == "products"){
          await fetchProduk();
        } else if (tampilan == "stock_history"){
          await fetchStockCardHistory()
        } else if (tampilan == "verify_add"){
          await fetchAddVerify();
        }else if (tampilan == "verify_subtract"){
          await fetchSubtractVerify();
        }else if (tampilan == "assign_product"){
          await fetchAssign();
        }else if (tampilan == "product_category"){
          await fetchProductCategory();
          totalRows = product_category.length;
        }
    }

    function handleFileSelect(event) {
      files = event.target.files;
      if (files && files.length > 0) {
        imageUrl = URL.createObjectURL(files[0]);
      }
    }
    onMount(async () => {
      fetchProduk();
      // fetchAddVerify();
      // fetchSubtractVerify();
      // fetchStockCardHistory();
      fetchProductCategory();
      fetchSuppliers();
      // fetchAssign();
      sw_name_print = await getStoreWarehouse(store_warehouse_id);
  });

  </script>
  
   <div class="mt-[90px] mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={() => goto('/manage_inventory')} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Inventory</span>
      
    <div class="w-11/12 my-10">
        <div class="grid grid-cols-4 gap-x-2 gap-y-4">
            {#if tampilan == "products"}
                <button on:click={async() => {tampilan = "products"; tampilan = tampilan;}} class="bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Products</button>
            {:else}
                <button on:click={async() => {tampilan = "products"; tampilan = tampilan; goToPage(1);}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Products</button>
            {/if}
            {#if tampilan == "stock_history"}
                <button on:click={async() => {tampilan = "stock_history"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Stock History</button>
            {:else}
                <button on:click={async() => {tampilan = "stock_history"; tampilan = tampilan; goToPage(1);}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Stock History</button>
            {/if}
            {#if tampilan == "verify_add"}
                <button on:click={async() => {tampilan = "verify_add"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Verify Add</button>
            {:else}
                <button on:click={async() => {tampilan = "verify_add"; tampilan = tampilan; goToPage(1);}} class=" bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Verify Add</button>
            {/if}
            {#if tampilan == "verify_subtract"}
                <button on:click={async() => {tampilan = "verify_subtract"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Verify Subtract</button>
            {:else}
                <button on:click={async() => {tampilan = "verify_subtract"; tampilan = tampilan; goToPage(1);}} class=" bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Verify Subtract</button>
            {/if}
            {#if tampilan == "assign_product"}
                <button on:click={async() => {tampilan = "assign_product"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Assign Product</button>
            {:else}
                <button on:click={async() => {tampilan = "assign_product"; tampilan = tampilan; goToPage(1);}} class=" bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Assign Product</button>
            {/if}
            {#if tampilan == "add_product"}
                <button on:click={async() => {tampilan = "add_product"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Add New Product</button>
            {:else}
                <button on:click={async() => {tampilan = "add_product"; tampilan = tampilan;}} class=" bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Add New Product</button>
            {/if}
            {#if tampilan == "product_category"}
                <button on:click={async() => {tampilan = "product_category"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Product Category</button>
            {:else}
                <button on:click={async() => {tampilan = "product_category"; tampilan = tampilan; goToPage(1)}} class=" bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Product Category</button>
            {/if}
        </div>    
    </div>

    {#if tampilan != "add_product"}
         <label for="voice-search" class="sr-only">Search</label>
          {#if tampilan == "products"}
          <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
            <input 
            type="text" 
            id="voice-search" 
            bind:value={searchQuery_product}
            class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
            placeholder="Search product by product id, name, or product code..."/>
            <button on:click={toggleFilter}
            type="button" 
            class="absolute inset-y-0 end-0 flex items-center pe-3 ">
            <i class="fa-solid fa-sliders fa-xl mr-2"></i>
          </button>
            {#if showFilter}
              <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-3/5 bg-gray-100 p-4 rounded-lg font-roboto">
                <span class="font-bold text-xl mb-4">Price Range</span>
                <div class="flex gap-x-4 w-full items-center mt-2">
                  <span class="font-semibold text-lg ">From</span>
                  <MoneyInput bind:value={start_price} shadow={false}/>
                  <span class="font-semibold text-lg ">To</span>
                  <MoneyInput bind:value={end_price} shadow={false}/>
                </div>

                <span class="font-bold text-xl mb-1">Unit Type</span>
                <div class="grid grid-cols-4 flex w-full flex-wrap">
                    <button on:click={() => {unit_type = (unit_type === '' || unit_type !== "unit") ? "unit" : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${unit_type === 'unit' ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Units</button>
                    <button on:click={() => {unit_type = (unit_type === '' || unit_type !== "gram") ? "gram" : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${unit_type === 'gram' ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Grams</button>
                </div>
                <span class="font-bold text-xl mb-1">Product Category</span>
                <div class="grid grid-cols-4 flex w-full flex-wrap">
                  {#each product_category as cat}
                    <button on:click={() => {category = (category === '' || category !== cat.product_category_id) ? cat.product_category_id : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:bg-white hover:border hover:border-peach2 hover:text-peach2 ${category === cat.product_category_id ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>{cat.product_category_name}</button>
                  {/each}
                </div>
                
                <div class="flex justify-between font-semibold mt-4">
                    <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => {clearVariable()}}>Clear</button>
                    <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={async() => {await fetchProduk(); toggleFilter(); clearVariable()}}>Apply</button>
                </div>
              </div>
            {/if}
          </div>
          {:else if tampilan == "stock_history"}
          <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
            <input 
            type="text" 
            id="voice-search" 
            bind:value={searchQuery_stock}
            class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
            placeholder="Search product by product id, name, product code, or batch..."/>
            <button on:click={toggleFilter}
            type="button" 
            class="absolute inset-y-0 end-0 flex items-center pe-3 ">
            <i class="fa-solid fa-sliders fa-xl mr-2"></i>
          </button>
            {#if showFilter}
              <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-3/5 bg-gray-100 p-4 rounded-lg font-roboto">
                <span class="font-bold text-xl mb-1">Time Period</span>
                <div class="flex gap-x-4 w-full items-center">
                  <span class="font-semibold text-lg mb-4">From</span>
                  <input type="date" bind:value={start_date} class="rounded-xl w-32 mb-4 p-2 border" />
                  <span class="font-semibold text-lg mb-4">To</span>
                  <input type="date" bind:value={end_date} class="rounded-xl w-32 mb-4 p-2 border" />
                </div>

                <span class="font-bold text-xl mb-1">Unit Type</span>
                <div class="grid grid-cols-4 flex w-full flex-wrap">
                    <button on:click={() => {unit_type = (unit_type === '' || unit_type !== "unit") ? "unit" : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${unit_type === 'unit' ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Units</button>
                    <button on:click={() => {unit_type = (unit_type === '' || unit_type !== "gram") ? "gram" : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${unit_type === 'gram' ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Grams</button>
                </div>
                <span class="font-bold text-xl mb-1">Product Category</span>
                <div class="grid grid-cols-4 flex w-full flex-wrap">
                  {#each product_category as cat}
                    <button on:click={() => {category = (category === '' || category !== cat.product_category_id) ? cat.product_category_id : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:bg-white hover:border hover:border-peach2 hover:text-peach2 ${category === cat.product_category_id ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>{cat.product_category_name}</button>
                  {/each}
                </div>
                
                <div class="flex justify-between font-semibold mt-4">
                    <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => {clearVariable()}}>Clear</button>
                    <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={async() => {await fetchStockCardHistory(); toggleFilter(); clearVariable();  currentPage = 1;}}>Apply</button>
                </div>
              </div>
            {/if}
          </div>
          <!-- {:else if tampilan == "verify_add_subtract"}
          <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
            <input 
              type="text" 
              id="voice-search" 
              bind:value={searchQuery_verify}
              class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
              placeholder="Search..."/>
            </div> -->
          {:else if tampilan == "product_category"}
          <div class="flex w-11/12">
            <div class="relative w-9/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg mr-4">
              <input 
                  type="text" 
                  id="voice-search" 
                  bind:value={searchQuery_category}
                  class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] h-full bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                  placeholder="Search category by name..."/>
            </div>
            <div class="relative w-3/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-xl">
                <button on:click={() => {showModal = "add_category_modal"; showModal = showModal;}} class="w-full py-4 rounded-xl bg-peach font-semibold text-lg text-darkGray border-2 border-darkGray"><i class="fa-solid fa-plus mr-2"></i>Add New Category</button>
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
    {/if}
      
      {#if tampilan == "products"}
        <div class="w-[96%] my-5 font-roboto">
            <div class="relative overflow-x-auto sm:rounded-lg">
            {#if all_produk.length > 0 }
              {#each all_produk as product}
                  <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3">                        
                      <div class="m-4 w-1/12 flex">
                      <img class="rounded-lg " src={img_produk} alt="">
                      </div>
                          <div class="py-4 w-8/12">
                              <div class="font-bold text-[#f2b082] whitespace-nowrap text-lg">
                              #{product.ProductDetails.product_detail_id}
                              </div>
                              <div class="font-semibold text-xl">
                              {product.ProductDetails.product_name}
                              </div>
                          </div>
                      <div class="px-6 py-4 font-semibold w-3/12 flex flex-col items-center self-center">
                          <div class="flex justify-center text-xl">
                              Stock: {product.ProductDetails.product_stock} {product.ProductDetails.product_unit}
                          </div>
                          <div  class="flex items-center justify-center py-2 w-full">
                              <button 
                              on:click={async () => {handleClick(product.ProductDetails.product_detail_id);
                                stock_card_product = []; 
                                fetchStockCard(product.ProductDetails.product_detail_id); 
                                tampilan_modal = "products_modal"; 
                                product_photo_fetched = ''; 
                                if (product.ProductDetails.product_photo !== '-') {
                                  await fetchProductPhoto(product.ProductDetails.product_photo);
                                }
                              }}
                              type="button" 
                              class="h-10 px-4 w-40 inline-flex items-center justify-start font-bold rounded-3xl bg-[#3d4c52] text-[#f2b082] hover:shadow-2xl">
                              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-6">
                                  <path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" />
                                  <path fill-rule="evenodd" d="M1.323 11.447C2.811 6.976 7.028 3.75 12.001 3.75c4.97 0 9.185 3.223 10.675 7.69.12.362.12.752 0 1.113-1.487 4.471-5.705 7.697-10.677 7.697-4.97 0-9.186-3.223-10.675-7.69a1.762 1.762 0 0 1 0-1.113ZM17.25 12a5.25 5.25 0 1 1-10.5 0 5.25 5.25 0 0 1 10.5 0Z" clip-rule="evenodd" />
                              </svg>
                              <div class="text-lg text-white font-semibold w-full">View</div>
                              </button>
                          </div>
                      </div>
                  </div>
              {/each}
            {:else}
              <div class="flex justify-center w-full">
                <span>No Product Found</span>
              </div>
            {/if}
            </div>
        </div>
      {:else if tampilan == "stock_history"}
        <div class="w-11/12">
          <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
            {#if filtered_stock_card_history.length > 0}
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
                {#each filtered_stock_card_history as stock, i}
                  <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                    <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                          {i+1}
                    </th>
                    <td class="px-1 py-2 text-center">
                      {stock.product_name}
                    </td>
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
            {:else}
              <div class="flex justify-center items-center w-full">
                <span class="h-48">No Result Found</span>
              </div>
            {/if}
          </div>
        </div>
      {:else if tampilan == "verify_add"}
        <div class="w-[96%] my-5 font-roboto">
            <div class="relative overflow-x-auto sm:rounded-lg">
            {#each verify_add as add_req}
                <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3 py-2 px-4">    
                  <div class="w-10/12 flex flex-col font-semibold text-lg">
                    <span class="my-1">Add Product Stock Request</span>
                    {#await getStoreWarehouse(add_req.store_warehouse_id)}
                      <span class="my-1">Loading...</span>
                    {:then sw_name}
                      <span class="my-1">From warehouse {sw_name}</span>
                    {/await}
                    <div class="flex items-center my-1">
                      {#await getAddStockDetails(add_req.add_stock_id)}
                        <span class="my-1">Loading...</span>
                      {:then total_items}
                        <span class="mx-1">{total_items} Items, </span>
                      {/await}
                      {#if add_req.status_verify == 0}
                        <span class="">UNVERIFIED.</span>
                      {:else}
                        <span class="">VERIFIED.</span>
                      {/if}
                    </div>
                  </div>
                  
                  <div class="w-2/12 flex justify-end items-center">
                    <button on:click={() => goto(`/manage_inventory/${store_warehouse_id}/add_stock/${add_req.add_stock_id}`)} class="p-4 bg-darkGray rounded-xl"><svg width="60" height="60" viewBox="0 0 60 60" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M2.5 30C2.5 30 12.5 10 30 10C47.5 10 57.5 30 57.5 30C57.5 30 47.5 50 30 50C12.5 50 2.5 30 2.5 30Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M30 37.5C34.1421 37.5 37.5 34.1421 37.5 30C37.5 25.8579 34.1421 22.5 30 22.5C25.8579 22.5 22.5 25.8579 22.5 30C22.5 34.1421 25.8579 37.5 30 37.5Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      </button>
                  </div>
                </div>
            {/each}
            </div>
        </div>
      {:else if tampilan == "verify_subtract"}
        <div class="w-[96%] my-5 font-roboto">
            <div class="relative overflow-x-auto sm:rounded-lg">
            {#each verify_subtract as sub_req}
                <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3 py-2 px-4">    
                  <div class="w-10/12 flex flex-col font-semibold text-lg">
                    <span class="my-1 text-sm text-peach2">Subtract Product Stock Request</span>
                    <div class="flex items-center font-bold">
                        <span class="my-1">{sub_req.product_name}</span>
                    </div>
                    
                    <div class="flex items-center">
                      <div class="flex items-center w-3/12">
                          <span class="my-1">Subtract : </span>
                          <span class="my-1 ml-1">{sub_req.subtract_quantity}</span>
                      </div>
                      <div class="flex items-center w-3/12">
                          <span class="my-1">Stock : </span>
                          <span class="my-1">{sub_req.product_stock}</span>
                      </div>
                      <div class="flex items-center w-3/12">
                          <span class="my-1">Batch : </span>
                          <span class="my-1">{sub_req.batch}</span>
                      </div>
                      <div class="flex items-center w-3/12">
                          <span class="my-1">Product Unit : </span>
                          <span class="my-1">{sub_req.product_unit}</span>
                      </div>
                    </div>
                      <span class="my-1">From warehouse {sub_req.sw_name}</span>
                  </div>
                  
                  <div class="w-2/12 flex justify-end items-center">
                    <button on:click={() => {tampilan_modal = "subtract_modal"; showModal = sub_req.subtract_stock_id}} class="p-4 bg-darkGray rounded-xl"><svg width="60" height="60" viewBox="0 0 60 60" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M2.5 30C2.5 30 12.5 10 30 10C47.5 10 57.5 30 57.5 30C57.5 30 47.5 50 30 50C12.5 50 2.5 30 2.5 30Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M30 37.5C34.1421 37.5 37.5 34.1421 37.5 30C37.5 25.8579 34.1421 22.5 30 22.5C25.8579 22.5 22.5 25.8579 22.5 30C22.5 34.1421 25.8579 37.5 30 37.5Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      </button>
                  </div>
                </div>
            {/each}
            </div>
        </div>
      {:else if tampilan == "assign_product"}
        <div class="w-[96%] my-5 font-roboto">
          <div class="relative overflow-x-auto sm:rounded-lg">
          {#each assign_product as ass_produk}
              <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3 py-2 px-4">    
                <div class="w-10/12 flex flex-col font-semibold text-lg">
                  {#await getStoreWarehouse(ass_produk.store_warehouse_from)}
                    <span class="my-1">Loading...</span>
                  {:then warehouse_name}
                    <span class="my-1">From warehouse {warehouse_name}</span>
                  {/await}
                  {#await getStoreWarehouse(ass_produk.store_warehouse_to)}
                    <span class="my-1">Loading...</span>
                  {:then store_name}
                    <span class="my-1">To Store {store_name}</span>
                  {/await}
                  <div class="flex items-center my-1">
                      <span class="mx-1">{ass_produk.quantity_total} Items, </span>
                    {#if ass_produk.status_verify == 0}
                      <span class="">UNVERIFIED.</span>
                    {:else}
                      <span class="">VERIFIED.</span>
                    {/if}
                  </div>
                </div>
                
                <div class="w-2/12 flex justify-end items-center">
                  <button on:click={() => goto(`/manage_inventory/${store_warehouse_id}/transfer_note/${ass_produk.transfer_note_id}`)} class="p-4 bg-darkGray rounded-xl"><svg width="60" height="60" viewBox="0 0 60 60" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M2.5 30C2.5 30 12.5 10 30 10C47.5 10 57.5 30 57.5 30C57.5 30 47.5 50 30 50C12.5 50 2.5 30 2.5 30Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M30 37.5C34.1421 37.5 37.5 34.1421 37.5 30C37.5 25.8579 34.1421 22.5 30 22.5C25.8579 22.5 22.5 25.8579 22.5 30C22.5 34.1421 25.8579 37.5 30 37.5Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                    </button>
                </div>
              </div>
          {/each}
          </div>
        </div>
      {:else if tampilan == "add_product"}
        <div class="w-11/12">
          <div class="flex flex-col mx-4">
              <span class="text-xl text-darkGray font-semibold">Product Photo</span>
              <input class="block w-full text-sm text-gray-900 border border-black rounded-3xl cursor-pointer bg-gray-50 focus:outline-none" aria-describedby="file_input_help" accept="image/png, image/jpeg" bind:files id="avatar" name="avatar" type="file" />
              {#if files}
                {#if imageUrl}
                    <img src={imageUrl} alt="Selected image" class="max-w-40 max-h-40 mt-4" />
                {/if}
              {/if}
              <span class=" mt-6 text-xl text-darkGray font-semibold">Product Code</span>
              <input bind:value={product_code} type="text" class="my-1 mb-6 rounded-3xl focus:border-peach focus:ring-peach2" placeholder="Input Product Code">
              
              <span class="text-xl text-darkGray font-semibold">Product Name</span>
              <input bind:value={product_name} type="text" class="my-1 mb-6 rounded-3xl focus:border-peach focus:ring-peach2" placeholder="Input Product Name">

              <div class="grid grid-cols-3 gap-6">
                <div>
                  <span class="text-xl text-darkGray font-semibold">Product Type</span>
                  <select bind:value={product_category_id}  class="w-full rounded-3xl p-2 my-1 focus:border-peach focus:ring-peach2">
                    {#each product_category as category}
                      <option value={category.product_category_id}>{category.product_category_name}</option>
                    {/each}
                  </select>
                </div>
                <div>
                  <span class="text-xl text-darkGray font-semibold">Product Brand</span>
                  <div class="">
                    <select bind:value={supplier_id} class="w-full rounded-3xl p-2 my-1 focus:border-peach focus:ring-peach2">
                      {#each suppliers as supplier}
                        <option value={supplier.supplier_id}>{supplier.supplier_name}</option>
                      {/each}
                    </select>
                  </div>
                </div>
                <div>
                  <span class="text-xl text-darkGray font-semibold">Product Unit Type</span>
                  <select bind:value={product_unit} class="w-full rounded-3xl p-2 my-1 focus:border-peach focus:ring-peach2">
                    <option value="unit">Unit</option>
                    <option value="gram">Gram</option>
                  </select>
                </div>
                <div>
                  <span class="text-xl text-darkGray font-semibold">Buy Price</span>
                  <input bind:value={buy_price} type="number" class="[appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none w-full my-1 mb-6 rounded-3xl focus:border-peach focus:ring-peach2" placeholder="Input Buy Price">
                </div>
                <div>
                  <span class="text-xl text-darkGray font-semibold">Sell Price</span>
                  <input bind:value={sell_price} type="number" class="[appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none w-full my-1 mb-6 rounded-3xl focus:border-peach focus:ring-peach2" placeholder="Input Sell Price">
                </div>
                <div>
                  <span class="text-xl text-darkGray font-semibold">Min Stock</span>
                  <input bind:value={min_stock} type="number" class="[appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none w-full my-1 mb-6 rounded-3xl focus:border-peach focus:ring-peach2" placeholder="Input Min Stock">
                </div>
              </div>
          </div>
          <div class="flex justify-center mt-8">
            <!-- <button class="w-48 py-2 bg-darkGray text-peach rounded-2xl text-lg font-semibold mx-4">Back</button> -->
            <button on:click={() => showModal = "confirm_add"} class="w-48 py-2 bg-peach text-darkGray rounded-2xl text-lg font-semibold mx-4">Add</button>
          </div>
        </div>
      {:else if tampilan == "product_category"}
        <div class="w-[96%] my-5 font-roboto">
          <div class="relative overflow-x-auto sm:rounded-lg">
          {#if filtered_product_category.length > 0 }
            {#each filtered_product_category as category}
                <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3">                        
                    <div class="m-4 w-1/12 flex">
                    <img class="rounded-lg " src={img_produk} alt="">
                    </div>
                    <div class="py-4 w-10/12 flex items-center">
                      <span class="font-semibold text-2xl">{category.product_category_name}</span>
                    </div>
                </div>
            {/each}
          {:else}
            <div class="flex justify-center w-full">
              <span>No Product Found</span>
            </div>
          {/if}
          </div>
        </div>
      {/if}
        
      {#if tampilan != "add_product"}
       
     
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
  {/if}
       
   </div>

<!-- MODAL PRODUCTS -->
{#each all_produk as product}
{#if tampilan_modal == "products_modal"}
  {#if showModal === product.ProductDetails.product_detail_id}
    <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
      <div class="flex items-center justify-center pt-8">
        <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Product detail</div>
      </div>
      {#if editMode == true}
        <button on:click={() => editMode = false} class="mt-6 mx-4 p-2 bg-darkGray text-peach shadow w-32 rounded-2xl font-semibold border border-peach">Exit Edit Mode</button>
      {:else}
        <button on:click={() => editMode = true} class="mt-6 mx-4 p-2 bg-peach2 text-darkGray shadow w-32 rounded-2xl font-semibold">Edit <i class="fa-regular fa-pen-to-square" style="color: #364445;"></i></button>
      {/if}
      <form class=" mt-4 p-4 md:p-5">
          <div class="grid gap-3 font-roboto font-semibold">
            <div class="">
              <div class="text-[#f7d4b2] mr-1">Product Photo</div>
              {#if editMode == false}
                {#if product_photo_fetched !== ''}
                  <img src={product_photo_fetched} class="w-40 rounded-xl border border-darkGray" alt="Profile Picture">
                {:else}
                  <img src={img_produk} class="w-40 rounded-xl border border-darkGray" alt="Default Picture">
                {/if}
              {:else}
                <input 
                  class="block w-full text-sm text-gray-900 border  rounded-lg cursor-pointer bg-gray-50 focus:outline-none" 
                  aria-describedby="file_input_help" 
                  accept="image/png, image/jpeg" 
                  bind:files 
                  id="avatar" 
                  name="avatar" 
                  type="file" 
                  on:change={handleFileSelect} 
                />
                
                {#if files}
                  {#if imageUrl}
                    <img src={imageUrl} alt="Selected image" class="mt-4  w-40 rounded-xl border border-darkGray" />
                  {/if}
                {:else}
                  {#if product_photo_fetched !== ''}
                    <img src={product_photo_fetched} class="mt-4 w-40 rounded-xl border border-darkGray" alt="Profile Picture">
                  {:else}
                    <img src={img_produk} class="mt-4 w-40 rounded-xl border border-darkGray" alt="Default Picture">
                  {/if}
                {/if}
              {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product ID</div>
                <div class="text-white">{product.ProductDetails.product_detail_id}</div>
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product Name</div>
                <div class="text-white">{product.ProductDetails.product_name}</div>
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product Brand</div>
                {#if editMode == true}
                  <select bind:value={product.ProductDetails.supplier_name} on:change={console.log(product.ProductDetails.supplier_name)} name="product_type" id="product_type" class="w-44 rounded p-1 border-0 text-darkGray">
                    {#each suppliers as supplier}
                      <option value={supplier.supplier_name}>{supplier.supplier_name}</option>
                    {/each}
                    </select>
                {:else}
                  <div class="text-white">{product.Suppliers.supplier_name}</div>
                {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product Type</div>
                {#if editMode == true}
                  <select bind:value={product.ProductCategories.product_category_name} on:change={console.log(product.ProductCategories.product_category_name)} name="product_type" id="product_type" class="w-44 rounded p-1 border-0 text-darkGray">
                    {#each product_category as category}
                      <option value={category.product_category_name}>{category.product_category_name}</option>
                    {/each}
                    </select>
                {:else}
                  <div class="text-white">{product.ProductCategories.product_category_name}</div>
                {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Date Added</div>
                {#if editMode == true}
                  <div class="my-1 text-peach2">The current date added : </div>
                  <div class="text-white">
                    <DateConverter value={product.ProductDetails.product_timestamp} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                  </div>
                  <div class="my-1 text-peach2">New date added : </div>
                  <!-- <input type="date" bind:value={new Date(product.ProductDetails.product_timestamp).toJSON().slice(0, 10)} class="w-44 mb-4 p-2 border-0 rounded" /> -->
                  <input type="date" bind:value={product.ProductDetails.product_timestamp} on:change={console.log(product.ProductDetails.product_timestamp)} class="w-44 mb-4 p-2 border-0 rounded" />
                {:else}
                  <div class="text-white">
                      {#if product.ProductDetails.product_timestamp.length > 1}
                      <DateConverter value={product.ProductDetails.product_timestamp} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                      {:else}
                      -
                      {/if}
                  </div>                
                {/if}
                
            </div>
            <!-- <div class="">
                <div class="text-[#f7d4b2] mr-1">Expiration Date</div>
                  <div class="text-white">
                      {#if product.ProductDetails.expiry_date.length > 1}
                      <DateConverter value={product.ProductDetails.expiry_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                      {:else}
                      -
                      {/if}
                  </div>              
            </div> -->
            <div class="">
              <div class="text-[#f7d4b2]">Current Stock
                <button on:click={() => toggleTable1(product.ProductDetails.product_detail_id)} class="ml-2">
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
            
            <div class="">
              <div class="text-[#f7d4b2]">Last Inventory Taking</div>
              <div class="text-white">{product.ProductDetails.product_name}</div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">
                Stock Card
                <button on:click={() => toggleTable(product.ProductDetails.product_detail_id)} class="ml-2">
                  {#if showTable}
                     <i class="fa-solid fa-caret-up"></i>
                  {:else}
                     <i class="fa-solid fa-caret-down"></i>
                  {/if}
               </button>
              </div>
              {#if showTable && stock_card_product.length > 0}
              <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
                <table class="w-full text-sm text-left rtl:text-right">
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
                    {#each stock_card_product as stock, i}
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
              {/if}
            </div>
            <div class="">
              <button 
                on:click={() => exportPDF(window.location.origin+`/print_stock_card/${$uri}/${product.ProductDetails.product_detail_id}/${store_warehouse_id}`, `StockCard_${product.ProductDetails.product_detail_id}_${sw_name_print}_PrintedOn${getFormattedDateForPrint()}`, 190)}
                type="button" class="mt-6 mb-3 flex items-center justify-center text-[#3d4c52] bg-[#F2AA7E] shadow-[0_2px_3px_rgba(0,0,0,0.3)] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg  px-12 py-1.5 text-center">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096m-.72-.096L17.66 18m0 0 .229 2.523a1.125 1.125 0 0 1-1.12 1.227H7.231c-.662 0-1.18-.568-1.12-1.227L6.34 18m11.318 0h1.091A2.25 2.25 0 0 0 21 15.75V9.456c0-1.081-.768-2.015-1.837-2.175a48.055 48.055 0 0 0-1.913-.247M6.34 18H5.25A2.25 2.25 0 0 1 3 15.75V9.456c0-1.081.768-2.015 1.837-2.175a48.041 48.041 0 0 1 1.913-.247m10.5 0a48.536 48.536 0 0 0-10.5 0m10.5 0V3.375c0-.621-.504-1.125-1.125-1.125h-8.25c-.621 0-1.125.504-1.125 1.125v3.659M18 10.5h.008v.008H18V10.5Zm-3 0h.008v.008H15V10.5Z" />
                </svg>
                Print Stock Card
              </button>
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Buy Price</div>
                {#if editMode == true}
                <div class="w-44">
                  <MoneyInput bind:value={product.ProductDetails.buy_price} />
                </div>
                {:else}
                  <div class="text-white">
                      <MoneyConverter value={product.ProductDetails.buy_price} currency={true} decimal={true}></MoneyConverter>
                  </div>                
                {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Sell Price</div>
                {#if editMode == true}
                <div class="w-44">
                  <MoneyInput bind:value={product.ProductDetails.sell_price} />
                </div>
                {:else}
                  <div class="text-white">
                      <MoneyConverter value={product.ProductDetails.sell_price} currency={true} decimal={true}></MoneyConverter>
                  </div>             
                {/if}
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Minimum Stock</div> 
                {#if editMode == true}
                  <input type="number" bind:value={product.ProductDetails.min_stock} class="bg-white text-darkGray border-0 p-1 rounded [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none">
                {:else}
                  <div class="text-white">{product.ProductDetails.min_stock}</div>
                {/if}
            </div>
            
            <div class="flex items-center justify-center">
              {#if editMode == false}
                <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                  Close
                </button>
              {:else}
                <button type="button" on:click={async() => 
                { let product_code = product.ProductDetails.product_code;
                  let product_category_id = getCategoryId(product.ProductCategories.product_category_name);
                  let product_name = product.ProductDetails.product_name;
                  let supplier_id =  getSupplierId(product.ProductDetails.supplier_name);
                  let buy_price = product.ProductDetails.buy_price;
                  let sell_price = product.ProductDetails.sell_price;
                  let min_stock = product.ProductDetails.min_stock;
                  let product_unit = product.ProductDetails.product_unit;
                  let product_timestamp = product.ProductDetails.product_timestamp + " 00:00:00";
                  let atribut = {
                    product_code,
                    product_category_id,
                    product_name,
                    supplier_id,
                    buy_price,
                    sell_price,
                    min_stock,
                    product_unit,
                    product_timestamp
                  };await editProduct(product.ProductDetails.product_detail_id,atribut); console.log(JSON.stringify(atribut));
                  Swal.fire({
                      title: "Produk Berhasil terupdate",
                      icon: "success",
                      color: "white",
                      background: "#364445",
                      confirmButtonColor: '#F2AA7E'
                    }); closeModal(); editMode = false; editMode = editMode; fetchProduk()}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                  Save
                </button>
              {/if}
            </div>
          </div>
      </form>
  </TaskModal> 
  {/if}
{/if}
{/each}

<!-- MODAL ADD NEW PRODUCT -->
{#if showModal == "confirm_add" }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Save</div>
    </div>
    <form class="my-4 p-4 md:p-5 font-roboto text-xl">
          <div class="text-[#f7d4b2] font-medium text-center mb-8">
            Are you sure you want to submit the changes you've made?
          </div>
          <div class="flex items-center justify-center gap-4">
              <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                Back
              </button>
              <button type="button" on:click={async() => {AddNewProduct();   
              console.log("product_name",product_name)
              let description = "User ID "+$userId+" menambahkan produk baru dengan nama " + product_name ;
              //19 Add New Product
              await insertNotif(description,19)

              Swal.fire({
                title: "Produk Berhasil Ditambahkan",
                icon: "success",
                color: "white",
                background: "#364445",
                confirmButtonColor: '#F2AA7E'
              }); closeModal();
              product_code = "";
              product_category_id = 0;
              product_name = "";
              supplier_id = 0;
              buy_price = 0;
              sell_price = 0;
              min_stock = 0;
              product_unit = ""}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                Add
              </button>
          </div>
    </form>
  </TaskModal> 
  {/if}

{#each verify_subtract as sub_req}
{#if tampilan_modal == "subtract_modal"}
  {#if showModal == sub_req.subtract_stock_id}
    <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
      <div class="flex items-center justify-center pt-8">
        <div class="mt-6 text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Subtract Produk Stock Request</div>
      </div>
      {#if editMode == true}
        <button on:click={() => editMode = false} class="mt-6 mx-4 p-2 bg-darkGray text-peach shadow w-32 rounded-2xl font-semibold border border-peach">Exit Edit Mode</button>
      {:else}
        <button on:click={() => editMode = true} class="mt-6 mx-4 p-2 bg-peach2 text-darkGray shadow w-32 rounded-2xl font-semibold">Edit <i class="fa-regular fa-pen-to-square" style="color: #364445;"></i></button>
      {/if}
      <form class=" mt-4 p-4 md:p-5">
          <div class="grid gap-3 font-roboto font-semibold">
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product Name</div>
                <div class="text-white">{sub_req.product_name}</div>
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product Batch</div>
                <div class="text-white">{sub_req.batch}</div>
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Product Stock</div>
                <div class="text-white">{sub_req.product_stock}</div>
            </div>
            <div class="">
                <div class="text-[#f7d4b2] mr-1">Subtract Amount</div>
                {#if editMode == true}
                  <input type="number" bind:value={sub_req.subtract_quantity} class="bg-white text-darkGray border-0 p-1 rounded [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none">
                {:else}
                  <div class="text-white">{sub_req.subtract_quantity}</div>
                {/if}
            </div>
            <div class="">
              <div class="text-[#f7d4b2] mr-1">Unit Type</div>
              <div class="text-white">{sub_req.product_unit}</div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2] mr-1">Notes</div>
              {#if editMode == true}
                <textarea bind:value={sub_req.notes} rows="4" class="min-h-24 shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 "></textarea>  
              {:else}
              <textarea value={sub_req.notes} readonly rows="4" class="min-h-24 shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 "></textarea>  
              {/if}
            </div>
            
            <div class="flex items-center justify-center">
              {#if editMode == false}
                <button on:click={async() => {await verifySubtractStock(sub_req.subtract_stock_id,2); await fetchSubtractVerify();

                  let description = "User ID "+$userId+" menolak subtract produk dengan ID "+ sub_req.subtract_stock_id;
                  //15 Verify Subtracts Product
                  await insertNotif(description,15)

                  Swal.fire({
                      title: "Subtract Produck Request Berhasil direject",
                      icon: "success",
                      color: "white",
                      background: "#364445",
                      confirmButtonColor: '#F2AA7E'
                    }); closeModal();}}  type="button" class="justify-center mx-4 mt-2 flex w-40 text-peach bg-darkGray hover:bg-[#293334] focus:outline-none font-semibold rounded-lg text-2xl py-1.5 text-center">
                  Reject
                </button>
                <button on:click={async() => {await verifySubtractStock(sub_req.subtract_stock_id,1); await fetchSubtractVerify();
                  
                  let description = "User ID "+$userId+" menerima subtract produk dengan ID "+ sub_req.subtract_stock_id;
                  //15 Verify Subtracts Product
                  await insertNotif(description,15)
                  
                  Swal.fire({
                      title: "Subtract Produck Request Berhasil diverify",
                      icon: "success",
                      color: "white",
                      background: "#364445",
                      confirmButtonColor: '#F2AA7E'
                    }); closeModal(); 
                }} type="button" on:click={() => closeModal()} class="justify-center mx-4 mt-2 flex w-40 text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082] focus:outline-none font-semibold rounded-lg text-2xl py-1.5 text-center">
                  Verify
                </button>
              {:else}
                <button type="button" on:click={async() => 
                { let subtract_quantity = sub_req.subtract_quantity;
                  let notes = sub_req.notes;

                  let atribut = {
                    subtract_quantity,
                    notes
                  };await editSubtractReq(sub_req.subtract_stock_id,atribut); console.log(JSON.stringify(atribut)); await fetchSubtractVerify();
                  Swal.fire({
                      title: "Subtract Produck Request Berhasil terupdate",
                      icon: "success",
                      color: "white",
                      background: "#364445",
                      confirmButtonColor: '#F2AA7E'
                    }); closeModal(); editMode = false; editMode = editMode}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                  Save 
                </button>
              {/if}
            </div>
          </div>
      </form>
  </TaskModal> 
  {/if}
{/if}
{/each}

<!-- MODAL ADD CATEGORY -->
{#if showModal == "add_category_modal"}
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Add Product Category</div>
    </div>
    <div class="w-full flex justify-center my-8">
      <div class="flex flex-col my-2 w-10/12">
        <span class="text-peach font-semibold mb-1">Product Category Name</span>
        <input type="text" bind:value={new_category_name} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
      </div>
    </div>

    <div class="flex items-center justify-center my-4">
      <button on:click={() => {closeModal()}} class="w-1/4 py-2.5 mx-4 bg-darkGray border border-peach text-peach font-semibold rounded-xl">Back</button>
      <button on:click={async() => {await AddNewCategory(); closeModal();
        Swal.fire({
          title: "Berhasil Menambahkan Kategori Baru",
          icon: "success",
          color: "white",
          background: "#364445",
          confirmButtonColor: '#F2AA7E'
        }); await fetchProductCategory()}} 
      class="w-1/4 py-2.5 mx-4 bg-peach border border-peach text-darkGray font-semibold rounded-xl">Save</button>
    </div>
</TaskModal> 
{/if}

