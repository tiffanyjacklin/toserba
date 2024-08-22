<script>
    import SessionHistory from "$lib/SessionHistory.svelte";
    import TransactionHistory from "$lib/TransactionHistory.svelte"
    import TransactionHistoryDetails from "$lib/TransactionHistoryDetails.svelte"
    import ProdukMain from "$lib/ProdukMain.svelte"
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { getFormattedDate } from '$lib/DateNow.js';
    import { onMount } from 'svelte';
    import img_produk from "$lib/assets/produk.png";
    import { goto } from '$app/navigation';
    export let data;
    let sessionId = data.sessionId;
    let roleId = data.roleId;
    let userId = data.userId;

    // CLOSE SESSION
    let showTable = false;
    let showModal = null; 
    let session = [];
    
    function handleClick(id) {
        showModal = id;
    }
    function toggleTable() {
        showTable = !showTable;
    }
    function closeModal() {
        showModal = null;
    }
    
    let this_session = {"session_id":1,"user_id":1,"start_time":"2015-09-02 08:04:00","end_time":"0000-00-00 00:00:00","last_update_time":"0000-00-00 00:00:00","opening_cash":20000,"total_income":100000,"expected_closing_cash":120000,"actual_closing_cash":100000,"actual_difference":20000,"deposit_money":0,"deposit_difference":0,"opening_notes":"","closing_notes":"Finished"};
    
    async function thisSession(){
        const response = await fetch(`http://leap.crossnet.co.id:8888/cashier/session/${sessionId}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('last session fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch last', data);
            return;
        }

        this_session = data.data;
        this_session.last_update_time = getFormattedDate();
        console.log(this_session);
    }

    $: {
        this_session.actual_difference = this_session.actual_closing_cash - this_session.expected_closing_cash;
        this_session.deposit_difference = this_session.actual_closing_cash - this_session.deposit_money;
    }

    async function CloseSession(session_id, this_session) {
        try {
            const response = await fetch(`http://leap.crossnet.co.id:8888/cashier/session/close/${session_id}`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    "end_time": this_session.last_update_time, 
                    "expected_closing_cash": this_session.expected_closing_cash,
                    "actual_closing_cash": this_session.actual_closing_cash,
                    "actual_difference": this_session.actual_difference,
                    "deposit_money": this_session.deposit_money,
                    "deposit_difference": this_session.deposit_difference,
                    "closing_notes": this_session.closing_notes,
                })
            });
            if (!response.ok) {
                const errorDetails = await response.text();
                console.error('CloseSession failed:', response.status, response.statusText, errorDetails);
                Swal.fire({
                    title: "Error",
                    text: `CloseSession failed: ${response.statusText}`,
                    icon: "error",
                    confirmButtonColor: '#F2AA7E'
                });
                return;
            }

            console.log('Session closed successfully');

            closeModal();
            goto(`/session_history/${userId}/${roleId}`);

        } catch (error) {
            console.error('Request failed:', error);
            Swal.fire({
                title: "Error",
                text: `Request failed: ${error.message}`,
                icon: "error",
                confirmButtonColor: '#F2AA7E'
            });
        }
    }

    // VIEW ALL PROMO
    let all_promo = [];
    async function fetchAllPromo(){
        const response = await fetch(`http://leap.crossnet.co.id:8888/promos`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch promo failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch promo', data);
            return;
        }

        all_promo = data.data;
        // console.log(all_promo[0]["Promo"]);
    }

    // GATAU ALEX

    let all_produk = [];
    let products = [];
    let checkout = [];
    let promos = [];
    $: total = 0;
    $: count_promo_app = 0;

    function checkPromo(){
        for (let i = 0; i < checkout.length; i++) {
            // cek apakah produk promo pada checkout
            let produk_promo = all_promo.find((produk) => produk["ProductDetail"].product_detail_id == checkout[i].product_detail_id);
            // jika ada, di cek apakah udh ada di array promos atau blm, klo blm baru di push
            if (produk_promo != null){
                if (promos.find((produk) => produk["ProductDetail"].product_detail_id == produk_promo["ProductDetail"].product_detail_id) != null){
                    // console.log("produk promo udh ada di promos")
                } else {
                    produk_promo.promo_applied = checkout[i].promo_applied;
                    promos.push(produk_promo);
                    promos = promos;
                }
            }
        }
        console.log("promos",promos);
    }

    function promoType2_3(produk_checkout){

        // cek apakah produk_checkout ada di array all promo
        if (all_promo.find((produk) => produk["ProductDetail"].product_detail_id == produk_checkout.product_detail_id) != null){
            // jika ada, ambil index di array all promo
            let index = all_promo.findIndex(produk_p => produk_p["ProductDetail"].product_detail_id == produk_checkout.product_detail_id);

            // type 2 discount
            if (all_promo[index]["Promo"].promo_type_id == 2){
                produk_checkout.sell_price = produk_checkout.sell_price - (produk_checkout.sell_price*(all_promo[index]["Promo"].promo_percentage)/100)
                produk_checkout.sell_price = produk_checkout.sell_price
                produk_checkout.promo_applied = true;
            } else if (all_promo[index]["Promo"].promo_type_id == 3){
                produk_checkout.sell_price = produk_checkout.sell_price - (all_promo[index]["Promo"].promo_discount)
                produk_checkout.sell_price = produk_checkout.sell_price
                produk_checkout.promo_applied = true;
            } else {
                produk_checkout.promo_applied = false;
            }
        }
        return produk_checkout;
    }
    
    function countPromoApplied(){
        let count = 0;
        for (let i = 0; i < promos.length; i++) {
            if (promos[i].promo_applied == true){
                count += 1
            }
        }
        count_promo_app = count;
        count_promo_app = count_promo_app;
    }

    function checkPromoAppliedType1(){
        for (let i = 0; i < checkout.length; i++) {
            if (promos.find((produk) => produk["ProductDetail"].product_detail_id == checkout[i].product_detail_id) != null){
                // jika ada, ambil index di array all promo
                let index = promos.findIndex(produk_p => produk_p["ProductDetail"].product_detail_id == checkout[i].product_detail_id);

                if (checkout[i].jumlah >= promos[index]["Promo"].x_amount){
                    checkout[i].promo_applied = true;
                    checkout[i].promo_applied = checkout[i].promo_applied;

                    promos[index].promo_applied = true;
                    promos[index].promo_applied = promos[index].promo_applied;
                } else {
                    checkout[i].promo_applied = false;
                    checkout[i].promo_applied = checkout[i].promo_applied;

                    promos[index].promo_applied = false;
                    promos[index].promo_applied = promos[index].promo_applied;
                }
            }
        }
    }

    function sumTotal(){
        total = checkout.reduce((sum, item) => {
        return sum + (item.sell_price * item.jumlah);
        }, 0);
        total = total
        // console.log(total); 
    }

    async function fetchProduk() {
        const response = await fetch(`http://leap.crossnet.co.id:8888/products/${userId}/${roleId}`, {
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

        products = data.data;
        all_produk = products;
    }
    let searchQuery = '';

    $: if (searchQuery.length > 0) {
        all_produk = products.filter(item => 
        item.product_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.product_detail_id.toString().includes(searchQuery)
        );
    } else {
        all_produk = products; 
    }

    onMount(async () => {
        await fetchProduk();
        await thisSession();
        await fetchAllPromo();

    });

    let window = "payment";

    function addtoCheckout(produk){
        if (checkout.find(({ product_name }) => product_name === produk.product_name) != null){
            let index = checkout.findIndex(produk_c => produk_c.product_name == produk.product_name);
            checkout[index].jumlah+=1;
        } else{
            promoType2_3(produk);
            produk.jumlah = 1;
            checkout.push(produk)
        }
        all_produk = all_produk;
        checkout = checkout;
        console.log("checkout : ", checkout);
    }


</script>

<style>
    /* Hide scrollbar for Chrome, Safari and Opera */
    .no-scrollbar::-webkit-scrollbar {
        display: none;
    }

    /* Hide scrollbar for IE, Edge and Firefox */
    .no-scrollbar {
        -ms-overflow-style: none;  /* IE and Edge */
        scrollbar-width: none;  /* Firefox */
    }
</style>

<div class="flex h-screen">
    <div class="w-7/12 bg-gray-100 flex flex-col">
        <div class="h-auto text-darkGray text-lg font-semibold my-2 mx-6">
            <button class="mx-3 hover:bg-gray-300 p-2 rounded-lg"
            on:click={() => handleClick(1)}>
            <i class="fa-solid fa-arrow-right-from-bracket mr-1"></i>Close Session</button>
            <button on:click={() => window = "session_history"} class="mx-3 hover:bg-gray-300 p-2 rounded-lg"><i class="fa-regular fa-clock mr-1"></i>Session History</button>
        </div>
        <div class="h-auto overflow-auto no-scrollbar">
            {#if window == "transaction_list"}
              <TransactionHistory userId={userId} roleId={roleId} sessionId={sessionId}></TransactionHistory>

            <!-- <TransactionHistory></TransactionHistory> -->
            <!-- <TransactionHistoryDetails></TransactionHistoryDetails> -->
            {:else if window == "session_history"}
                <!-- <SessionHistory ></SessionHistory>             -->
                <SessionHistory sessionId={sessionId} userId={data.userId} roleId={data.roleId}></SessionHistory>
                <!-- <SessionHistory session={this_session} userId={userId} roleId={roleId}></SessionHistory>             -->
            {:else if window == "payment"}
                <div class="mx-8 flex flex-col items-center my-10">
                    <label for="voice-search" class="sr-only">Search</label>
                    <div class="relative w-11/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg">
                       <input 
                        bind:value={searchQuery}
                        type="text" id="voice-search" class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " placeholder="Search..."/>
                       <button type="button" class="absolute inset-y-0 end-0 flex items-center pe-3">
                          <svg class="size-7" viewBox="0 0 66 59" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
                             <rect x="0.625" width="64.8125" height="59" fill="url(#pattern0_371_473)"/>
                             <defs>
                             <pattern id="pattern0_371_473" patternContentUnits="objectBoundingBox" width="1" height="1">
                             <use xlink:href="#image0_371_473" transform="matrix(0.000625 0 0 0.000686573 0 -0.0492585)"/>
                             </pattern>
                             <image id="image0_371_473" width="1600" height="1600" xlink:href="data:image/png;base64,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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAANh7X84BTjNoBUCnAAAAAElFTkSuQmCC"/>
                             </defs>
                             </svg>
                       </button>
                    </div>
                    
                    <div class="grid grid-cols-3 gap-4 mt-6 mx-8">
                        {#each all_produk as produk}
                            {@const tmp_produk = {...produk}}
                        <button on:click={() => {addtoCheckout(tmp_produk); sumTotal(); checkPromo(); checkPromoAppliedType1(); countPromoApplied();}} class="w-full border-2 border-black rounded-lg bg-white">
                            <div class="p-3 w-full flex flex-col items-center">
                                <img class="rounded-lg w-10/12 h-10/12" src={img_produk} alt="">
                                <p class="w-full truncate text-black font-semibold my-1 text-center">{produk.product_name}</p>
                                <p class="truncate text-peach2 font-semibold mb-1"><MoneyConverter value={produk.sell_price} currency={true} decimal={true}></MoneyConverter></p>
                                <p class="truncate text-black font-semibold mb-1">{produk.product_stock} {produk.product_unit}</p>
                            </div>
                        </button>
                    {/each}
                
                    </div>
                </div>
            {/if}            
        
        </div>
        
        
    </div>
    <div class="w-5/12 flex flex-col bg-darkGray h-full border-l-8 border-l-peach">
        <div class="flex justify-around text-white font-semibold mt-4 mb-2">
            <button on:click={() =>  window = "payment"} class="mx-2 p-2 rounded-lg hover:bg-peach hover:text-darkGray"><span><i class="fa-solid fa-dollar-sign mr-2" style="color: #F2AA7E;"></i></span>Payment</button>
            <button on:click={() =>  window = "transaction_list"} class="mx-2 p-2 rounded-lg hover:bg-peach hover:text-darkGray"><span><i class="fa-solid fa-list mr-2" style="color: #F2AA7E;"></i></span>View Transaction List</button>
            <button 
            on:click={() => handleClick(2)}
            class="mx-2 p-2 rounded-lg hover:bg-peach hover:text-darkGray flex"><span class="mr-2"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
                <rect width="24" height="24" fill="url(#pattern0_434_939)"/>
                <defs>
                <pattern id="pattern0_434_939" patternContentUnits="objectBoundingBox" width="1" height="1">
                <use xlink:href="#image0_434_939" transform="scale(0.0025)"/>
                </pattern>
                <image id="image0_434_939" width="400" height="400" xlink:href="data:image/png;base64,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"/>
                </defs>
                </svg>
                </span>View All Promos</button>
        </div>
        <hr class="border mx-auto w-11/12 mb-2">
        <div class="flex flex-col items-center ml-6 h-5/6 overflow-auto">
            {#each checkout as produk_checkout}
                <div class="flex py-1 my-1 w-full">
                    <div class="w-9/12 text-white">
                        {#if (promos.find((produk) => produk["ProductDetail"].product_detail_id == produk_checkout.product_detail_id) != null)}
                            <p class="font-semibold truncate text-peach2">{produk_checkout.product_name}</p>
                        {:else}
                            <p class="font-semibold truncate">{produk_checkout.product_name}</p>
                        {/if}
                        <p class="flex font-semibold ml-8"><MoneyConverter value={produk_checkout.sell_price} currency={true} decimal={true}></MoneyConverter>/{produk_checkout.product_unit}</p>
                        {#if (promos.find((produk) => produk["ProductDetail"].product_detail_id == produk_checkout.product_detail_id) != null)}
                            {@const promo_produk = promos.find((produk) => produk["ProductDetail"].product_detail_id == produk_checkout.product_detail_id)}
                            {#if (promo_produk["Promo"].promo_type_id == 1)}
                                {#if (produk_checkout.jumlah >= promo_produk["Promo"].x_amount)}
                                    <p class="font-semibold ml-8">{(parseInt(produk_checkout.jumlah/promo_produk["Promo"].x_amount)*promo_produk["Promo"].y_amount) + " Free " + produk_checkout.product_unit + " from Promo"}</p>
                                    <p class="font-semibold ml-8 text-peach2">Promo Applied.</p>
                                {:else}
                                    <p class="font-semibold ml-8 text-peach2">This item has a promo! Promo not yet applied.</p>
                                {/if}
                            {:else if (promo_produk["Promo"].promo_type_id == 2)}
                                <p class="font-semibold ml-8">{"Discount " + promo_produk["Promo"].promo_percentage + "% off"}</p>
                                <p class="font-semibold ml-8 text-peach2">Promo Applied.</p>
                            {:else if (promo_produk["Promo"].promo_type_id == 3)}
                                <p class="font-semibold ml-8">{"Discount Rp" + all_promo[index]["Promo"].promo_discount + " off"}</p>
                                <p class="font-semibold ml-8 text-peach2">Promo Applied.</p>
                            {/if}
                       {/if}
                        
                    </div>
                    <div class="w-3/12 text-center">
                        <span class="text-peach font-semibold"><MoneyConverter value={produk_checkout.sell_price*produk_checkout.jumlah} currency={true} decimal={true}></MoneyConverter></span>
                        <div class="flex">
                            <button on:click={() => {
                                let index = checkout.findIndex(produk_c => produk_c.product_name == produk_checkout.product_name);
                                let index_promo = promos.findIndex(produk_p => produk_p["ProductDetail"].product_detail_id == produk_checkout.product_detail_id);
                                if (checkout[index].jumlah > 1){
                                    checkout[index].jumlah-=1;
                                } else{
                                    checkout.splice(index,1);
                                    checkout = checkout;

                                    promos.splice(index_promo,1);
                                    promos = promos;
                                    // console.log(checkout);
                                    // console.log("promos-",promos);
                                }
                                sumTotal();
                                checkPromoAppliedType1();
                                countPromoApplied();
                            }} 
                            type="button" class="bg-peach rounded-s-xl h-8 p-2">
                                <svg class="w-3 h-3 text-gray-900" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 18 2">
                                    <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 1h16"/>
                                </svg>
                            </button>
                            <input on:change={() =>{ sumTotal(); checkPromoAppliedType1();countPromoApplied()}} id={produk_checkout.product_name} bind:value={produk_checkout.jumlah} type="number" class="h-8 bg-gray-50 border-x-0 border-gray-300 text-center text-gray-900 text-sm w-16 [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none" required />
                            <button on:click={() => {
                                let index = checkout.findIndex(produk_c => produk_c.product_name == produk_checkout.product_name);
                                checkout[index].jumlah+=1;
                                sumTotal(); 
                                checkPromoAppliedType1();
                                countPromoApplied();
                            }} 
                            type="button" class="bg-peach rounded-e-xl h-8 p-2">
                                <svg class="w-3 h-3 text-gray-900" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 18 18">
                                    <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 1v16M1 9h16"/>
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>
            {/each}
            

        </div>

        <div class="text-end"> 
            <span class="text-peach font-semibold"><MoneyConverter bind:value={total} currency={true} decimal={true}></MoneyConverter></span>

        </div>
        <button on:click={() => handleClick(3)} class="w-auto bg-peach2 text-darkGray p-2 px-auto rounded-2xl mx-3 my-2 font-semibold">{promos.length} item(s) with promo, {count_promo_app} promo(s) applied</button>
        
        <button class="w-48 bg-peach text-darkGray p-2 px-auto rounded-2xl mx-auto mt-2 mb-4 font-semibold">Pay</button>
        
    </div>
</div>

{#if showModal === 1}
    <TaskModal open={showModal} onClose={() => closeModal()} color={"#3d4c52"}>
        <div class="flex items-center justify-center pt-8">
        <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Session #{this_session.session_id}</div>
        </div>
        
        <form class="p-4 md:p-5" >
        <div class="grid gap-3 font-roboto font-semibold">
            <div class="flex justify-between">
                <div class="text-[#f7d4b2]">Cashier</div>
                <div class="text-white">{this_session.user_fullname}</div>
            </div>
            <div class="flex justify-between">
                <div class="text-[#f7d4b2]">Start time</div>
                <div class="text-white">
                    <DateConverter value={this_session.start_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                </div>
            </div>
            <div class="flex justify-between">
                <div class="text-[#f7d4b2]">Closing time</div>
                <div class="text-white">
                    <DateConverter value={this_session.last_update_time} date={true} hour={true} second={false} ampm={true} monthNumber={true} dash={false} dateFirst={false}/>
                </div>
            </div>
            <div class="flex justify-between">
                <div class="text-[#f7d4b2]">Opening cash</div>
                <div class="text-white"><MoneyConverter value={this_session.opening_cash} currency={true} decimal={true}/></div>
            </div>
            <div class="flex justify-between">
                <div class="text-[#f7d4b2]">Total Income
                    <button on:click={toggleTable} class="ml-2">
                    {#if showTable}
                        <i class="fa-solid fa-caret-up"></i>
                    {:else}
                        <i class="fa-solid fa-caret-down"></i>
                    {/if}
                    </button>
                </div>
                <div class="text-white"><MoneyConverter value={this_session.total_income} currency={true} decimal={true}/></div>
            </div>
        
            {#if showTable}
            <div class="relative overflow-x-auto shadow-md sm:rounded-lg">
                <table class="w-full text-sm text-left rtl:text-right">
                    <thead class="text-xs text-gray-700 uppercase bg-gray-100">
                        <tr class="border-b-2 border-black">
                            <th scope="col" class="px-6 py-3 text-sm font-bold">
                                TRANSACTION ID
                            </th>
                            <th scope="col" class="px-6 py-3 text-sm font-bold">
                                TIME
                            </th>
                            <th scope="col" class="px-6 py-3 text-sm font-bold">
                                TOTAL
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr class="bg-yellow-100">
                            <th scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">
                                5432112345
                            </th>
                            <td class="px-6 py-4">
                                15:40 PM
                            </td>
                            <td class="px-6 py-4">
                                Rp 16.000,00
                            </td>
                        </tr>
                        <tr class="bg-white">
                            <th scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">
                                5432112345
                            </th>
                            <td class="px-6 py-4">
                                15:40 PM
                            </td>
                            <td class="px-6 py-4">
                                Rp 16.000,00
                            </td>
                        </tr>
                        <tr class="bg-yellow-100">
                            <th scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">
                                5432112345
                            </th>
                            <td class="px-6 py-4">
                                15:40 PM
                            </td>
                            <td class="px-6 py-4">
                                Rp 16.000,00
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            {/if}

            <div class="flex justify-between">
                <div class="text-[#f7d4b2]">Expected closing cash</div>
                <div class="text-white"><MoneyConverter value={this_session.expected_closing_cash} currency={true} decimal={true}/></div>
            </div>
            <div class="flex justify-between">
                <div class="text-[#f7d4b2]">Actual closing cash</div>
                    <MoneyInput bind:value={this_session.actual_closing_cash} />
                    </div>
            <div class="flex justify-between">
                <div class="text-[#f7d4b2]">Actual difference</div>
                <div class="text-white"><MoneyConverter value={this_session.actual_difference} currency={true} decimal={true}/></div>
            </div>
            <div class="flex justify-between">
                <div class="text-[#f7d4b2]">Deposit money</div>
                <MoneyInput bind:value={this_session.deposit_money} />
            </div>
            <div class="flex justify-between">
                <div class="text-[#f7d4b2]">Deposit Difference</div>
                <div class="text-white"><MoneyConverter value={this_session.deposit_difference} currency={true} decimal={true}/></div>
            </div>
            <div class="text-[#f7d4b2]">
                <div class="pb-3">Opening notes</div>
                <textarea id="opening_notes" rows="4" class="min-h-24 shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5" bind:value={this_session.opening_notes} readonly></textarea>                    
            </div>
            <div class="text-[#f7d4b2]">
                <div class="pb-3">Closing notes</div>
                <textarea id="closing_notes" rows="4" class="min-h-24 shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5" bind:value={this_session.closing_notes}></textarea>                    
            </div>
    
            <div class="flex items-center justify-center">
                <button
                on:click={() => CloseSession(this_session.session_id, this_session)}
                    type="submit" 
                    class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center ">
                    Save
                </button>
            </div>
        </div>
        </form>
    </TaskModal>
{:else if showModal === 2}
    <TaskModal open={showModal} onClose={() => closeModal()} color={"#3d4c52"}>
        <div class="flex items-center justify-center pt-8">
            <svg width="136" height="35" viewBox="0 0 136 35" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g filter="url(#filter0_i_1156_3148)">
                <path d="M6.52728 5.21416V14.9342H9.90228C12.6473 14.9342 14.4923 13.7642 14.4923 9.66916C14.4923 5.79916 12.9623 5.21416 9.40728 5.21416H6.52728ZM6.52728 34.0142H0.227282V0.264157H13.0973C19.1273 0.264157 20.9723 5.12416 20.9723 9.84916C20.9723 12.7292 20.2073 15.9692 17.8223 17.8592C15.8423 19.4342 13.1873 19.9292 10.7573 19.8842H6.52728V34.0142ZM30.4972 8.63416V13.1342H30.5872C31.3072 11.2892 32.0272 10.2542 32.8822 9.53416C34.5472 8.13916 35.6722 8.22916 36.5272 8.18416V15.1142C33.2872 14.7992 30.8122 15.6092 30.7222 19.3442V34.0142H24.8722V8.63416H30.4972ZM45.3925 17.2742V25.7342C45.3925 28.8392 45.6625 30.1892 48.4975 30.1892C51.1975 30.1892 51.4225 28.8392 51.4225 25.7342V17.2742C51.4225 14.8892 51.4225 12.4592 48.4975 12.4592C45.3925 12.4592 45.3925 14.8892 45.3925 17.2742ZM48.4975 34.6892C40.8025 34.8242 39.4975 31.0442 39.5425 22.2242C39.5875 13.5392 39.6775 7.95916 48.4975 7.95916C57.1825 7.95916 57.2275 13.5392 57.2725 22.2242C57.3175 31.0442 56.0575 34.8242 48.4975 34.6892ZM68.4775 8.63416V11.2442H68.5675C69.8725 8.45416 72.2575 8.04916 74.1475 7.95916C76.3075 7.91416 79.1875 8.85916 79.5475 11.2442H79.6375C80.7625 9.03916 82.6075 7.95916 85.4875 7.95916C89.8075 7.95916 91.6975 10.6592 91.6975 13.3592V34.0142H85.8475V16.8692C85.8475 14.5742 85.6225 12.3242 83.0575 12.4592C80.5375 12.5942 80.0875 14.3492 80.0875 17.3192V34.0142H74.2375V16.5542C74.2375 14.3042 74.0575 12.4142 71.3575 12.4592C68.6125 12.5042 68.4775 14.5292 68.4775 17.3192V34.0142H62.6275V8.63416H68.4775ZM102.917 17.2742V25.7342C102.917 28.8392 103.187 30.1892 106.022 30.1892C108.722 30.1892 108.947 28.8392 108.947 25.7342V17.2742C108.947 14.8892 108.947 12.4592 106.022 12.4592C102.917 12.4592 102.917 14.8892 102.917 17.2742ZM106.022 34.6892C98.3269 34.8242 97.0219 31.0442 97.0669 22.2242C97.1119 13.5392 97.2019 7.95916 106.022 7.95916C114.707 7.95916 114.752 13.5392 114.797 22.2242C114.842 31.0442 113.582 34.8242 106.022 34.6892ZM118.487 25.6442H124.337C123.887 30.3242 125.687 30.1892 127.037 30.1892C128.702 30.1892 129.872 28.9742 129.467 27.3542C129.377 25.9142 127.712 25.1042 126.587 24.3392L123.392 22.1342C120.467 20.1092 118.577 17.7692 118.577 14.1242C118.577 10.2092 121.682 7.95916 127.307 7.95916C132.977 7.95916 135.587 10.9292 135.452 16.3742H129.602C129.737 13.5392 128.927 12.4592 126.902 12.4592C125.507 12.4592 124.427 13.0892 124.427 14.5292C124.427 16.0142 125.507 16.6892 126.632 17.4542L131.402 20.6942C132.887 21.5492 135.227 23.9792 135.407 25.6892C135.902 30.0992 134.822 34.6892 126.722 34.6892C123.617 34.6892 117.812 33.3842 118.487 25.6442Z" fill="white"/>
                </g>
                <defs>
                <filter id="filter0_i_1156_3148" x="0.226562" y="0.26416" width="135.672" height="38.5601" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
                <feFlood flood-opacity="0" result="BackgroundImageFix"/>
                <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
                <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
                <feOffset dy="4"/>
                <feGaussianBlur stdDeviation="2"/>
                <feComposite in2="hardAlpha" operator="arithmetic" k2="-1" k3="1"/>
                <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/>
                <feBlend mode="normal" in2="shape" result="effect1_innerShadow_1156_3148"/>
                </filter>
                </defs>
            </svg>
         </div>
        <div class="p-4 md:p-5 font-roboto font-semibold" >
        {#each all_promo as promo}
            <div class="py-3">
                <div class="text-[#f7d4b2] text-xl">
                    {promo.ProductDetail.product_name}
                </div>
                <div class="indent-8 text-white text-xl ">
                    {#if (promo.Promo.promo_percentage !== 0)}
                        Discount {promo.Promo.promo_percentage}% off.
                    {:else if (promo.Promo.promo_discount !== 0)}
                        Discount <MoneyConverter value={promo.Promo.promo_discount} currency={true} decimal={true}></MoneyConverter>
                        
                    {:else}
                        Buy {promo.Promo.x_amount} get {promo.Promo.y_amount} free.
                    {/if}
                    
                </div>
                <div class="indent-8 text-2xl text-[#f7d4b2]">
                    {promo.Promo.promo_term_and_cond}
                </div>
                
                
            </div>
        {/each}
        <div class="flex items-center justify-center">
            <button
            on:click={() => closeModal()}
               type="submit" 
               class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center ">
               Close
            </button>
         </div>
        </div>
    </TaskModal>
{:else}
    <TaskModal open={showModal} onClose={() => closeModal()} color={"#3d4c52"}>
        <div class="flex items-center justify-center pt-8">
            <svg width="136" height="35" viewBox="0 0 136 35" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g filter="url(#filter0_i_1156_3148)">
                <path d="M6.52728 5.21416V14.9342H9.90228C12.6473 14.9342 14.4923 13.7642 14.4923 9.66916C14.4923 5.79916 12.9623 5.21416 9.40728 5.21416H6.52728ZM6.52728 34.0142H0.227282V0.264157H13.0973C19.1273 0.264157 20.9723 5.12416 20.9723 9.84916C20.9723 12.7292 20.2073 15.9692 17.8223 17.8592C15.8423 19.4342 13.1873 19.9292 10.7573 19.8842H6.52728V34.0142ZM30.4972 8.63416V13.1342H30.5872C31.3072 11.2892 32.0272 10.2542 32.8822 9.53416C34.5472 8.13916 35.6722 8.22916 36.5272 8.18416V15.1142C33.2872 14.7992 30.8122 15.6092 30.7222 19.3442V34.0142H24.8722V8.63416H30.4972ZM45.3925 17.2742V25.7342C45.3925 28.8392 45.6625 30.1892 48.4975 30.1892C51.1975 30.1892 51.4225 28.8392 51.4225 25.7342V17.2742C51.4225 14.8892 51.4225 12.4592 48.4975 12.4592C45.3925 12.4592 45.3925 14.8892 45.3925 17.2742ZM48.4975 34.6892C40.8025 34.8242 39.4975 31.0442 39.5425 22.2242C39.5875 13.5392 39.6775 7.95916 48.4975 7.95916C57.1825 7.95916 57.2275 13.5392 57.2725 22.2242C57.3175 31.0442 56.0575 34.8242 48.4975 34.6892ZM68.4775 8.63416V11.2442H68.5675C69.8725 8.45416 72.2575 8.04916 74.1475 7.95916C76.3075 7.91416 79.1875 8.85916 79.5475 11.2442H79.6375C80.7625 9.03916 82.6075 7.95916 85.4875 7.95916C89.8075 7.95916 91.6975 10.6592 91.6975 13.3592V34.0142H85.8475V16.8692C85.8475 14.5742 85.6225 12.3242 83.0575 12.4592C80.5375 12.5942 80.0875 14.3492 80.0875 17.3192V34.0142H74.2375V16.5542C74.2375 14.3042 74.0575 12.4142 71.3575 12.4592C68.6125 12.5042 68.4775 14.5292 68.4775 17.3192V34.0142H62.6275V8.63416H68.4775ZM102.917 17.2742V25.7342C102.917 28.8392 103.187 30.1892 106.022 30.1892C108.722 30.1892 108.947 28.8392 108.947 25.7342V17.2742C108.947 14.8892 108.947 12.4592 106.022 12.4592C102.917 12.4592 102.917 14.8892 102.917 17.2742ZM106.022 34.6892C98.3269 34.8242 97.0219 31.0442 97.0669 22.2242C97.1119 13.5392 97.2019 7.95916 106.022 7.95916C114.707 7.95916 114.752 13.5392 114.797 22.2242C114.842 31.0442 113.582 34.8242 106.022 34.6892ZM118.487 25.6442H124.337C123.887 30.3242 125.687 30.1892 127.037 30.1892C128.702 30.1892 129.872 28.9742 129.467 27.3542C129.377 25.9142 127.712 25.1042 126.587 24.3392L123.392 22.1342C120.467 20.1092 118.577 17.7692 118.577 14.1242C118.577 10.2092 121.682 7.95916 127.307 7.95916C132.977 7.95916 135.587 10.9292 135.452 16.3742H129.602C129.737 13.5392 128.927 12.4592 126.902 12.4592C125.507 12.4592 124.427 13.0892 124.427 14.5292C124.427 16.0142 125.507 16.6892 126.632 17.4542L131.402 20.6942C132.887 21.5492 135.227 23.9792 135.407 25.6892C135.902 30.0992 134.822 34.6892 126.722 34.6892C123.617 34.6892 117.812 33.3842 118.487 25.6442Z" fill="white"/>
                </g>
                <defs>
                <filter id="filter0_i_1156_3148" x="0.226562" y="0.26416" width="135.672" height="38.5601" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
                <feFlood flood-opacity="0" result="BackgroundImageFix"/>
                <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
                <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
                <feOffset dy="4"/>
                <feGaussianBlur stdDeviation="2"/>
                <feComposite in2="hardAlpha" operator="arithmetic" k2="-1" k3="1"/>
                <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/>
                <feBlend mode="normal" in2="shape" result="effect1_innerShadow_1156_3148"/>
                </filter>
                </defs>
            </svg>
         </div>
        <div class="p-4 md:p-5 font-roboto font-semibold" >
        {#if (promos.length == 0)}
            <div class="text-[#f7d4b2] text-xl text-center">
                Tidak ada promo pada produk di checkout
            </div>
        {:else}
            {#each promos as promo}
                {@const checkout_produk = checkout.find((produk) => produk.product_detail_id  == promo["ProductDetail"].product_detail_id)}
                <div class="py-3">
                    <div class="text-peach2 text-xl">
                        {promo.ProductDetail.product_name}
                    </div>
                    <div class="indent-8 text-white text-xl ">
                        {#if (promo.Promo.promo_percentage !== 0)}
                            Discount {promo.Promo.promo_percentage}% off.
                        {:else if (promo.Promo.promo_discount !== 0)}
                            Discount <MoneyConverter value={promo.Promo.promo_discount} currency={true} decimal={true}></MoneyConverter>
                            
                        {:else}
                            Buy {promo.Promo.x_amount} get {promo.Promo.y_amount} free.
                        {/if}
                        
                    </div>
                    <!-- <div class="indent-8 text-2xl text-[#f7d4b2]">
                        {promo.Promo.promo_term_and_cond}
                    </div>    -->
                    <div class="indent-8 text-xl text-peach2">
                        {#if (promo.promo_applied == true)}
                            {#if (promo["Promo"].promo_type_id == 1)}
                                Promo applied {(parseInt(checkout_produk.jumlah/promo["Promo"].x_amount))} time(s)
                                <p class="indent-16 text-white font-bold">{(parseInt(checkout_produk.jumlah/promo["Promo"].x_amount)*promo["Promo"].y_amount)} Free {checkout_produk.product_unit}</p>
                            
                            {:else}
                                Promo applied 
                            {/if}
                        {:else}
                            Promo not applied, requirements not met.
                        {/if}
                    </div>   

                </div>
            {/each}
        {/if}
        
        <div class="flex items-center justify-center">
            <button
            on:click={() => closeModal()}
               type="submit" 
               class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center ">
               Close
            </button>
         </div>
        </div>
    </TaskModal>
{/if}