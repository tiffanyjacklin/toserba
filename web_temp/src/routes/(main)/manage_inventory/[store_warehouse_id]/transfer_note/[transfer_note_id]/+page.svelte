<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import receipt from '$lib/assets/receipt-1.png';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri } from '$lib/uri.js';

    export let data;
    let store_warehouse_id = data.store_warehouse_id;
    let transfer_note_id = data.transfer_note_id;
    let showModal = false;
    function closeModal() {
      showModal = false;
    }
    function handleClick() {
      showModal = true;
    }
    function backToAddStock(){
      goto(`/manage_inventory/${store_warehouse_id}`);
    }

    let tf_details = [];
    let ori_tf_details = [];

    $: edit_id = 0;
    $: isSame = true;

    async function getTransferNotetDetails() {
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
 
        // let tmp = data.data;

        // for (let i = 0; i < tmp.length; i++) {
        //     let ProductDetails = await getProductDetail(tmp[i].product_detail_id);
        //     tmp[i].product_name = ProductDetails.product_name;
        //     tmp[i].product_unit = ProductDetails.product_unit;
        // }

        // add_stock_details = tmp;
        // ori_add_stock_details = structuredClone(tmp);

        tf_details = data.data;
        ori_tf_details = structuredClone(tf_details);

        console.log("tf_details", tf_details);
    }

    // async function verifyAddStock(add_stock_id,status) {
    //     const response = await fetch(`http://${$uri}:8888/orders/supplier/verify/${add_stock_id}/${status}`, {
    //         method: 'PUT',
    //         headers: {
    //                 'Content-Type': 'application/json',
    //             },
    //         // body: JSON.stringify({
    //         //     actual_closing_cash,
    //         //     deposit_money
    //         // })
    //     });

    //     if (!response.ok) {
    //         console.error('PUT verify session gagal', response);
    //         return;
    //     }

    //     const data = await response.json();

    //     if (data.status !== 200) {
    //         console.error('Invalid put verify session', data);
    //         return;
    //     }
    //     // console.log("verify session :",data);
    //   }

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
    
    async function deleteTFDetails(product_detail_id) {
      const response = await fetch(`http://${$uri}:8888/orders/transfer/detail/delete/product/${transfer_note_id}/${product_detail_id}`, {
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
      for (let i = 0; i < tf_details.length; i++) {
            if (tf_details[i].quantity != ori_tf_details[i].quantity){
              updateTFdetails(tf_details[i].product_detail_id, tf_details[i].quantity)
            }
        }
        ori_tf_details = structuredClone(tf_details);
        isSameWithOri();
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
      await getTransferNotetDetails();
    });
   
  </script>

  <div class="mt-[90px] mx-8 mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={backToAddStock} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Assign Product</span>       
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
                  Batch
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
              <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                <th scope="row" class="px-3 py-2  text-center font-medium text-gray-900 whitespace-nowrap">
                      {i+1}
                </th>
                <td class="px-1 py-2 text-center">
                  <span class="my-1">{produk.product_name}</span>
                </td>
                <td class="px-1 py-2 text-center">
                  {produk.batch}
                </td>
                <td class="px-1 py-2 text-center">
                  {produk.remaining_quantity}
                </td>
                <td class="px-1 py-2 text-center">
                  {#if edit_id == produk.transfer_note_detail_id}
                    <input bind:value={produk.quantity} class="w-36 rounded-lg [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none" type="number">    
                  {:else}
                    {produk.quantity}
                  {/if}
                </td>
                <td class="px-1 py-2 text-center">
                  <span class="my-1">{produk.unit_type}</span>
                </td>
                <td class="px-1 py-2 text-center flex items-center justify-center">
                  <button on:click={async() => {
                    await deleteTFDetails(produk.product_detail_id); tf_details = []; await getTransferNotetDetails();}} class="w-8 mx-1 p-1 bg-peach2 rounded-xl border border-darkGray">
                    <i class="fa-solid fa-trash-can"></i>                     
                  </button>
                  {#if edit_id == produk.transfer_note_detail_id}
                    <button on:click={() => {edit_id = 0; isSameWithOri();
                        if (produk.quantity > produk.remaining_quantity){
                            produk.quantity = produk.remaining_quantity;
                        } else if (produk.quantity == 0){
                            produk.quantity = 1;
                        }
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

              <!-- {#if showModal == "confirm_verify" }
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
                              <button type="button" on:click={async() => {await verifyAddStock(add_stock_id,1); Swal.fire({
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
              {/if} -->
              
              <!-- {#if showModal == "confirm_reject" }
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
                              <button type="button" on:click={async() => {await verifyAddStock(add_stock_id,2); Swal.fire({
                                title: "Add Stock Berhasil Direject",
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
              {/if} -->

              {/each}
          </tbody>
        </table>

        
        {#if tf_details.length > 0}
          <div class="flex justify-end mt-2 mb-10">
            <button on:click={() => {tf_details = structuredClone(ori_tf_details); tf_details = tf_details; isSameWithOri()}} class="mx-2 w-48 bg-darkGray text-peach border border-darkGray shadow py-1 rounded-2xl font-semibold text-xl">Reset</button>
            {#if !isSame}
              <button on:click={async() => {await applyChanges();}} class="mx-2 w-48 bg-peach text-darkGray border border-darkGray shadow py-1 rounded-2xl font-semibold text-xl">Apply Changes</button>
            {/if}
            <button class="mx-2 w-48 bg-peach2 text-darkGray border border-darkGray shadow py-1 rounded-2xl font-semibold text-xl"><i class="fa-solid fa-plus mr-1"></i>Add Product</button>
            </div>
          <div class="flex justify-center mb-10">
            <button on:click={() => {showModal = "confirm_reject"; showModal = showModal;}} class="mx-6 w-48 bg-darkGray text-peach border border-darkGray shadow py-3 rounded-2xl font-semibold text-xl">Reject</button>
            <button on:click={() => {showModal = "confirm_verify"; showModal = showModal;}} class="mx-6 w-48 bg-peach2 text-darkGray border border-darkGray shadow py-3 rounded-2xl font-semibold text-xl">Verify</button>
          </div>
        {/if}
      </div>
</div>


  
  
