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
    let delivery_order_id = data.delivery_order_id;
    let showModal = null;

    $: do_details = [];
    $: sw_id_from = '';
    $: sw_id_to = '';
    $: sw_id_from_address = '';
    $: sw_id_to_address = '';

    function closeModal() {
      showModal = null;
    }
    function backToStores(){
      goto(`/manage_stores/${store_warehouse_id}`);
    }

    async function fetchDeliveryOrderDetails() {
        const response = await fetch(`http://${$uri}:8888/orders/delivery/detail/${delivery_order_id}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all do details fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch do details', data);
            return;
        }  

        do_details = data.data
        console.log("do details", do_details);
    }
    async function fetchDeliveryOrder() {
        const response = await fetch(`http://${$uri}:8888/orders/delivery/${delivery_order_id}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get do fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch do', data);
            return;
        }
 
        // console.log("do", data.data);
        let tmp_sw_id_from = await getStoreWarehouse(data.data.store_warehouse_from);
        sw_id_from = tmp_sw_id_from.store_warehouse_name;
        sw_id_from_address = tmp_sw_id_from.store_warehouse_address;
        
        let tmp_sw_id_to = await getStoreWarehouse(data.data.store_warehouse_to);
        sw_id_to = tmp_sw_id_to.store_warehouse_name;
        sw_id_to_address = tmp_sw_id_to.store_warehouse_address;
        // console.log("from", sw_id_from, " to ", sw_id_to);
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

    async function verifyDeliveryOrder() {
        const response = await fetch(`http://${$uri}:8888/orders/delivery/verify/${delivery_order_id}`, {
            method: 'PUT',
            headers: {
                    'Content-Type': 'application/json',
                },
        });

        if (!response.ok) {
            console.error('PUT verify do gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid put do session', data);
            return;
        }
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

    onMount(async () => {
        await fetchDeliveryOrder();
        await fetchDeliveryOrderDetails();
    });
   
  </script>

  <div class="mt-[90px] mx-8 mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={backToStores} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-4">Verify Delivery Order</span>       
    <div class="w-11/12 overflow-x-auto">
      <div class="flex flex-col my-4">
        <div class="my-2 flex flex-col">
          <span class="text-xl font-bold mb-1">Origin</span>
          <span class="text-xl">{sw_id_from}, {sw_id_from_address}</span>
        </div>
        <div class="my-2 flex flex-col">
          <span class="text-xl font-bold mb-1">Destination</span>
          <span class="text-xl">{sw_id_to}, {sw_id_to_address}</span>
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
                  Quantity
              </th>
              <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                  Actual Quantity
              </th>
              <th scope="col" class="px-1 py-2 text-center text-sm font-bold uppercase text-center">
                Unit Type
              </th>
            </tr>
          </thead>
          <tbody>
            
            {#each do_details as produk, i}
            <!-- <div class="hidden">{last_id = i}</div> -->
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
                    {produk.quantity}
                </td>
                <td class="px-1 py-2 text-center">
                    {produk.actual_quantity}
                </td>
                <td class="px-1 py-2 text-center">
                  <span class="my-1">{produk.unit_type}</span>
                </td>
              </tr>
              
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
                              <button type="button" on:click={async() => {await verifyDeliveryOrder(); 
                              
                              let description = "User ID "+$userId+" melakukan verify pada delivery order dengan ID "+ delivery_order_id;
                              //22 Verify delivery orders
                              await insertNotif(description,22)
                              
                              Swal.fire({
                                title: "Delivery Order Berhasil Diverify",
                                icon: "success",
                                color: "white",
                                background: "#364445",
                                confirmButtonColor: '#F2AA7E'
                              }); closeModal(); backToStores();}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                                Verify
                              </button>
                          </div>
                    </form>
                </TaskModal> 
              {/if}
              
              {/each}
          </tbody>
        </table>
      </div>


    <div class="flex justify-center mb-10 mt-10">
        <button on:click={() => {showModal = "confirm_verify"; showModal = showModal;}} class="mx-6 w-48 bg-peach2 text-darkGray border border-darkGray shadow py-3 rounded-2xl font-semibold text-xl">Verify</button>
    </div>
</div>


  
  
