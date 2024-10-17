<script>
  import TaskModal from '$lib/TaskModal.svelte';
  import MoneyConverter from '$lib/MoneyConverter.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { uri, userId, roleId, sessionId } from '$lib/uri.js';
  import img_toko from "$lib/assets/store.png";

  let storeWarehouse = [];
  let filtered_sw = [];

  $: limit = 10; 
  $: offset = 0;
  $: currentPage = 1; 
  $: totalRows = 0;
  $: totalPages = Math.ceil(totalRows/limit);
  
  let showModal = false;
  let searchQuery = '';
  let searchQuery_temp = '';

  //BUAT ADD PROMO

  $: showDropDownID = false;
  $: showDropDownName = false;
  $: showPromoInput = 0;
  $: swListAll = false;

  let produk_promos = [];
  let filtered_produk_promos = [];
  let all_produk = [];
  let filtered_all_produk = [];
  // let storeWarehouse = [];

  let choosen_product_id = null;
  let choosen_product_name = "";

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
  $: sw_id_list = [];

  function closeModal() {
     showModal = false;
  }

  function handleClick() {
     showModal = true;
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
  
  // async function fetchSW(){
  //     const response = await fetch(`http://${$uri}:8888/store_warehouses/${$userId}/${$roleId}/''/0/0`, {
  //         method: 'GET',
  //         headers: {
  //             'Content-Type': 'application/json'
  //         }
  //     });

  //     if (!response.ok) {
  //         console.error('fetch all promo failed', response);
  //         return;
  //     }

  //     const data = await response.json();

  //     if (data.status !== 200) {
  //         console.error('Invalid fetch all promo', data);
  //         return;
  //     }

  //     let tmp_sw = data.data;

  //     for(let i = 0; i < tmp_sw.length; i++){

  //     }

  //     storeWarehouse = data.data;
  // }

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
      // await fetchSW();
      // await getAllStoreWarehouse()
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
        sw_id_list = sw_id_list;
    }
  }

  function toggleSwListAll(){
    swListAll = !swListAll;
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

      let description = "User ID "+$userId+" membuat promo baru dengan ID promo "+ last_promo_id;
      //1 Add Promo
      await insertNotif(description,1)

      await applyPromotoProduct(last_promo_id);

      for (let i = 0; i < sw_id_list.length; i++) {
        await applyPromotoStore(sw_id_list[i],last_promo_id)
        
        let description = "User ID "+$userId+" menerapkan promo ID "+ last_promo_id + " pada produk ID " + choosen_product_id + " dan store ID " + sw_id_list[i];
        //18 Apply Promo
        await insertNotif(description,18)
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
      // await fetchPromos();

      Swal.fire({
          title: "Add promo pada produk berhasil",
          icon: "success",
          color: "white",
          background: "#364445",
          confirmButtonColor: '#F2AA7E'
        });
  }

  function navigateToStorePage(store_warehouse_id) {
      const url = `/manage_promos/${store_warehouse_id}`;
      goto(url);
  }

  onMount(async () => {
      await getAllStoreWarehouse();
  });

  async function getAllStoreWarehouse(){
      const response = await fetch(`http://${$uri}:8888/store_warehouses/${$userId}/${$roleId}/${searchQuery}/${limit}/${offset}`, {
          method: 'GET',
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('fetch store warehouse failed', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid fetch store warehouse', data);
          return;
      }

      totalRows = data.data.length;
      totalPages = Math.ceil(totalRows/limit);
      let tmp = data.data

      for(let i = 0; i < tmp.length; i++){
        if (tmp[i].StoreWarehouses.store_warehouse_type == "STORE"){
          storeWarehouse.push(tmp[i]);
        }
      }

      filtered_sw = structuredClone(storeWarehouse);
      console.log(storeWarehouse);
      
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

  async function goToPage(page) {
      if (page < 1 || page > Math.ceil(totalRows / limit)) return;

      currentPage = page;
      offset = (currentPage - 1) * limit;
      await getAllStoreWarehouse()
  }

  $: if ((searchQuery_temp !== searchQuery) ){
    console.log(searchQuery);
    getAllStoreWarehouse();
    searchQuery_temp = searchQuery;
  } else{
    searchQuery_temp = '';
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

</script>

 <div class="mt-[90px] mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Promos</span>
    
    <!-- <form class="flex items-center max-w-lg mx-auto">    -->
       <label for="voice-search" class="sr-only">Search</label>
       <div class="w-11/12 flex items-center">
        <div class="relative w-9/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg mr-4">
            <input 
                type="text" 
                id="voice-search" 
                bind:value={searchQuery}
                class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                placeholder="Search by store name..."/>
        </div>
        <div class="relative w-3/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-xl">
            <button on:click={async() => {await fetchProduk(); showModal = "choose_product"}} class="w-full py-4 rounded-xl bg-peach font-semibold text-lg text-darkGray border-2 border-darkGray"><i class="fa-solid fa-plus mr-2"></i>Add New Promo</button>
        </div>
      </div>

    <!-- </form> -->
       {#each filtered_sw as store}
          <!-- {#if store.StoreWarehouses.store_warehouse_type != "WAREHOUSE"} -->
              <button on:click={() => navigateToStorePage(store.StoreWarehouses.store_warehouse_id)} class="my-4 p-4 border-2 border-black rounded-xl w-11/12 hover:bg-gray-200">
                  <div class="flex">
                      <img class="w-32 rounded-xl mr-8 " src={img_toko} alt="">
                      <div class="w-10/12 flex flex-col items-start justify-center">
                          <span class="text-2xl font-semibold text-wrap my-1">{store.StoreWarehouses.store_warehouse_name}</span>
                          <span class="text-2xl font-semibold text-wrap my-1 text-start">{store.StoreWarehouses.store_warehouse_address}</span>
                      </div>
                  </div>
              </button>
          <!-- {/if} -->
      {/each}


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
          {#if sw_id_list.length != storeWarehouse.length}
            <input on:change={() => {addStoreToList("all"); swListAll = true; console.log(swListAll); console.log("sw_id_list",sw_id_list)}} class="border border-peach bg-darkGray" type="checkbox">
          {:else if sw_id_list.length == storeWarehouse.length}
            <input checked on:change={() => {addStoreToList("all"); swListAll = false; console.log(swListAll); console.log("sw_id_list",sw_id_list)}} class="border border-peach bg-darkGray" type="checkbox">
          <!-- {:else} -->
            <!-- <input checked disabled class="border border-peach bg-darkGray disabled:opacity-75" type="checkbox"> -->
          {/if}
        </div>
        
        {#each storeWarehouse as store}
        <!-- {#if store.StoreWarehouses.store_warehouse_type == "STORE"} -->
          <ul class="font-semibold text-white ml-2">
            <li class="mb-1">
              <div class="flex items-center">
                {#if swListAll == false && (sw_id_list.find((id) => id == store.StoreWarehouses.store_warehouse_id) == null)}
                  <input on:change={() => {addStoreToList(store.StoreWarehouses.store_warehouse_id)}} class="border border-white bg-darkGray  mr-2" type="checkbox">
                {:else if swListAll == false && (sw_id_list.find((id) => id == store.StoreWarehouses.store_warehouse_id) != null)}
                  <input checked on:change={() => {addStoreToList(store.StoreWarehouses.store_warehouse_id)}} class="border border-white bg-darkGray  mr-2" type="checkbox">
                {:else if swListAll == true}
                  <input checked disabled class="border border-white bg-darkGray disabled:opacity-75 mr-2" type="checkbox">
                {/if}
                  <span class="">{store.StoreWarehouses.store_warehouse_name}</span>
              </div>
            </li>
          </ul>
        <!-- {/if} -->
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
