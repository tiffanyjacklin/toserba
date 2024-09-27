<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { getFormattedDate, isInTimeRange } from '$lib/DateNow.js';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId, user } from '$lib/uri.js';
    import { read } from '$app/server';
    import { getFormattedDateNow, getThirtyDaysBefore } from '$lib/DateNow';
    import LineChart from '$lib/LineChart.svelte';
    $: limit = 10; 
    $: offset = 0; 
    $: totalNotes = 10; 
    $: currentPage = 1; 
      
    $: endDate = '';
    $: startDate = '';
    $: status = '';
    $: category = '';
    $: searchQuery = '';
    $: searchQuery_temp = '';
    
    $: tampilan = "all_promos"
    $: tab_menu = "detail"

    let produk_promos = [];
    let filtered_produk_promos = [];
    let all_produk = [];
    let filtered_all_produk = [];
    let storeWarehouse = [];
    let categories = [];

    let choosen_product_id = null;
    let choosen_product_name = "";

    $: showModal = null;
    $: showDropDownID = false;
    $: showDropDownName = false;
    $: showPromoInput = 0;
    $: swListAll = false;
    let searchQuery = "";

    // ADD PROMO BARU
    let promo_code = "";
    let promo_type_id = 0;
    let promo_start_date = "";
    let promo_end_date = "";
    let promo_percentage = 0;
    let promo_discount = 0;
    let promo_term_and_cond = "";
    let x_amount = 0;
    let y_amount = 0;

    //ADD PROMO TO STORE
    let sw_id_list = [];


    //PROMO COST
    
    $: startTransaction = '';
    $: endTransaction = '';
    $: dateChosen = '1M';
    $: transactions = [];
    $: list_of_dates = [];
    $: list_of_discount = [];
    $: end_date = getFormattedDateNow();
    $: start_date = getThirtyDaysBefore(end_date, 30);
    $: weekly_cost = 0;
    $: monthly_cost = 0;
    $: all_profit = [];
    $: all_discount = [];
    $: disc_sum = 0;
    let showFilter = false;

    function toggleFilter() {
      showFilter = !showFilter;
    }
    function closeModal() {
        showModal = null;
   }
   function toggleSwListAll() {
        swListAll = !swListAll;
    }
    async function fetchPromoCategory() {
      const response = await fetch(`http://${$uri}:8888/promos/type/all/0/0`, {
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

      categories = [...data.data];  
      console.log(categories);
    }

   async function fetchPromos(){
        const response = await fetch(`http://${$uri}:8888/promos/${startDate}/${endDate}/${searchQuery}/${category}/${status}/${limit}/${offset}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch all promo failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch all promo', data);
            return;
        }

        totalNotes = data.total_rows;
        produk_promos = data.data;
        console.log("produk_promos",produk_promos);
        
        for (let i = 0; i < produk_promos.length; i++) {
          produk_promos[i].total_store = await fetchPromoProductStoreTotal(produk_promos[i].ProductDetail.product_detail_id)
          produk_promos[i].username = await getUsername(produk_promos[i].Promo.user_id)
        }

        filtered_produk_promos = structuredClone(produk_promos);
    }
   
    async function fetchPromoProductStoreTotal(product_detail_id){
        const response = await fetch(`http://${$uri}:8888/promos/product/${product_detail_id}/100/0`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch all promo product store failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch all promo product store', data);
            return;
        }

        return data.data.length
        console.log(data.data.length);
        
    }
   
    async function fetchProduk(){
        const response = await fetch(`http://${$uri}:8888/products/detail`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch all promo failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch all promo', data);
            return;
        }

        all_produk = data.data;
        filtered_all_produk = [...all_produk]
        console.log(all_produk);
        
    }
    
    async function fetchSW(){
        const response = await fetch(`http://${$uri}:8888/store_warehouses/all`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch all promo failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch all promo', data);
            return;
        }

        storeWarehouse = data.data;
    }
    
    async function getLastPromoId(){
        const response = await fetch(`http://${$uri}:8888/promos/last`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch all promo failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch all promo', data);
            return;
        }

        return data.data.promo_id;
        console.log(data.data.promo_id);
    }
   
    async function getUsername(user_id){
        const response = await fetch(`http://${$uri}:8888/user/${user_id}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch user failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch user', data);
            return;
        }

        return data.data.user_fullname;
    }

    function matchIDandName(atribut,jenis){
      if (jenis == "id"){
        for (let i = 0; i < all_produk.length; i++) {
          if (all_produk[i].ProductDetails.product_detail_id == atribut){
            choosen_product_name = all_produk[i].ProductDetails.product_name;
          }
        }
      } else if (jenis == "name"){
        for (let i = 0; i < all_produk.length; i++) {
          if (all_produk[i].ProductDetails.product_name == atribut){
            choosen_product_id = all_produk[i].ProductDetails.product_detail_id;
          }
        }
      }
      
    }
    
    async function checkChooseProduct(){
      let isOK = false;
      if (choosen_product_id != null && choosen_product_name != "" ) {
        // console.log("produk",all_produk)
        // let produk_id = all_produk.find((produk) => produk.ProductDetails.product_detail_id == choosen_product_id);
        // if (produk_id !=  null){
        //   if (produk_id.ProductDetails.product_name == choosen_product_name){
        //     let produk_name = all_produk.find((produk) => produk.ProductDetails.product_name == choosen_product_name);
        //     if (produk_name !=  null){
        //       if (produk_name.ProductDetails.product_detail_id == choosen_product_id){
        //         isOK = true;
        //       }
        //     }
        //   }
        // }
        console.log("produk",filtered_all_produk)
        let produk_id = filtered_all_produk.find((produk) => produk.ProductDetails.product_detail_id == choosen_product_id);
        if (produk_id !=  null){
          if (produk_id.ProductDetails.product_name == choosen_product_name){
            let produk_name = filtered_all_produk.find((produk) => produk.ProductDetails.product_name == choosen_product_name);
            if (produk_name !=  null){
              if (produk_name.ProductDetails.product_detail_id == choosen_product_id){
                isOK = true;
              }
            }
          }
        }
      } else{
        console.log("all_produk lho ga kosong", all_produk)
      }

      if (isOK == true){
        await fetchSW();
        showModal = "add_promo"
        showModal = showModal;
      } else {
        Swal.fire({
          title: "Pastikan nama dan id produk tidak kosong dan merupakan produk yang sama",
          icon: "error",
          color: "white",
          background: "#364445",
          confirmButtonColor: '#F2AA7E'
        });
      }
    }
  
    function addStoreToList(sw){
      if (sw == "all"){
        if (sw_id_list.length > 0){
          sw_id_list = [];
          console.log("sw_id",sw_id_list);
        } else {
            sw_id_list = [];
            for (let i = 0; i < storeWarehouse.length; i++) {
              if (storeWarehouse[i].StoreWarehouses.store_warehouse_type == "STORE"){
                sw_id_list.push(storeWarehouse[i].StoreWarehouses.store_warehouse_id);
                console.log("sw_id",sw_id_list);
              }
            }
        }
      } else {
          let store = sw_id_list.find((id) => id == sw)
          if (store != null){
            let index = sw_id_list.findIndex((id) => id == sw)
            sw_id_list.splice(index,1);
            console.log("sw_id",sw_id_list);
          } else {
            sw_id_list.push(sw);
            console.log("sw_id",sw_id_list);
          }
      }
    }

    async function applyPromotoProduct(promo_id) {
        const response = await fetch(`http://${$uri}:8888/promos/product/add`, {
            method: 'POST',
            body: JSON.stringify([{
              product_detail_id : choosen_product_id,
              promo_id : promo_id
            }])
        });

        if (!response.ok) {
            console.error('POST apply promo product gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid post apply promo product', data);
            return;
        }
        console.log("apply product berhasil")
      }

    async function addPromo() {
        console.log(JSON.stringify([{
              promo_code,
              promo_type_id,
              promo_start_date,
              promo_end_date,
              promo_percentage,
              promo_discount,
              promo_term_and_cond,
              x_amount,
              y_amount
            }]))
        const response = await fetch(`http://${$uri}:8888/promos/add`, {
            method: 'POST',
            body: JSON.stringify([{
              promo_code,
              promo_type_id,
              promo_start_date,
              promo_end_date,
              promo_percentage,
              promo_discount,
              promo_term_and_cond,
              x_amount,
              y_amount
            }])
        });

        if (!response.ok) {
            console.error('POST add new promo gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid post add promo product', data);
            return;
        }
        console.log("add promo berhasil")
      }
    
    async function applyPromotoStore(sw_id,promo_id) {
        const response = await fetch(`http://${$uri}:8888/promos/stores/add`, {
            method: 'POST',
            body: JSON.stringify([{
              store_warehouse_id : sw_id,
              promo_id : promo_id
            }])
        });

        if (!response.ok) {
            console.error('POST apply promo store gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid post apply promo store', data);
            return;
        }

        console.log("apply promo store berhasil")
      }

    async function addProductPromo(){
      await addPromo();
      let last_promo_id = await getLastPromoId();
      await applyPromotoProduct(last_promo_id);

      for (let i = 0; i < sw_id_list.length; i++) {
        await applyPromotoStore(sw_id_list[i],last_promo_id)  
      }

      
      choosen_product_id = "";
      choosen_product_name = "";

      promo_code = "";
      promo_type_id = 0;
      promo_start_date = "";
      promo_end_date = "";
      promo_percentage = 0;
      promo_discount = 0;
      promo_term_and_cond = "";
      x_amount = 0;
      y_amount = 0;

      sw_id_list = [];

      produk_promos = [];
      await fetchPromos();

      Swal.fire({
          title: "Add promo pada produk berhasil",
          icon: "success",
          color: "white",
          background: "#364445",
          confirmButtonColor: '#F2AA7E'
        });
    }

    async function verifyPromo(promo_id,product_id,status) {
        const response = await fetch(`http://${$uri}:8888/promos/verify/${promo_id}/${product_id}/${status}`, {
            method: 'PUT',
        });

        if (!response.ok) {
            console.error('PUT verify promo gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid put verify promo', data);
            return;
        }
        console.log("verify promo berhasil")
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

      all_profit = [...data.data];
      transactions = [...data.data].sort((a, b) => {
          return new Date(a.Transaction.transaction_timestamp) - new Date(b.Transaction.transaction_timestamp);
      });
      console.log("for graph", transactions);
      list_of_dates = transactions.map(transaction => {
        const date = new Date(transaction.Transaction.transaction_timestamp);
        return date.toLocaleDateString('en-GB', {
              day: '2-digit',
              month: 'short',
              year: 'numeric'
        });
      });

      list_of_discount = transactions.map(transaction => transaction.TransactionDetails.discount_price);

    }
    async function fetchAllDiscount(start_date, end_date) {
      const response = await fetch(`http://${$uri}:8888/promos/cost/product/${start_date}/${end_date}/0/0`, {
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

      all_discount = [...data.data];
      console.log("hha",all_discount);
    }
    onMount(async () => {
      await fetchPromos();
      await fetchProduk();
      end_date = getFormattedDateNow();
      start_date = getThirtyDaysBefore(end_date, 7);
      console.log(start_date, end_date);
      await fetchAllProfit(start_date, end_date);
      all_profit.forEach(profit => {
        weekly_cost += profit.TransactionDetails.discount_price;
      });
      end_date = getFormattedDateNow();
      start_date = getThirtyDaysBefore(end_date, 30);
      console.log(start_date, end_date);
      await fetchAllProfit(start_date, end_date);
      all_profit.forEach(profit => {
        monthly_cost += profit.TransactionDetails.discount_price;
      });
      console.log(start_date, end_date);
      await fetchAllDiscount(start_date, end_date);
      all_discount.forEach(profit => {
        disc_sum += profit.TransactionDetails.discount_price;
      });
      await fetchPromoCategory();
    });
    
    //SEARCH BAR
    $: if (searchQuery != null) {
        filtered_produk_promos = produk_promos.filter(item => 
            item.ProductDetail.product_name.toLowerCase().includes(searchQuery)
        );
    } else {
        filtered_produk_promos = [...produk_promos];
    }
    
    //UNTUK ADD PROMO
    $: if (choosen_product_id != null) {
        all_produk = filtered_all_produk.filter(item => 
            item.ProductDetails.product_detail_id.toString().includes(choosen_product_id)
        );
    } else {
        all_produk = [...filtered_all_produk];
    }
    
    $: if (choosen_product_name.length > 0) {
        all_produk = filtered_all_produk.filter(item => 
            item.ProductDetails.product_name.toLowerCase().includes(choosen_product_name)
        );
    } else {
        all_produk = [...filtered_all_produk];
    }

    async function goToPage(page) {
      if (page < 1 || page > Math.ceil(totalNotes / limit)) return;

      currentPage = page;
      offset = (currentPage - 1) * limit;
      await fetchPromos();
    }
   $: if ((searchQuery_temp !== searchQuery) ){
      console.log(searchQuery);
      fetchPromos();
      searchQuery_temp = searchQuery;
    } else{
      searchQuery_temp = '';
    }

  
  </script>
  
   <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Promos</span>

        <div class="w-11/12 mb-10">
            <div class="grid grid-cols-4 gap-x-2 gap-y-4">
                {#if tampilan == "all_promos"}
                    <button on:click={() => {tampilan = "all_promos"; tampilan = tampilan;}} class="bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">All Promos</button>
                {:else}
                    <button on:click={() => {tampilan = "all_promos"; tampilan = tampilan;}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">All Promos</button>
                {/if}
                {#if tampilan == "promo_req"}
                    <button on:click={() => {tampilan = "promo_req"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Promo Request</button>
                {:else}
                    <button on:click={() => {tampilan = "promo_req"; tampilan = tampilan;}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Promo Request</button>
                {/if}
                {#if tampilan == "promo_cost"}
                    <button on:click={() => {tampilan = "promo_cost"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Promo Cost</button>
                {:else}
                    <button on:click={() => {tampilan = "promo_cost"; tampilan = tampilan;}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Promo Cost</button>
                {/if}
            </div>
        </div>

        {#if tampilan == "all_promos"}
        <div class="w-11/12 flex items-center">
            <div class="relative w-9/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg mr-4">
                <input 
                    type="text" 
                    id="voice-search" 
                    bind:value={searchQuery}
                    class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                    placeholder="Search..."/>
                    <button on:click={toggleFilter}
                    type="button" 
                    class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                    <i class="fa-solid fa-sliders fa-xl mr-2"></i>
                  </button>
                  {#if showFilter}
                    <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-fit bg-gray-100 p-4 rounded-lg font-roboto">
                      <span class="font-bold text-xl mb-1">Promo Period</span>

                      <div class="flex gap-x-4 w-full items-center">
                        <span class="font-semibold text-lg mb-4">From</span>
                        <input type="date" bind:value={startDate} class="rounded-xl w-32 mb-4 p-2 border" />
                        <span class="font-semibold text-lg mb-4">To</span>
                        <input type="date" bind:value={endDate} class="rounded-xl w-32 mb-4 p-2 border" />
                      </div>
                      
                      <span class="font-bold text-xl mb-1">Promo Type</span>
                      <div class="grid grid-cols-4 flex w-full flex-wrap">
                        {#each categories as cat}
                          <button on:click={() => {category = (category === '' || category !== cat.promo_type_id) ? cat.promo_type_id : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:bg-white hover:border hover:border-peach2 hover:text-peach2 ${category === cat.promo_type_id ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>{cat.promo_type_name}</button>
                        {/each}
                      </div>
                      
                      <span class="font-bold text-xl mb-1">Status</span>
                      <div class="grid grid-cols-4 flex w-full flex-wrap">
                          <button on:click={() => {status = (status === 0 || status !== 0) ? 0 : 0;}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${status === 0 ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Unverified</button>
                          <button on:click={() => {status = (status === 0 || status !== 1) ? 1 : 0;}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${status === 1 ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Accepted</button>
                          <button on:click={() => {status = (status === 0 || status !== 2) ? 2 : 0;}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${status === 2 ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Rejected</button>
                      </div>
                      
                      <div class="flex justify-between font-semibold mt-4">
                          <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { status = ''; startDate = ''; endDate = ''; category = ''; }}>Clear</button>
                          <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {fetchPromos(); toggleFilter()}}>Apply</button>
                      </div>
                    </div>
                  {/if}
            </div>
            <div class="relative w-3/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-xl">
                <button on:click={async() => {await fetchProduk(); showModal = "choose_product"}} class="w-full py-4 rounded-xl bg-peach font-semibold text-lg text-darkGray border-2 border-darkGray"><i class="fa-solid fa-plus mr-2"></i>Add New Promo</button>
            </div>
        </div>
        {:else if tampilan == "promo_req"}
        <div class="w-11/12 flex items-center">
          <div class="relative w-full shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg mr-4">
              <input 
                  type="text" 
                  id="voice-search" 
                  bind:value={searchQuery}
                  class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                  placeholder="Search..."/>
                  <button on:click={toggleFilter}
                  type="button" 
                  class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                  <i class="fa-solid fa-sliders fa-xl mr-2"></i>
                </button>
                {#if showFilter}
                  <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-fit bg-gray-100 p-4 rounded-lg font-roboto">
                    <span class="font-bold text-xl mb-1">Promo Period</span>

                    <div class="flex gap-x-4 w-full items-center">
                      <span class="font-semibold text-lg mb-4">From</span>
                      <input type="date" bind:value={startDate} class="rounded-xl w-32 mb-4 p-2 border" />
                      <span class="font-semibold text-lg mb-4">To</span>
                      <input type="date" bind:value={endDate} class="rounded-xl w-32 mb-4 p-2 border" />
                    </div>
                    
                    <span class="font-bold text-xl mb-1">Promo Type</span>
                    <div class="grid grid-cols-4 flex w-full flex-wrap">
                      {#each categories as cat}
                        <button on:click={() => {category = (category === '' || category !== cat.promo_type_id) ? cat.promo_type_id : '';}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:bg-white hover:border hover:border-peach2 hover:text-peach2 ${category === cat.promo_type_id ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>{cat.promo_type_name}</button>
                      {/each}
                    </div>
                    
                    <span class="font-bold text-xl mb-1">Status</span>
                    <div class="grid grid-cols-4 flex w-full flex-wrap">
                        <button on:click={() => {status = (status === 0 || status !== 0) ? 0 : 0;}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${status === 0 ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Unverified</button>
                        <button on:click={() => {status = (status === 0 || status !== 1) ? 1 : 0;}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${status === 1 ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Accepted</button>
                        <button on:click={() => {status = (status === 0 || status !== 2) ? 2 : 0;}} class={`border-gray-400 border w-32 mx-1 my-1 rounded-2xl p-2 hover:border hover:bg-white hover:border-peach2 hover:text-peach2 ${status === 2 ? 'bg-white text-peach2 border-[#f2b082]' : 'bg-gray-100'}`}>Rejected</button>
                    </div>
                    
                    <div class="flex justify-between font-semibold mt-4">
                        <button class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" on:click={() => { status = ''; startDate = ''; endDate = ''; category = ''; }}>Clear</button>
                        <button class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded" on:click={() => {fetchPromos(); toggleFilter()}}>Apply</button>
                    </div>
                  </div>
                {/if}
            </div>
        </div>
        {/if}
    {#if tampilan != "promo_cost"}
    <nav class="my-8">
      <ul class="flex items-center -space-x-px h-8 text-sm">
         {#if totalNotes !== 0}
         <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
            <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
            </svg>
            Previous
          </a>
         </li>
         {/if}
    
        <!-- Pagination Links -->
        {#each Array(Math.ceil(totalNotes / limit)) as _, i}
          <li>
            <a href="#" on:click|preventDefault={() => goToPage(i + 1)} class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">{i + 1}</a>
          </li>
        {/each}

        {#if totalNotes !== 0}
        <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
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

      <div class="w-[96%] my-5 font-roboto">
        {#if tampilan == "all_promos"}
        <div class="relative overflow-x-auto sm:rounded-lg">
            {#each filtered_produk_promos as promo}
              {#if promo.PromoProducts.status_verify != 0}
                <div class="flex items-center border-2 rounded-xl ml-auto border-gray-700 m-3 py-2 px-4">    
                  <div class="w-10/12 flex flex-col font-semibold text-lg">
                    <span class="my-1">{promo["ProductDetail"].product_name}</span>
                    <div class="flex justify-between my-1">
                      <span class="mx-1 text-peach2">Applied to {promo.total_store} Stores</span>
                      <span class="mx-1">
                        {#if promo["Promo"].promo_type_id == 1}
                          BUYXGETY
                        {:else if promo["Promo"].promo_type_id == 2}
                          %DISCOUNT
                        {:else if promo["Promo"].promo_type_id == 3}
                          RPDISCOUNT
                        {:else if promo["Promo"].promo_type_id == 4}
                          BUYXDISCOUNT%
                        {/if}
                      </span>
                      <span class="mx-1">Promo End : {promo["Promo"].promo_end_date}</span>
                    </div>
                    <div class="flex">
                      <span>Requested by {promo.username},
                        {#if promo.PromoProducts.status_verify == 0}
                          <span class="">UNVERIFIED</span>
                        {:else if promo.PromoProducts.status_verify == 1}
                          <span class="text-green-600">ACCEPTED</span>
                        {:else}
                          <span class="text-red-600">REJECTED</span>
                        {/if}
                      </span>
                  </div>
                  </div>
              
                  <div class="w-2/12 flex justify-end items-center">
                    <button on:click={() => {showModal =  promo.ProductDetail.product_detail_id; showModal = showModal}} class="p-4 bg-darkGray rounded-xl"><svg width="60" height="60" viewBox="0 0 60 60" fill="none" xmlns="http://www.w3.org/2000/svg">
                      <path d="M2.5 30C2.5 30 12.5 10 30 10C47.5 10 57.5 30 57.5 30C57.5 30 47.5 50 30 50C12.5 50 2.5 30 2.5 30Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                      <path d="M30 37.5C34.1421 37.5 37.5 34.1421 37.5 30C37.5 25.8579 34.1421 22.5 30 22.5C25.8579 22.5 22.5 25.8579 22.5 30C22.5 34.1421 25.8579 37.5 30 37.5Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                    </button>
                  </div>
                </div>
              {/if}
            {/each}
        </div>
        {:else if tampilan == "promo_req"}
        <div class="relative overflow-x-auto sm:rounded-lg">
            {#each filtered_produk_promos as promo}
            <div class="flex items-center border-2 rounded-xl ml-auto border-gray-700 m-3 py-2 px-4">    
              <div class="w-9/12 flex flex-col font-semibold text-lg">
                <span class="my-1">{promo["ProductDetail"].product_name}</span>
                <div class="flex justify-between my-1">
                  <span class="mx-1 text-peach2">Applied to {promo.total_store} Stores</span>
                  <span class="mx-1">
                    {#if promo["Promo"].promo_type_id == 1}
                      BUYXGETY
                    {:else if promo["Promo"].promo_type_id == 2}
                      %DISCOUNT
                    {:else if promo["Promo"].promo_type_id == 3}
                      RPDISCOUNT
                    {:else if promo["Promo"].promo_type_id == 4}
                      BUYXDISCOUNT%
                    {/if}
                  </span>
                  <span class="mx-1">Promo End : {promo["Promo"].promo_end_date}</span>
                </div>
                <div class="flex justify-between my-1 font-semibold">
                    <div class="flex">
                        <span>Requested by {promo.username},
                          {#if promo.PromoProducts.status_verify == 0}
                            <span class="">UNVERIFIED</span>
                          {:else if promo.PromoProducts.status_verify == 1}
                            <span class="text-green-600">ACCEPTED</span>
                          {:else}
                            <span class="text-red-600">REJECTED</span>
                          {/if}
                        </span>
                    </div>
                    {#if promo.Promo.promo_type_id == 1}
                      <span class="text-peach2 flex">-<MoneyConverter value={promo.ProductDetail.sell_price} currency={true} decimal={true}></MoneyConverter></span>
                    {:else if promo.Promo.promo_type_id == 2 || promo.Promo.promo_type_id == 4}
                      <span class="text-peach2 flex">-<MoneyConverter value={promo.ProductDetail.sell_price*(promo.Promo.promo_percentage/100)} currency={true} decimal={true}></MoneyConverter></span>
                    {:else if promo.Promo.promo_type_id == 3}
                      <span class="text-peach2 flex">-<MoneyConverter value={promo.ProductDetail.sell_price-promo.Promo.promo_discount} currency={true} decimal={true}></MoneyConverter></span>
                    {/if}
                </div>
              </div>
              
              <div class="w-3/12 flex justify-end items-center">
                {#if promo.PromoProducts.status_verify == 0}
                  <button on:click={async() => {await verifyPromo(promo.Promo.promo_id,promo.ProductDetail.product_detail_id,2); 
                  Swal.fire({
                    title: "Promo berhasil direject",
                    icon: "success",
                    color: "white",
                    background: "#364445",
                    confirmButtonColor: '#F2AA7E'
                  }); await fetchPromos(); closeModal();}} class="w-24 py-4 mr-2 bg-darkGray border-2 border-darkGray rounded-xl"><i class="fa-solid fa-xmark fa-3x" style="color: #FACFAD;"></i></button>
                  <button on:click={async() => {await verifyPromo(promo.Promo.promo_id,promo.ProductDetail.product_detail_id,1); 
                    Swal.fire({
                      title: "Promo berhasil diaccept",
                      icon: "success",
                      color: "white",
                      background: "#364445",
                      confirmButtonColor: '#F2AA7E'
                    }); await fetchPromos(); closeModal();}} class="w-24 py-4 bg-peach border-2 border-darkGray rounded-xl"><i class="fa-solid fa-check fa-3x" style="color: #364445;"></i></button>
                {:else}
                  <button on:click={() => {showModal =  promo.ProductDetail.product_detail_id; showModal = showModal}} class="p-4 bg-darkGray rounded-xl"><svg width="60" height="60" viewBox="0 0 60 60" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M2.5 30C2.5 30 12.5 10 30 10C47.5 10 57.5 30 57.5 30C57.5 30 47.5 50 30 50C12.5 50 2.5 30 2.5 30Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                    <path d="M30 37.5C34.1421 37.5 37.5 34.1421 37.5 30C37.5 25.8579 34.1421 22.5 30 22.5C25.8579 22.5 22.5 25.8579 22.5 30C22.5 34.1421 25.8579 37.5 30 37.5Z" stroke="#FACFAD" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                    </svg>
                  </button>
                {/if}
              </div>
            </div>
            {/each}
        </div>
        {:else if tampilan == "promo_cost"}
            <div class="flex mb-8 ">
                <div class="w-96 p-6 mx-4 border-2 border-darkGray text-darkGray rounded-2xl drop-shadow-xl">
                    <div class="flex flex-col">
                        <span class="mb-1 font-semibold text-xl">Total Promo Cost (Weekly)</span>
                        <span class="font-bold text-4xl flex gap-x-2">- <MoneyConverter bind:value={weekly_cost} currency={true} decimal={true}/></span>
                    </div>
                </div>
                <div class="w-96 p-6 mx-4 border-2 border-darkGray text-darkGray rounded-2xl drop-shadow-xl">
                    <div class="flex flex-col">
                        <span class="mb-1 font-semibold text-xl">Total Promo Cost (Monthly)</span>
                        <span class="font-bold text-4xl flex gap-x-2">- <MoneyConverter bind:value={monthly_cost} currency={true} decimal={true}/></span>
                    </div>
                </div>
            </div>

            <div class="flex  mx-4">
                {#if tab_menu == "detail"}
                    <button on:click={() => tab_menu = "detail"} class="px-4 pt-2 pb-2 rounded-t-xl border-t-2 border-r-2 border-l-2 border-darkGray text-darkGray font-semibold mr-2">Detail</button>
                    <button on:click={() => tab_menu = "graph"} class="px-4 mt-4 py-1 bg-gray-300 rounded-t-xl border-t-2 border-r-2 border-l-2 border-darkGray text-darkGray font-semibold">Graph</button>
                {:else if tab_menu == "graph"}
                    <button on:click={() => tab_menu = "detail"} class="px-4 mt-4 py-1 bg-gray-300 rounded-t-xl border-t-2 border-r-2 border-l-2 border-darkGray text-darkGray font-semibold mr-2">Detail</button>
                    <button on:click={() => tab_menu = "graph"} class="px-4 pt-2 pb-2 rounded-t-xl border-t-2 border-r-2 border-l-2 border-darkGray text-darkGray font-semibold">Graph</button>
                {/if}
            </div>
            <div class="w-11/12 mx-4 rounded-b-xl rounded-r-xl min-h-48 border-2 border-darkGray py-4 px-8">
              {#if tab_menu === "detail"}
                <span class="flex w-full justify-center text-2xl font-semibold my-4">1 Month</span>
                <div class="flex flex-col mb-4">
                    <span class="font-semibold text-lg">Products</span>
                    {#each all_discount as disc}
                      <div class="flex justify-between hover:bg-gray-300">
                        {#if disc.PromoTypes.promo_type_name === "BUYXGETY"}
                          <span class="indent-8 font-semibold text-lg flex">BUY {disc.Promos.x_amount} GET {disc.Promos.y_amount} {disc.ProductDetails.product_name}</span>
                        {:else if disc.PromoTypes.promo_type_name === "%DISCOUNT"}
                          <span class="indent-8 font-semibold text-lg flex">DISCOUNT {disc.TransactionDetails.promo_percentage}% {disc.ProductDetails.product_name}</span>
                        {:else if disc.PromoTypes.promo_type_name === "RPDISCOUNT"}
                          <span class="indent-8 font-semibold text-lg flex">DISCOUNT <MoneyConverter bind:value={disc.TransactionDetails.discount_price} currency={true} decimal={true}/>  {disc.ProductDetails.product_name}</span>
                        {:else if disc.PromoTypes.promo_type_name === "BUYXDISCOUNT%"}
                          <span class="indent-8 font-semibold text-lg flex">BUY {disc.Promos.x_amount} GET {disc.TransactionDetails.promo_percentage}% {disc.ProductDetails.product_name}</span>
                        {/if}
                          
                        <span class="font-semibold text-lg"><MoneyConverter bind:value={disc.TransactionDetails.discount_price} currency={true} decimal={true}/></span>

                      </div>
                    {/each}
                    {#if all_discount.length === 0}
                    <div class="justify-center w-full h-full flex border-2 rounded-xl py-4 border-gray-400 my-3 ">
                      No promo used.
                    </div>
                    {/if}
                </div>

                <hr class="border-4 border-gray-300 mb-4">

                <div class="flex flex-col mb-4">
                    <span class="font-semibold text-lg">Total</span>
                    <div class="flex justify-between hover:bg-gray-300">
                        <span class="indent-8 font-semibold text-lg">Total Promo Cost</span>
                        <span class="font-semibold text-lg"><MoneyConverter bind:value={disc_sum} currency={true} decimal={true}/></span>
                    </div>
                </div>
                <div class="flex justify-center mb-4">
                  <button on:click={async () => {dateChosen = '1Y'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 365); console.log(start_date, end_date); await fetchAllDiscount(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '1Y' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>1Y</button>
                  <button on:click={async () => {dateChosen = '6M'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 182); console.log(start_date, end_date); await fetchAllDiscount(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '6M' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>6M</button>
                  <button on:click={async () => {dateChosen = '3M'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 91); console.log(start_date, end_date); await fetchAllDiscount(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '3M' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>3M</button>
                  <button on:click={async () => {dateChosen = '1M'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 30); console.log(start_date, end_date); await fetchAllDiscount(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '1M' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>1M</button>
                  <button on:click={async () => {dateChosen = '2W'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 14); console.log(start_date, end_date); await fetchAllDiscount(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '2W' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>2W</button>
                  <button on:click={async () => {dateChosen = '1W'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 7); console.log(start_date, end_date); await fetchAllDiscount(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '1W' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>1W</button>
                  <button on:click={async () => {dateChosen = '3D'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 3); console.log(start_date, end_date); await fetchAllDiscount(start_date, end_date);  }} class={`border border-[#f2b082] text-sm font-normal py-3 px-4 text-black ${dateChosen === '3D' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>3D</button>
                </div>
              {:else if tab_menu === "graph"}
              <div class="flex justify-center">
                {#if list_of_discount.length > 0 && list_of_dates.length > 0}
                    <LineChart data={list_of_discount} dates={list_of_dates} labelColor={"black"} width={800} height={400} />
                {:else}
                  <div class="text-black m-4">No Transaction have been made.</div>
                {/if}
              </div>
                <div class="flex justify-center mb-4">
                  <button on:click={async () => {dateChosen = '1Y'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 365); console.log(start_date, end_date); await fetchAllProfit(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '1Y' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>1Y</button>
                  <button on:click={async () => {dateChosen = '6M'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 182); console.log(start_date, end_date); await fetchAllProfit(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '6M' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>6M</button>
                  <button on:click={async () => {dateChosen = '3M'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 91); console.log(start_date, end_date); await fetchAllProfit(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '3M' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>3M</button>
                  <button on:click={async () => {dateChosen = '1M'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 30); console.log(start_date, end_date); await fetchAllProfit(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '1M' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>1M</button>
                  <button on:click={async () => {dateChosen = '2W'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 14); console.log(start_date, end_date); await fetchAllProfit(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '2W' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>2W</button>
                  <button on:click={async () => {dateChosen = '1W'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 7); console.log(start_date, end_date); await fetchAllProfit(start_date, end_date);  }} class={`border border-[#f2b082] border-r-0 text-sm font-normal py-3 px-4 text-black ${dateChosen === '1W' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>1W</button>
                  <button on:click={async () => {dateChosen = '3D'; end_date = getFormattedDateNow(); start_date = getThirtyDaysBefore(end_date, 3); console.log(start_date, end_date); await fetchAllProfit(start_date, end_date);  }} class={`border border-[#f2b082] text-sm font-normal py-3 px-4 text-black ${dateChosen === '3D' ? 'bg-[#f2b082] ' : 'bg-transparent'}`}>3D</button>
                </div>
              {/if}
            </div>
        {/if}
    </div>
      
    {#if tampilan != "promo_cost"}
       
    <nav class="my-8">
      <ul class="flex items-center -space-x-px h-8 text-sm">
         {#if totalNotes !== 0}
         <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
            <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
            </svg>
            Previous
          </a>
         </li>
         {/if}
    
        <!-- Pagination Links -->
        {#each Array(Math.ceil(totalNotes / limit)) as _, i}
          <li>
            <a href="#" on:click|preventDefault={() => goToPage(i + 1)} class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">{i + 1}</a>
          </li>
        {/each}

        {#if totalNotes !== 0}
        <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
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

<!-- MODAL CHOOSE PRODUCT -->
{#if showModal == "choose_product" }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Choose Product</div>
    </div>
    <div class="flex flex-col justify-center p-8">
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold">Product ID</span>
        <input on:input={() => showDropDownID = true} bind:value={choosen_product_id}  type="number" class="rounded-xl mb-1 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none" placeholder="Choose Product ID">
        {#if showDropDownID}
          <ul class="z-10 bg-peach text-darkGray rounded">
            {#each all_produk as produk}
              <li on:click={async() => {
                choosen_product_id = produk.ProductDetails.product_detail_id;
                choosen_product_id = choosen_product_id;
                await matchIDandName(choosen_product_id,"id");
                showDropDownID = false;
                }} class="p-1 rounded hover:bg-peach2 font-semibold">{produk.ProductDetails.product_detail_id}</li>
            {/each}  
          </ul>
        {/if}
      </div>
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold">Product Name</span>
        <input on:input={() => showDropDownName = true} bind:value={choosen_product_name} type="text" class="rounded-xl mb-1" placeholder="Choose Product Name">
        {#if showDropDownName}
        <ul class="z-10 bg-peach text-darkGray rounded">
          {#each all_produk as produk}
              <li on:click={async() => {
                choosen_product_name = produk.ProductDetails.product_name;
                choosen_product_name = choosen_product_name;
                showDropDownName = false;
                await matchIDandName(choosen_product_name,"name");
                }} class="p-1 rounded hover:bg-peach2 font-semibold">{produk.ProductDetails.product_name}</li>
            {/each}  
        </ul>
        {/if}
      </div>
      <div class="flex mt-8 items-center justify-center">
        <button on:click={() => closeModal()} class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
        <button on:click={() => {checkChooseProduct();}} class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Add</button>
      </div>
    </div>
  </TaskModal> 
{/if}

  <!-- MODAL ADD PROMO -->
{#if showModal == "add_promo" }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Add Promo</div>
    </div>
    <div class="flex flex-col justify-center p-8">
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold mb-1">Product ID</span>
        <input value={choosen_product_id} readonly type="text" class="rounded-xl mb-1" placeholder="Choose Product ID">
      </div>
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold mb-1">Product Name</span>
        <input value={choosen_product_name} readonly type="text" class="rounded-xl mb-1">
      </div>
      <div class="flex flex-col my-1 mb-2">
        <span class="text-peach font-semibold mb-1">Product Promo</span>
        <div class="w-2/3 grid grid-cols-2 gap-2">
          {#if showPromoInput == "1"}
            <button on:click={() => {showPromoInput = "0"}} class="w-full py-2 bg-peach text-darkGray border border-peach rounded-2xl font-semibold">BUYXGETY</button>
          {:else}
            <button on:click={() => {showPromoInput = "1"; promo_type_id = 1; promo_type_id = promo_type_id}} class="w-full py-2 bg-darkGray text-peach border border-peach rounded-2xl font-semibold">BUYXGETY</button>
          {/if}
          {#if showPromoInput == "2"}
            <button on:click={() => {showPromoInput = "0"}} class="w-full py-2 bg-peach text-darkGray border border-peach rounded-2xl font-semibold">%DISCOUNT</button>
          {:else}
            <button on:click={() => {showPromoInput = "2"; promo_type_id = 2; promo_type_id = promo_type_id}} class="w-full py-2 bg-darkGray text-peach border border-peach rounded-2xl font-semibold">%DISCOUNT</button>
          {/if}
          {#if showPromoInput == "3"}
            <button on:click={() => {showPromoInput = "0"}} class="w-full py-2 bg-peach text-darkGray border border-peach rounded-2xl font-semibold">RPDISCOUNT</button>
          {:else}
            <button on:click={() => {showPromoInput = "3"; promo_type_id = 3; promo_type_id = promo_type_id}} class="w-full py-2 bg-darkGray text-peach border border-peach rounded-2xl font-semibold">RPDISCOUNT</button>
          {/if}
          {#if showPromoInput == "4"}
            <button on:click={() => {showPromoInput = "0"}} class="w-full py-2 bg-peach text-darkGray border border-peach rounded-2xl font-semibold">BUYXDISCOUNT%</button>
          {:else}
            <button on:click={() => {showPromoInput = "4"; promo_type_id = 4; promo_type_id = promo_type_id}} class="w-full py-2 bg-darkGray text-peach border border-peach rounded-2xl font-semibold">BUYXDISCOUNT%</button>
          {/if}
        </div>
      </div>

      {#if showPromoInput != "0"}
        <div class="flex flex-col my-1">
          <span class="text-peach font-semibold mb-1">Promo Code</span>
          <input bind:value={promo_code} type="text" class="rounded-xl mb-1">
        </div>

        {#if showPromoInput == "1"}
        <!-- PROMO TYPE 1 : BUY X, GET Y -->
        <div class="flex items-center my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Buy Amount</span>
          <input bind:value={x_amount} type="number" class="w-32 rounded-xl mb-1 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none">
        </div>
        <div class="flex items-center my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Get Amount</span>
          <input bind:value={y_amount} type="number" class="w-32 rounded-xl mb-1 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none">
        </div>
        
        {:else if showPromoInput == "2"}
        <!-- PROMO TYPE 2 : %DISCOUNT -->
        <div class="flex items-center my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Discount Percentage (%) </span>
          <input bind:value={promo_percentage} type="number" class="w-32 rounded-xl mb-1 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none">
        </div>
        
        {:else if showPromoInput == "3"}
        <!-- PROMO TYPE 3 : RPDISCOUNT -->
        <div class="flex items-center my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Discount Amount (Rp) </span>
          <input bind:value={promo_discount} type="number" class="w-32 rounded-xl mb-1 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none">
        </div>
        
        {:else if showPromoInput == "4"}
        <!-- PROMO TYPE 4 : BUY X, DISCOUNT% -->
        <div class="flex items-center my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Buy Amount</span>
          <input bind:value={x_amount} type="number" class="w-32 rounded-xl mb-1 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none">
        </div>
        <div class="flex items-center my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Discount Percentage (%) </span>
          <input bind:value={promo_percentage} type="number" class="w-32 rounded-xl mb-1 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none">
        </div>
        {/if}


        <!-- CHOOSE STORE (STORE LIST) -->
        <div class="flex flex-col my-1">
          <div class="flex items-center mb-1">
            <span class="text-peach font-semibold mr-2">Store List</span>
            <input on:change={() => {addStoreToList("all"); toggleSwListAll();}} class="border border-peach bg-darkGray" type="checkbox">
          </div>
          
          {#each storeWarehouse as store}
          {#if store.store_warehouse_type == "STORE"}
            <ul class="font-semibold text-white ml-2">
              <li class="mb-1">
                <div class="flex items-center">
                  {#if swListAll == false}
                    <input on:change={() => {addStoreToList(store.store_warehouse_id)}} class="border border-white bg-darkGray  mr-2" type="checkbox">
                  {:else}
                    <input checked disabled class="border border-white bg-darkGray  mr-2" type="checkbox">
                  {/if}
                    <span class="">{store.store_warehouse_name}</span>
                </div>
              </li>
            </ul>
          {/if}
          {/each}
        </div>

        <!-- TIME START END -->
        <div class="flex items-center my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Time Start</span>
          <input type="date" bind:value={promo_start_date} class="rounded-xl mb-1 w-60">
        </div>
        <div class="flex items-center my-1">
          <span class="text-peach font-semibold mb-1 mr-4">Time End</span>
          <input type="date" bind:value={promo_end_date} class="rounded-xl mb-1 w-60">
        </div>

        <div class="flex flex-col my-1">
          <span class="text-peach font-semibold mb-1">Promo Term & Condition</span>
          <textarea bind:value={promo_term_and_cond} rows="3" type="text" class="rounded-xl mb-1"></textarea>
        </div>
      {/if}

      <div class="flex mt-8 items-center justify-center">
        <button on:click={() => {showModal = "choose_product"}} class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
        <button on:click={async() => {await addProductPromo(); closeModal()}} class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Add</button>
      </div>
    </div>
  </TaskModal> 
{/if}

{#each produk_promos as promo}
  <!-- MODAL VIEW PROMO PRODUCT-->
{#if showModal == promo.ProductDetail.product_detail_id }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Add Promo</div>
    </div>
    <div class="flex flex-col justify-center p-8">
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold mb-1">Product Name</span>
        <span class="text-white font-semibold mb-1">{promo.ProductDetail.product_name}</span>
      </div>
      <div class="flex flex-col my-1 mb-2">
        <span class="text-peach font-semibold mb-1">Product Promo</span>
        <span class="text-white font-semibold mb-1">
          {#if promo["Promo"].promo_type_id == 1}
            BUYXGETY
          {:else if promo["Promo"].promo_type_id == 2}
            %DISCOUNT
          {:else if promo["Promo"].promo_type_id == 3}
            RPDISCOUNT
          {:else if promo["Promo"].promo_type_id == 4}
            BUYXDISCOUNT%
          {/if}
        </span>
      </div>

      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold mb-1">Promo Code</span>
        <span class="text-white font-semibold mb-1">{promo.Promo.promo_code}</span>
      </div>

      {#if promo["Promo"].promo_type_id == 1}
        <div class="flex flex-col my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Buy Amount</span>
          <span class="text-white font-semibold mb-1 mr-2">{promo.Promo.x_amount}</span>
        </div>
        <div class="flex flex-col my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Get Amount</span>
          <span class="text-white font-semibold mb-1 mr-2">{promo.Promo.y_amount}</span>
        </div>
      {:else if promo["Promo"].promo_type_id == 2}
        <div class="flex flex-col my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Discount Percentage (%) </span>
          <span class="text-white font-semibold mb-1 mr-2">{promo.Promo.promo_percentage}</span>
        </div>
      {:else if promo["Promo"].promo_type_id == 3}
        <div class="flex flex-col my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Discount Amount (Rp) </span>
          <span class="text-white font-semibold mb-1 mr-2">{promo.Promo.promo_discount}</span>
        </div>
      {:else if promo["Promo"].promo_type_id == 4}
        <div class="flex flex-col my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Buy Amount</span>
          <span class="text-white font-semibold mb-1 mr-2">{promo.Promo.x_amount}</span>
        </div>
        <div class="flex flex-col my-1">
          <span class="text-peach font-semibold mb-1 mr-2">Discount Percentage (%) </span>
          <span class="text-white font-semibold mb-1 mr-2">{promo.Promo.promo_percentage}</span>
        </div>
      {/if}

      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold mr-2">Total Store Applied</span>
        <span class="text-white font-semibold mr-2">{promo.total_store}</span>
      </div>

      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold mb-1 mr-2">Time Start</span>
        <span class="text-white font-semibold mb-1 mr-2">{promo.Promo.promo_start_date}</span>
      </div>
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold mb-1 mr-4">Time End</span>
        <span class="text-white font-semibold mb-1 mr-2">{promo.Promo.promo_end_date}</span>
      </div>

      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold mb-1">Promo Term & Condition</span>
        <span class="text-white font-semibold mb-1 mr-2">{promo.Promo.promo_term_and_cond}</span>
      </div>

      <div class="flex mt-8 items-center justify-center">
        <button on:click={() => {closeModal();}} class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>  
      </div>
    </div>
  </TaskModal> 
  {/if}
{/each}