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
	import { json } from "@sveltejs/kit";
    
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
        if (Number(id) === 1){
            fetchTransactionBySession(sessionId);
        }
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
                    "total_income": this_session.total_income,
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

    function pay(){
        sessionStorage.setItem('checkout', JSON.stringify(checkout));
        goto(`/payment/${userId}/${roleId}/${sessionId}/${total}`);
    }

    let transactionByID = [];
    async function fetchTransactionBySession(sessionIdnya) {
        const response = await fetch(`http://leap.crossnet.co.id:8888/cashier/session/transaction/${sessionIdnya}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('transaction by id fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch transaction by id ', data);
            return;
        }

        transactionByID = data.data;
        console.log(transactionByID);
        const sumOfTransactionTotalPrice = transactionByID.length > 0 ? transactionByID.reduce((sum, transaction) => sum + transaction.transaction_total_price, 0) : 0;

        // Update this_session properties
        this_session.total_income = sumOfTransactionTotalPrice;
        this_session.expected_closing_cash = this_session.total_income + this_session.opening_cash;

        console.log('Total Income:', this_session.total_income);
        console.log('Expected Closing Cash:', this_session.expected_closing_cash);
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
                            <i class="fa-solid fa-sliders fa-xl mr-2"></i>
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
        
        <button on:click={() => pay()} class="w-48 bg-peach text-darkGray p-2 px-auto rounded-2xl mx-auto mt-2 mb-4 font-semibold">Pay</button>
        
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
                    {#if transactionByID.length > 0}
                    <button on:click={toggleTable} class="ml-2">
                    {#if showTable}
                        <i class="fa-solid fa-caret-up"></i>
                    {:else}
                        <i class="fa-solid fa-caret-down"></i>
                    {/if}
                    </button>
                    {/if}
                </div>
                <div class="text-white"><MoneyConverter value={this_session.total_income} currency={true} decimal={true}/></div>
            </div>
        
            {#if showTable && transactionByID.length > 0}
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
                        {#each transactionByID as transaction, i}
                            <tr class={i % 2 === 0 ? 'bg-yellow-100' : 'bg-white'}>                        
                            <th scope="row" class="px-6 py-4 font-medium text-gray-900 whitespace-nowrap">
                                    {transaction.transaction_id}
                            </th>
                            <td class="px-6 py-4">
                                <DateConverter value={transaction.transaction_timestamp} date={false} hour={true} second={false} ampm={true} monthNumber={false} dash={false} dateFirst={false}/>
                            </td>
                            <td class="px-6 py-4">
                                <MoneyConverter value={transaction.transaction_total_price} currency={true} decimal={true}/>
                            </td>
                            </tr>
                        {/each}
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