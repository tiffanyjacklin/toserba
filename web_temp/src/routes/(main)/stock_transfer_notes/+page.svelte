<script>
  import TaskModal from '$lib/TaskModal.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
  import MoneyConverter from '$lib/MoneyConverter.svelte';
  import { onMount } from 'svelte';
  import { uri, userId, roleId } from '$lib/uri.js';
  import img_produk from "$lib/assets/produk.png";
  $: limit = 10; // Number of items per page
  $: offset = 0; // Offset for pagination
  let totalNotes = 7; // Total number of notes (assumed to be fetched from server)
  $: currentPage = 1; // Current page

  let tf_notes = [];
  let transfer_notes = [];
  let tf_notes_details = [];
  let transfer_notes_details = [];
  let delivery_orders = [];
  let delivery_order_details = [];
  let searchQuery = '';
  let showModal = null; 
  let viewDeliveryOrders = true;
  let showSuratJalan = false;
  let idSuratJalan = 0;
  let productLeft = false;
  let from = {};
  let to = {};
  let notes = '';
  let products_to_send_fix = [];
  function resetLoad(){
    transfer_notes_details = tf_notes_details;
    notes = '';
  }
  async function saveLoad(transfer_note_id){
    products_to_send_fix = filterBeforeLoadToDeliveryOrder(transfer_notes_details);
    // console.log(products_to_add_fix);

    const response = await fetch(`http://${$uri}:8888/orders/delivery/add/${transfer_note_id}`, {
      method: 'POST',
      body: JSON.stringify(products_to_send_fix)
    });

    if (!response.ok) {
      console.error('POST add delivery order details gagal', response);
      return;
    }

    const data = await response.json();

    if (data.status !== 200) {
      console.error('Invalid post add delivery order details', data);
      return;
    }
    // console.log("insert delivery order detail",data);

    const add_products_details = String(data.data[0].delivery_order_id);
    // console.log(add_products_details);
    // console.log(delivery_order_supplier, supplier_id);
    const updateUrl = `http://${$uri}:8888/orders/delivery/update/${add_products_details}`;
    // console.log('Update URL:', updateUrl);

    const response2 = await fetch(updateUrl, {
      method: 'PUT',
      body: JSON.stringify({
        user_id_from: Number($userId),
        notes: notes,
      }),
      headers: {
        'Content-Type': 'application/json'
      }
    });

    if (!response2.ok) {
      console.error('PUT add delivery order details failed', response2);
    }

    const data2 = await response2.json();

    if (data2.status !== 200) {
      console.error('Invalid put add delivery order details', data2);
    }

    // console.log("Updated add delivery order details", data2);
    notes = '';
    transfer_notes_details = [];
    closeModal();
    // goto(`/products`);
  }
  function filterBeforeLoadToDeliveryOrder(products){
    return products.map(product => ({
        product_detail_id: product.product_detail_id,
        quantity: product.quantity_to_send,
        expired_date: product.expired_date,
        batch: product.batch
    }));
  }
  function toggleModalView(transfer_note_id){
    viewDeliveryOrders = !viewDeliveryOrders;
    if (!viewDeliveryOrders) {
      fetchTransferNotesDetails(transfer_note_id);
    }
  }
  function handleClick(transfer_note_id) {
      showModal = transfer_note_id;
      fetchDeliveryOrder(transfer_note_id);
      checkProductLeft(transfer_note_id);
      console.log(transfer_note_id)
  }
  function checkProductLeft(transfer_note_id){
    const transferNote = transfer_notes.find(note => note.transfer_note_id === transfer_note_id);
    productLeft = delivery_orders.quantity_total === transferNote.quantity_total;
  }
  function closeModal() {
    showModal = null;
    delivery_orders = [];
    viewDeliveryOrders = true;
  }
  function toggleDeliveryOrderByID(delivery_order, id) {
    // if (!showSuratJalan)
    if (showSuratJalan && idSuratJalan === id) {
        // If the same ID is clicked, toggle off the display
        showSuratJalan = false;
        delivery_order_details = [];
        from = [];
        to = [];
        idSuratJalan = 0;
    } else {
        // If a different ID is clicked or currently closed, open the new delivery order
        showSuratJalan = true;
        idSuratJalan = id;
        fetchDeliveryOrderDetails(delivery_order.delivery_order_id);
        fetchStoreWarehouseFrom(delivery_order.store_warehouse_from);
        fetchStoreWarehouseTo(delivery_order.store_warehouse_to);
    }
  }
  async function fetchDeliveryOrderDetails(delivery_order_id) {
      const response = await fetch(`http://${$uri}:8888/orders/delivery/detail/${delivery_order_id}`, {
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

      delivery_order_details = [...data.data];  
  }
  async function fetchStoreWarehouseFrom(store_warehouse_id) {
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
      
      from = data.data;  
      console.log(from);
  }
  async function fetchStoreWarehouseTo(store_warehouse_id) {
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
      
      to = data.data;  
      console.log(to);
  }
  async function fetchDeliveryOrder(transfer_note_id) {
      const response = await fetch(`http://${$uri}:8888/orders/delivery/transfernote/${transfer_note_id}`, {
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

      delivery_orders = [...data.data];  
      console.log(delivery_orders);
  }
  onMount(async () => {
      await fetchTransferNotes();
  });
  async function fetchTransferNotes() {
      const response = await fetch(`http://${$uri}:8888/orders/transfer/notes/all/${limit}/${offset}`, {
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

      tf_notes = [...data.data];  
      transfer_notes = [...tf_notes];
      console.log(transfer_notes);
  }
  $: if (searchQuery.length > 0) {
      transfer_notes = tf_notes.filter(item => 
        item.transfer_note_id.toLowerCase().includes(searchQuery)
          // product.ProductDetails.product_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
          // product.ProductDetails.product_detail_id.toString().includes(searchQuery)
      );
  } else {
      transfer_notes = [...tf_notes];
  }
   async function fetchTransferNotesDetails(transfer_note_id) {
      const response = await fetch(`http://${$uri}:8888/orders/transfer/notes/detail/${transfer_note_id}`, {
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

      tf_notes_details = [...data.data];
      tf_notes_details = await filterTransferNotesWithDeliveryOrder(tf_notes_details, delivery_orders);
      transfer_notes_details = [...tf_notes_details];
      console.log(transfer_notes_details);
  }
  function deleteProductFromList(product_detail_id) {
    transfer_notes_details = transfer_notes_details.filter(note => note.product_detail_id !== product_detail_id);
  }
  async function filterTransferNotesWithDeliveryOrder(transfer_notes_details, delivery_orders) {
    // Create an object to store the total quantity sent for each product_detail_id
    const sentQuantities = {};

    // Loop through each delivery order to accumulate sent quantities
    // for (const delivery_order of delivery_orders) {
    //     const delivery_order_id = delivery_order.delivery_order_id;
    //     const delivery_order_details_baru = await fetchDeliveryOrderDetails(delivery_order_id);
    //     console.log(delivery_order_details_baru);

    //     // Loop through each delivery order detail to update the sent quantities
    //     for (const detail of delivery_order_details_baru) {
    //         const product_detail_id = detail.product_detail_id;
    //         const quantity_sent = detail.quantity;

    //         if (sentQuantities[product_detail_id]) {
    //             sentQuantities[product_detail_id] += quantity_sent;
    //         } else {
    //             sentQuantities[product_detail_id] = quantity_sent;
    //         }
    //     }
    // }

    // Filter the transfer notes details to keep only those that haven't been fully sent
    const filteredTransferNotesDetails = transfer_notes_details.map(note => {
        const product_detail_id = note.product_detail_id;
        const remainingQuantity = note.remaining_quantity;

        // Calculate the quantity left to be sent
        const quantity_to_send = remainingQuantity;

        // Add the quantity_to_send column to each note
        return {
            ...note,
            quantity_to_send: Math.max(quantity_to_send, 0)  // Ensure the quantity is not negative
        };
    }).filter(note => note.quantity_to_send > 0);  // Filter out notes that are fully sent


    return filteredTransferNotesDetails;
  }
  async function goToPage(page) {
    if (page < 1 || page > Math.ceil(totalNotes / limit)) return;

    currentPage = page;
    offset = (currentPage - 1) * limit;
    await fetchTransferNotes();
  }
</script>

 
 <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Stock Transfer Notes</span>
    
    <!-- <form class="flex items-center max-w-lg mx-auto">    -->
       <label for="voice-search" class="sr-only">Search</label>
       <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
          <input 
          bind:value={searchQuery} 
          on:keydown={(event) => handleSearch(event)} 
          type="text" id="voice-search" 
          class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
          placeholder="Search detail transfer notes..."/>
          <button 
                type="button" class="absolute inset-y-0 end-0 flex items-center pe-3 mr-1">
            <!-- <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
              </svg> -->
              <i class="fa-solid fa-sliders fa-xl mr-2"></i>
          </button>
       </div>
    <!-- </form> -->
 
    <nav class="my-8">
      <ul class="flex items-center -space-x-px h-8 text-sm">
        <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
            <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
            </svg>
            Previous
          </a>
        </li>
    
        <!-- Pagination Links -->
        {#each Array(Math.ceil(totalNotes / limit)) as _, i}
          <li>
            <a href="#" on:click|preventDefault={() => goToPage(i + 1)} class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">{i + 1}</a>
          </li>
        {/each}
    
        <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
            Next
            <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
            </svg>
          </a>
        </li>
      </ul>
    </nav>
 
    <div class="w-[96%] my-5 font-roboto">
      <div class="relative overflow-x-auto rounded-lg">
        {#each transfer_notes as note}
        <div class="flex border-2 rounded-xl ml-auto border-gray-700 m-3">                        
          <div class=" w-1/12 flex justify-center items-center">
            <!-- <i class="fa-regular fa-file-lines fa-xl"></i> -->
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-10">
              <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
            </svg>
            
          </div>
          <div class="py-4 w-9/12">
              <div class="font-bold whitespace-nowrap">
                Stock Transfer Note #{note.transfer_note_id}
              </div>
              <div class="font-semibold">
                <DateConverter value={note.created_at} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={true} dateFirst={true}/>
              </div>
              <div class="flex font-semibold gap-1">
                {#if note.status_verify === 0}
                  <div class="">
                    Not Verified, 
                  </div>
                {:else}
                  <div class="text-[#f2b082]">
                    Verified, 
                  </div>
                {/if}
                {#if note.status_send === 0}
                  <div class="">
                    Not Sent.
                  </div>
                {:else}
                  <div class="text-[#f2b082]">
                    Sent. 
                  </div>
                {/if}
              </div>

          </div>
          <div class="font-semibold w-2/12">
            <div class="flex justify-center">
              <!-- Stock: {product.ProductDetails.product_detail} {product.ProductDetails.product_unit} -->
            </div>
            <button 
            on:click={() => handleClick(note.transfer_note_id)}
            type="button" 
            class="flex items-center rounded-r-lg justify-center py-2 w-full h-full px-4 font-bold bg-[#3d4c52] text-[#f2b082] hover:bg-darkGray ">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.75" stroke="currentColor" class="size-10">
                <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
              </svg>
            
            </button>
          </div>
      </div>
        {/each}
      </div>
    </div>

    <nav class="my-8">
      <ul class="flex items-center -space-x-px h-8 text-sm">
        <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
            <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
            </svg>
            Previous
          </a>
        </li>
    
        <!-- Pagination Links -->
        {#each Array(Math.ceil(totalNotes / limit)) as _, i}
          <li>
            <a href="#" on:click|preventDefault={() => goToPage(i + 1)} class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">{i + 1}</a>
          </li>
        {/each}
    
        <li>
          <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
            Next
            <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
            </svg>
          </a>
        </li>
      </ul>
    </nav>
     
 </div>

{#each transfer_notes as note} 
  {#if showModal === note.transfer_note_id}
    <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
      {#if viewDeliveryOrders}
      <div class="flex items-center justify-center pt-8">
        <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Stock Transfer Note Detail</div>
      </div>
      <form class=" mt-8 p-4 md:p-5">
          <div class="grid gap-3 font-roboto font-semibold">
            <div class="">
                <div class="text-[#f7d4b2]">Stock Transfer Note ID</div>
                <div class="text-white">{note.transfer_note_id}</div>
            </div>
            <div class="">
              <div class="text-[#f7d4b2]">Created at</div>
              <div class="text-white">
                <DateConverter value={note.created_at} date={true} hour={true} second={false} ampm={true} monthNumber={false} dash={false} dateFirst={false}/>
              </div>
            </div>


            <div class="">
              <div class="text-[#f7d4b2]">Delivery Order</div>
              {#if delivery_orders.length > 0}
                {#each delivery_orders as delivery_order}
                <div class="flex mx-auto items-center rounded-lg bg-white text-black my-2">
                  <div class="w-10/12 flex mx-auto justify-start ml-4">
                    <div class="w-4/12">#{delivery_order.delivery_order_id}</div>
                    <div class="w-4/12">
                      <DateConverter value={delivery_order.order_timestamp} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                    </div>
                    <div class="w-4/12">{delivery_order.quantity_total} loaded</div>
                  </div>
                  <div class="w-2/12 flex justify-end mr-4">
                    <button on:click={() => toggleDeliveryOrderByID(delivery_order, delivery_order.delivery_order_id)} type="button" 
                      class="my-2 flex items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:shadow-[0_2px_3px_rgba(0,0,0,0.5)] hover:bg-[#F2AA7E] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg outline outline-[1px] px-3 py-3 text-center">
                      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="size-6">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                        <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                      </svg>
                    </button>
                  </div>
                </div>
                {#if showSuratJalan && idSuratJalan === delivery_order.delivery_order_id}
                  <div class="mt-2 flex w-full mx-auto items-center rounded-lg bg-white text-black">
                    <div class="printable-section text-xs m-4 outline w-full outline-[1px] rounded p-4 ">
                      <div class="font-medium">
                        SURAT JALAN
                      </div>
                      <hr class="w-full border-t-[0.5px] my-2 border-black "/>
                      <div class="flex justify-between">
                        <div class="w-4/12 text-4xl items-center">
                          <div>LOGO</div>
                        </div>
                        <div class="w-6/12 items-start">
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
                            <div>Penerima:</div>
                            <div class="mt-12">(...............................)</div>
                          </div>
                          <div class="">
                            <div>Pengirim:</div>
                            <div class="mt-12">(...............................)</div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="flex items-center justify-start">
                    <button type="button" on:click={() => window.print()} class="mt-2 flex w-40 items-center justify-start text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-md py-1.5 text-center">
                      <div class="w-2/12 flex justify-center ml-2">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-6">
                          <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096m-.72-.096L17.66 18m0 0 .229 2.523a1.125 1.125 0 0 1-1.12 1.227H7.231c-.662 0-1.18-.568-1.12-1.227L6.34 18m11.318 0h1.091A2.25 2.25 0 0 0 21 15.75V9.456c0-1.081-.768-2.015-1.837-2.175a48.055 48.055 0 0 0-1.913-.247M6.34 18H5.25A2.25 2.25 0 0 1 3 15.75V9.456c0-1.081.768-2.015 1.837-2.175a48.041 48.041 0 0 1 1.913-.247m10.5 0a48.536 48.536 0 0 0-10.5 0m10.5 0V3.375c0-.621-.504-1.125-1.125-1.125h-8.25c-.621 0-1.125.504-1.125 1.125v3.659M18 10.5h.008v.008H18V10.5Zm-3 0h.008v.008H15V10.5Z" />
                        </svg>
                      </div>
                      <div class="w-10/12 text-start ml-2">
                        Print detail card
                      </div>
                    </button>
                  </div>
                  <div class="text-[#f7d4b2] my-4">
                    <div class="pb-3">Additional notes</div>
                    <input  bind:value={notes}
                    class="min-h-24	shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5"/>                    
                  </div>
                {/if}
                {/each}
              {/if}
              <div class="flex items-center justify-start">
                <button type="button" on:click={() => toggleModalView(note.transfer_note_id)} class="mt-2 flex w-2/4 items-center justify-start text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-md py-1.5 text-center"
                  disabled={note.status_verify == 0}>
                  <div class="w-2/12 flex justify-center">
                    <i class="fa-solid fa-plus"></i>
                  </div>
                  <div class="w-10/12 text-start">
                    Create delivery order
                  </div>
                </button>
                {#if productLeft}
                <div>
                  WARNING:  product(s) not loaded.
                </div>
                {/if}
              </div>
            </div>
           
            <div class="flex items-center justify-center">
                <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                  Close
                </button>
            </div>
          </div>
      </form>
      {:else}
        <div class="flex items-center justify-center pt-8">
          <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Create Delivery Order</div>
        </div>
        <form class=" mt-8 p-4 md:p-5">
            <div class="grid gap-3 font-roboto font-semibold">
              <div class="">
                <div class="text-[#f7d4b2]">Products Loaded</div>
                <div class="p-2 flex w-full items-center rounded-lg bg-white text-black">
                  <table class="w-full text-sm text-left rtl:text-right">
                    <thead class="text-sm text-gray-700 uppercase bg-white">
                      <tr class="border-b-2 border-black">
                          <th scope="col" class="px-3 py-2 text-center">No</th>
                          <th scope="col" class="px-1 py-2">Product Name</th>
                          <th scope="col" class="px-1 py-2">Requested</th>
                          <th scope="col" class="px-1 py-2">Loaded</th>
                          <th scope="col" class="px-1 py-2">Unit Type</th>
                          <th scope="col" class="px-1 py-2">Batch</th>
                          <th scope="col" class="px-1 py-2">Expiry Date</th>
                          <th scope="col" class="px-1 py-2">Action</th>
                        </tr>
                      </thead>
                      <tbody class="text-sm">
                        {#each transfer_notes_details as detail, i}
                        <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                          <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                            {i+1}
                            </th>
                            <td class="px-1 py-2">{detail.product_name}</td>
                            <td class="px-1 py-2">{detail.remaining_quantity}</td>
                            <td>
                              <input type="number" required
                                bind:value={detail.quantity_to_send} min={0} max={detail.remaining_quantity}
                                class="focus:ring-2 h-8 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full px-4 py-2 text-xs leading-6 text-slate-900 rounded-lg">
                            </td>
                            <td class="px-1 py-2">{detail.unit_type}</td>
                            <td class="px-1 py-2">{detail.batch}</td>
                            <td class="px-1 py-2">
                              <DateConverter value={detail.expired_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                            </td>
                            <td class="px-1 py-2 text-center">
                              <button on:click={() => deleteProductFromList(detail.product_detail_id)} type="button" 
                                class="flex items-center justify-center text-black hover:text-[#3d4c52] font-semibold text-lg rounded-lg px-3 py-2 text-center">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
                                  <path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0" />
                                </svg>
                              </button>
                            </td>
                          </tr>
                        {/each}
                      </tbody>
                  </table>
                </div>
                <div class="text-[#f7d4b2] mt-4">
                  <div class="pb-3">Additional notes</div>
                  <input bind:value={notes} class="min-h-24	shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " />                    
                </div>
                <div class="flex items-center justify-start">
                  <button type="button" on:click={() => resetLoad()} class="mt-2 flex w-1/5 items-center justify-start text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-md py-1.5 text-center">
                    <div class="w-5/12 flex justify-center">
                      <i class="fa-solid fa-repeat"></i>
                    </div>
                    <div class="w-7/12 text-start text-lg">
                      Reset
                    </div>
                  </button>
                </div>
              </div>
            
              <div class="flex items-center justify-center gap-8">
                <button type="button" on:click={() => toggleModalView(note.transfer_note_id)} class="mt-2 flex w-1/3 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline outline-[1px] hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-xl px-4 py-1.5 text-center">
                  Back
                </button>
                <button type="button" on:click={() => saveLoad(note.transfer_note_id)} class="mt-2 flex w-1/3 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-xl px-4 py-1.5 text-center">
                    Confirm
                </button>
              </div>
            </div>
        </form>
      {/if}
  </TaskModal> 
  {/if}
{/each}