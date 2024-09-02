<script>
    $: tampilan = "awal";
    import TaskModal from '$lib/TaskModal.svelte';
    import { onMount } from 'svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import { getFormattedDate } from '$lib/DateNow.js';
	import { goto } from '$app/navigation';
	import { json } from '@sveltejs/kit';
    import { uri, userId, roleId, sessionId, totalAmount } from '$lib/uri.js';
    import { get } from 'svelte/store';

    // export let data
    // let sessionId = data.sessionId;
    // let roleId = data.roleId;
    // let userId = data.userId;
    // let total_amount = get(get(totalAmount));
    // console.log(total_amount);
    let checkout = [];
    let promos = [];

    let transaction = [];

    if (typeof window !== 'undefined') {
        const storedCheckout = sessionStorage.getItem('checkout');
        checkout = storedCheckout ? JSON.parse(storedCheckout) : [];

        const storedPromos = sessionStorage.getItem('promos');
        promos = storedPromos ? JSON.parse(storedPromos) : [];
    }
    // $: checkout = JSON.parse(sessionStorage.getItem('checkout' || '[]'));
    console.log("isi checkout", checkout)
    console.log("isi promos", promos)

    $: received = 0;
    $: change = 0;
    $: transaction_payment_method_id = 1;

    // BUAT STRUK
    let transaction_detail = [];
    let transaction_struk = [];
    let payment_method = [];
    let user = [];
    let cashier_id = 0;
    let store_warehouse = [];
    let products = [];
    $: total_free = 0;
    $: total_discount = 0;

    let showModal = null; 
    let member_name = "";
    let member_phone_number = "";
    let member_join_date = getFormattedDate();
    $: member_points = 0;
    let member = [];
    let use = false;
    function handleClick(id) {
        showModal = id;
    }
    function closeModal() {
        showModal = null;
    }
    // onMount(async () => {
    //     fetchPhoneNumber();
    // });
    function toggleUse() {
        if (member.member_points > 0){
            use = !use;
        }else{
            use = false;
        }
    }

    async function fetchPhoneNumber() {
        const response = await fetch(`http://${$uri}:8888/cashier/members/phone_number/${member_phone_number}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('member fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch member', data);
            return;
        }

        member = data.data;
        return member;
    }
    async function checkPhoneNumber() {
        const memberData = await fetchPhoneNumber();
        
        if (!memberData || memberData.length === 0) {
            // Phone number does not exist, show SweetAlert
            Swal.fire({
                title: "Phone Number Not Found",
                text: "The phone number doesn't exist. Please create a member.",
                icon: "warning",
                confirmButtonText: "Create Member",
                color: "white",
                background: "#364445",
                confirmButtonColor: '#F2AA7E'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Open the Create Membership modal and autofill phone number
                    handleClick(1);
                }
            });
        } else {
            // Phone number exists, open the member information modal
            handleClick(3);
        }
    }
    async function NewMember() {
        const response = await fetch(`http://${$uri}:8888/cashier/members/add`, {
            method: 'POST',
            body: JSON.stringify({
                member_name,
                member_phone_number,
                member_join_date,
            })
        });

        if (!response.ok) {
            console.error('POST new member gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid post new member', data);
            return;
        }
        closeModal();
    }

    async function getPromoProductId(product_detail_id){
        const response = await fetch(`http://${$uri}:8888/promos/product/${product_detail_id}`, {
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
        // console.log(data.data[0]);
        // console.log(data.data[0].promo_product_id);
        let promo_product_id = data.data[0].promo_product_id;
        return promo_product_id;
        
    }

    function usePoints(){
        member_points = member.member_points;
        closeModal();
    }
    $: total_bayar = get(totalAmount)-member_points;
    $: {
        if (received >= total_bayar) {
        change = received - total_bayar;
        } else {
        change = 0;
        }
    }
    // function handleChange(){
    //     let total_bayar = get(totalAmount)-member_points;
    //     console.log(total_bayar)
    //     if(received >= total_bayar){
    //         change = received-total_bayar;
    //         return change;
    //     }
    // }

    async function validate(){
        for (let i = 0; i < checkout.length; i++) {
            // cek apakah produk_checkout ada di array promos
            if (promos.find((produk) => produk["ProductDetail"].product_detail_id == checkout[i]["ProductDetails"].product_detail_id) != null){
                // jika ada, ambil index di array promos
                let index = promos.findIndex(produk_p => produk_p["ProductDetail"].product_detail_id == checkout[i]["ProductDetails"].product_detail_id);
                
                let product_detail_id = promos[index]["ProductDetail"].product_detail_id;
                let promo_product_id = await getPromoProductId(product_detail_id);
                promo_product_id = promo_product_id;
                let quantity = checkout[i].jumlah;
                let sell_price = promos[index]["ProductDetail"].sell_price;
                let discount_price = ((promos[index]["ProductDetail"].sell_price)-(checkout[i]["ProductDetails"].sell_price))*quantity;
                let total_price = (sell_price-discount_price)*quantity;
                let quantity_free = 0;
                if (promos[index]["Promo"].promo_type_id == 1){
                    quantity_free = (parseInt(quantity/promos[index]["Promo"].x_amount)*promos[index]["Promo"].y_amount);
                    quantity_free = quantity_free;
                    discount_price = promos[index]["ProductDetail"].sell_price * quantity_free;
                    total_price = sell_price*quantity;
                }

                let produk_transaksi = 
                {
                    product_detail_id,
                    promo_product_id,
                    quantity,
                    sell_price,
                    discount_price,
                    total_price,
                    quantity_free
                }
                transaction.push(produk_transaksi);
                transaction = transaction;
            } else {
                let product_detail_id = checkout[i]["ProductDetails"].product_detail_id;
                let promo_product_id = 0;
                let quantity = checkout[i].jumlah;
                let sell_price = checkout[i]["ProductDetails"].sell_price;
                let discount_price = 0;
                let total_price = (sell_price-discount_price)*quantity;
                let quantity_free = 0;

                let produk_transaksi = 
                {
                    product_detail_id,
                    promo_product_id,
                    quantity,
                    sell_price,
                    discount_price,
                    total_price,
                    quantity_free
                }
                transaction.push(produk_transaksi);
                transaction = transaction;
            }
        }
        console.log("transaction arr:",JSON.stringify(transaction));
        await InsertTransaction(transaction);
        
        //update table transaction
        let last_transaction_id = await getLastTransactionId();
        let member_id = 0;
        let member_points = 0;

        if (member.length > 0){
            member_id = member.member_id
            if(member.member_points <= get(totalAmount)){
                member_points = -(member.member_points);
                console.log(member_points);
            } else if (member.member_points > get(totalAmount)){
                member_points = -(get(totalAmount));
                console.log(member_points);
            }
        }

        let transaction_timestamp = new Date();
        transaction_timestamp = transaction_timestamp.getUTCFullYear() + '-' +
        ('00' + (transaction_timestamp.getUTCMonth()+1)).slice(-2) + '-' +
        ('00' + transaction_timestamp.getUTCDate()).slice(-2) + ' ' + 
        ('00' + (transaction_timestamp.getUTCHours()+7)).slice(-2) + ':' + 
        ('00' + transaction_timestamp.getUTCMinutes()).slice(-2) + ':' + 
        ('00' + transaction_timestamp.getUTCSeconds()).slice(-2);
        transaction_timestamp = String(transaction_timestamp)

        let transaction_payment = parseInt(received);
        let transaction_change = change;

        let transaction_item = 
        {
            transaction_timestamp,
            transaction_payment_method_id,
            transaction_payment,
            transaction_change,
            member_points
        }
        console.log("isi transaction item",JSON.stringify(transaction_item));

        await updateLastTransaction(last_transaction_id,$sessionId,member_id,transaction_item);

        await fetchTransaction(last_transaction_id);
        await fetchTransactionDetail(last_transaction_id);

        await getStoreWarehouse();
        await fetchAllProduct();

    }

    async function InsertTransaction(transaction_arr) {
        const response = await fetch(`http://${$uri}:8888/transaction/details/add/${$userId}/${$roleId}`, {
            method: 'POST',
            body: JSON.stringify(transaction_arr)
        });

        if (!response.ok) {
            console.error('POST transaction gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid post transaction', data);
            return;
        }
        console.log("insert transaction detail",data);
      }

      async function updateLastTransaction(last_transaction_id,session_id,member_id,transaction) {
        const response = await fetch(`http://${$uri}:8888/transaction/update/${last_transaction_id}/${session_id}/${member_id}`, {
            method: 'PUT',
            headers: {
                    'Content-Type': 'application/json',
                },
            body: JSON.stringify(transaction)
        });

        if (!response.ok) {
            console.error('PUT transaction gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid put transaction', data);
            return;
        }
        console.log("put transaction",data);
      }

      async function getLastTransactionId(){
        const response = await fetch(`http://${$uri}:8888/transaction/last`, {
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
        console.log("last_id",data.data.transaction_id);
        let last_id = data.data.transaction_id;
        return last_id;
    }

    async function getStoreWarehouse() {
        let response;
        response = await fetch(`http://${$uri}:8888/store_warehouses/${cashier_id}/1`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all store_warehouses fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch store_warehouses', data);
            return;
        }

        store_warehouse = data.data;
        // console.log(transaction_detail);
    }

    async function fetchTransaction(transactionId) {
        let response;

        response = await fetch(`http://${$uri}:8888/transaction/${transactionId}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all transactions fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch transactions', data);
            return;
        }

        transaction_struk = data.data.Transaction;
        payment_method = data.data.PaymentMethod;
        user = data.data.UserData;
        cashier_id = data.data.UserData.user_id;
    }

    async function fetchTransactionDetail(transactionId) {
        let response;

        response = await fetch(`http://${$uri}:8888/transaction/detail/${transactionId}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all transactions fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch transactions', data);
            return;
        }

        transaction_detail = data.data;
        countFreeItem();
        console.log("isi transaction detail :",transaction_detail);
    }

    async function fetchAllProduct() {
        let response;

        response = await fetch(`http://${$uri}:8888/products`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('get all products fetch failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch products', data);
            return;
        }

        products = data.data;
    }

    function getProductSellPrice(product_detail_id) {
        const product = products.find(p => p.product_detail_id === product_detail_id);
        return product ? product.sell_price : 0;
    }
    
    function countFreeItem(){
        for (let i = 0; i < transaction_detail.length; i++) {
            if (transaction_detail[i].quantity_free > 0){
                total_free += transaction_detail[i].quantity_free;
                // total_discount_free += transaction_detail[i].discount_price;
            }
            //sekalian itung total discount
            total_discount += transaction_detail[i].discount_price;
        }
    }

    
</script>

<!-- {member_points} -->
<div class="flex h-screen">
    <div class="w-1/2 h-full flex flex-col">
        <div class="flex my-2 mx-8">
            <button on:click={() => goto(`/session_main`)} class="font-semibold text-lg mx-3 hover:bg-gray-300 p-2 rounded-lg"><i class="fa-solid fa-arrow-right-from-bracket mr-2"></i>Back</button>
            <button class="font-semibold text-lg mx-3 hover:bg-gray-300 p-2 rounded-lg"><i class="fa-solid fa-user mr-2"></i>Budi</button>
        </div>

        <hr class="border-2 border-darkGray mx-auto w-11/12 mb-2">

        {#if tampilan != "validasi"}
        <div class="h-full flex flex-col items-center justify-around mb-12">
            <div class="w-full flex flex-col items-center">
                <span class="text-4xl font-bold text-darkGray my-4">Payment Method</span>
                <button on:click={() => {tampilan = "cash"; tampilan = tampilan; transaction_payment_method_id = 2; transaction_payment_method_id = transaction_payment_method_id;}}  class="w-8/12 px-auto py-4 bg-white hover:bg-darkGray hover:text-peach2 focus:bg-darkGray focus:text-peach2 rounded-2xl text-xl font-bold border-b-4 border-b-peach my-2 shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)]">Cash</button>
                <button on:click={() => {tampilan = "qr"; tampilan = tampilan; transaction_payment_method_id = 1;transaction_payment_method_id = transaction_payment_method_id;}} class="w-8/12 px-auto py-4 bg-white hover:bg-darkGray hover:text-peach2 focus:bg-darkGray focus:text-peach2 rounded-2xl text-xl font-bold border-b-4 border-b-peach my-2 shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)]">Generate QR</button>    
            </div>

            <div class="w-full flex flex-col items-center">
                <span class="text-4xl font-bold text-darkGray my-4">Membership</span>
                <button 
                on:click={() => handleClick(1)}
                class="w-8/12 px-auto py-4 bg-white hover:bg-darkGray hover:text-peach2 focus:bg-darkGray focus:text-peach2 rounded-2xl text-xl font-bold border-b-4 border-b-peach my-2 shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)]">Create Membership</button>
                <button 
                on:click={() => handleClick(2)}
                class="w-8/12 px-auto py-4 bg-white hover:bg-darkGray hover:text-peach2 focus:bg-darkGray focus:text-peach2 rounded-2xl text-xl font-bold border-b-4 border-b-peach my-2 shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)]">Use Membership</button>
            </div>
        </div>
        {:else}
        <div class="select-none	mx-8 bg-white p-3 font-roboto text-lg w-3/5">
            <div class="flex justify-center my-2 uppercase">
              {store_warehouse.store_warehouse_name}
            </div>
            <div class="flex justify-center uppercase">
              {store_warehouse.store_warehouse_address}
            </div>
            <div class="text-wrap">
              ==================================================
            </div>
            <div class="flex justify-between">
              <div>BON {transaction_struk.transaction_id}</div>
              <div>Kasir: {user.user_fullname}</div>
            </div>
            <div class="text-wrap">
                ==================================================
            </div>
            {#each transaction_detail as detail}
                <div class="flex">
                <div class="uppercase w-5/12 font-semibold">
                    {detail.product_detail_name}
                </div>
                <div class="flex w-1/12 justify-end">
                    {detail.quantity}
                </div>
                <div class="flex w-3/12 justify-end">
                    <MoneyConverter value={detail.sell_price} currency={false} decimal={false}></MoneyConverter>
                </div>
                <div class="flex w-3/12 justify-end">
                    <MoneyConverter value={detail.sell_price * detail.quantity} currency={false} decimal={false}></MoneyConverter>
                </div>
                </div>
                {#if detail.quantity_free > 0}
                <div class="flex">
                    <div class="pl-8 uppercase w-5/12">
                        <!-- FREE {detail.product_detail_name} -->
                        FREE
                    </div>
                    
                    <div class="flex w-1/12 justify-end">
                    {#if detail.quantity_free > 0}
                        {detail.quantity_free}
                    {/if}
                    </div>
                    <div class="flex w-3/12 justify-end">
                    <MoneyConverter value={detail.sell_price} currency={false} decimal={false}></MoneyConverter>
                    </div>
                    <div class="flex w-3/12 justify-end">
                        <MoneyConverter value={detail.discount_price} currency={false} decimal={false}></MoneyConverter>
                    </div>
                </div>
                {/if}
                {#if detail.discount_price}
                <div class="flex justify-between">
                <div class="pl-8 uppercase w-5/12">
                    <!-- DISCOUNT {detail.product_detail_name} -->
                    DISCOUNT
                </div>
                
                <div class="flex w-1/12 justify-end">

                </div>
                <div class="flex w-3/12 justify-end">

                </div>
                <div class="flex w-3/12 justify-end">
                    -<MoneyConverter value={detail.discount_price} currency={false} decimal={false}></MoneyConverter>
                </div>
                </div>
                {/if}
                <!-- {#if detail.quantity_free > 0}
                <div class="flex justify-start">
                    <div class="w-24">
                    FREE
                    </div>
                    <div class="">
                    {detail.quantity_free}
                    </div>
                </div>
                {/if} -->
            {/each}
            <div class="text-wrap">
                ==================================================
            </div>
            <div class="flex justify-between my-2">

                <div class="w-5/12">
                  Total item
                </div>
                <div class="flex w-1/12 justify-end">
                  {transaction.transaction_total_item + total_free}
                </div>
                <div class="flex w-3/12 justify-end">
      
                </div>
                <div class="flex w-3/12 justify-end">
                  <MoneyConverter value={transaction.transaction_total_price + total_discount} currency={false} decimal={false}></MoneyConverter>
                </div>
      
            </div>
            <div class="flex justify-between my-2">
      
                <div class="w-5/12">
                  Total discount
                </div>
                <div class="flex w-1/12 justify-end">
                  
                </div>
                <div class="flex w-3/12 justify-end">
      
                </div>
                <div class="flex w-3/12 justify-end">
                  -<MoneyConverter value={total_discount} currency={false} decimal={false}></MoneyConverter>          
                </div>
      
            </div>
            <div class="flex justify-between my-2">
              <div>
                Total belanja
              </div>
              <div>
                  <MoneyConverter value={transaction_struk.transaction_total_price} currency={false} decimal={false}></MoneyConverter>
              </div>
            </div>
            <div class="flex justify-between my-2">
              <div>
                {payment_method.payment_method_name}
              </div>
              <div>
                  <MoneyConverter value={transaction_struk.transaction_payment} currency={false} decimal={false}></MoneyConverter>
              </div>
            </div>
            {#if (Number(transaction_struk.transaction_change) > 0)}
            <div class="flex justify-between my-2">
              <div>
                Kembalian
              </div>
              <div>
                  <MoneyConverter value={transaction_struk.transaction_change} currency={false} decimal={false}></MoneyConverter>
              </div>
            </div>
            {/if}
            <div class="text-wrap">
                ==================================================
            </div>
            <div class="flex justify-center my-2">
              Tgl. <DateConverter value={transaction_struk.transaction_timestamp} date={true} hour={true} second={true} ampm={false} monthNumber={true} dash={true} dateFirst={true}/>
      
              <!-- Tgl. 01-01-2024 06:54:17 -->
            </div>
            <!-- <img src={receipt} class=""> -->
        </div>
        {/if}
        
    </div>
    <div class="w-1/2 h-full bg-darkGray border-l-8 border-l-peach">
            {#if tampilan == "awal"}
            <div class="h-3/6 bg-gray-100 mt-16 mx-2 flex flex-col items-center justify-center">
                <span class="text-3xl text-darkGray font-bold mb-2">Total Amount</span>
                <span class="text-7xl text-darkGray font-bold"><MoneyConverter value={get(totalAmount)} currency={true} decimal={true}></MoneyConverter></span>
            </div>
            {:else if tampilan == "cash"}
            <div class="h-3/6 bg-gray-100 mt-16 mx-2 flex flex-col items-center justify-center">
                <div class="w-full p-6">
                    <div class="w-full flex justify-between text-darkGray font-semibold text-lg my-2">
                        <span>Total Amount</span>
                        <span><MoneyConverter value={get(totalAmount)} currency={true} decimal={true}></MoneyConverter></span>
                    </div>
                    <div class="w-full flex justify-between text-darkGray font-semibold text-lg my-2">
                        <span>Membership Points</span>
                        <span><MoneyConverter value={member_points} currency={true} decimal={true}></MoneyConverter></span>
                    </div>
                    <div class="w-full flex justify-between text-darkGray font-semibold text-lg my-2">
                        <span>Total to Pay</span>
                        <span><MoneyConverter value={get(totalAmount)-member_points} currency={true} decimal={true}></MoneyConverter></span>
                    </div>
                    <div class="w-full flex justify-between text-darkGray font-semibold text-lg my-2">
                        <span class="">Received (Rp)</span>
                        <MoneyInput bind:value={received} />
                        <!-- <input type="text" name="" id="" class="w-4/12 rounded-lg focus:ring-darkGray" bind:value={received} on:input={() => handleChange()}> -->
                    </div>
                    <div class="w-full flex justify-between text-darkGray font-semibold text-lg my-2">
                        <span class="font-semibold text-darkGray text-lg mb-1">Change</span>
                        {#if received >=  (get(totalAmount)-member_points)}
                            <span class="font-semibold text-darkGray text-lg"><MoneyConverter value={change} currency={true} decimal={true}></MoneyConverter></span>
                        {:else}
                            <span class="font-bold text-red-500 text-lg">Uang yang diterima kurang</span>
                        {/if}
                    </div>
                </div>
            </div>
            {:else if tampilan == "qr"}
            <div class="h-3/6 bg-gray-100 mt-16 mx-2 flex items-center p-6">
                <div class="w-1/2">
                    <div class="w-full flex flex-col text-darkGray font-semibold text-lg my-2">
                        <span>Total Amount</span>
                        <span><MoneyConverter value={get(totalAmount)} currency={true} decimal={true}></MoneyConverter></span>
                    </div>
                    <div class="w-full flex flex-col text-darkGray font-semibold text-lg my-2">
                        <span>Membership Points</span>
                        <span><MoneyConverter value={member_points} currency={true} decimal={true}></MoneyConverter></span>
                    </div>
                    <div class="w-full flex flex-col text-darkGray font-semibold text-lg my-2">
                        <span>Total to Pay</span>
                        <span><MoneyConverter value={get(totalAmount)-member_points} currency={true} decimal={true}></MoneyConverter></span>
                    </div>
                </div>
                <div class="w-1/2">
                    <svg width="300" height="300" viewBox="0 0 300 300" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
                        <rect width="300" height="300" fill="url(#pattern0_464_2864)"/>
                        <defs>
                        <pattern id="pattern0_464_2864" patternContentUnits="objectBoundingBox" width="1" height="1">
                        <use xlink:href="#image0_464_2864" transform="matrix(0.0025237 0 0 0.0025 -0.00473934 0)"/>
                        </pattern>
                        <image id="image0_464_2864" width="400" height="400" xlink:href="data:image/png;base64,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"/>
                        </defs>
                        </svg>
                </div>
            </div>
            {:else if tampilan == "validasi"}
            <button class="w-full h-3/6 bg-gray-100 mt-16 flex flex-col items-center justify-center">
                <span class="text-8xl text-darkGray font-bold mb-2">PRINT</span>
            </button>
            {/if}
        <div class="h-2/6 my-8">
            <div class="h-full flex justify-center items-center">
                {#if tampilan != "awal"}
                <button on:click={() => {validate(); tampilan = "validasi"; tampilan = tampilan;}} class=" p-2 h-full flex flex-col justify-center items-center rounded-lg hover:border-4 hover:border-peach">
                    {#if tampilan == "cash" && (received >=  (get(totalAmount)-member_points)) || tampilan == "qr"}
                    <span class="text-white text-6xl font-bold">Validate</span>
                    <i class="fa-regular fa-circle-check fa-5x" style="color: #ffffff;"></i>       
                    {/if}      
                </button>
                    {#if tampilan == "validasi"}   
                        <span class="text-white text-8xl font-bold">NEXT ORDER</span>
                    {/if}
                {/if}
                
            </div>
        </div>
    </div>
</div>

{#if showModal === 1}
<TaskModal open={showModal} onClose={() => closeModal()} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8">
        <svg width="281" height="36" viewBox="0 0 281 36" fill="none" xmlns="http://www.w3.org/2000/svg">
            <g filter="url(#filter0_i_464_2202)">
            <path d="M14.2529 22.985H20.5979C20.5529 23.615 20.5079 24.29 20.4629 24.92C20.1479 31.085 18.0779 35.81 11.0579 35.81C0.707892 35.81 0.032892 29.24 0.032892 20.24V15.425C0.302892 6.83 0.977892 0.44 11.0579 0.44C16.6829 0.529999 19.8329 3.41 20.2829 9.17C20.3729 10.025 20.4629 10.88 20.4179 11.735H14.2079C13.9379 9.575 14.1629 5.525 11.0579 5.525C6.10789 5.525 6.51289 11.42 6.51289 14.03V23.39C6.51289 26.18 6.73789 30.725 11.0579 30.725C14.5229 30.725 14.1179 25.145 14.2529 22.985ZM30.8878 9.62V14.12H30.9778C31.6978 12.275 32.4178 11.24 33.2728 10.52C34.9378 9.125 36.0628 9.215 36.9178 9.17V16.1C33.6778 15.785 31.2028 16.595 31.1128 20.33V35H25.2628V9.62H30.8878ZM39.9331 25.01V18.35C39.6631 12.365 42.7231 8.945 48.4831 8.945C56.6281 8.945 57.4831 13.175 57.4831 20.105V23.525H45.7831V27.215C45.8281 30.545 47.0881 31.175 48.8431 31.175C51.0031 31.175 51.6331 29.6 51.5431 26.405H57.3931C57.6181 32.075 55.2781 35.675 49.2931 35.675C42.5431 35.675 39.7981 32.48 39.9331 25.01ZM45.7831 19.025H51.6331V16.82C51.5881 14.255 50.9131 13.445 48.5731 13.445C45.6481 13.445 45.7831 15.695 45.7831 17.99V19.025ZM79.8481 35H74.3131C73.9081 34.19 73.8631 33.29 73.9531 32.39H73.8631C73.1881 33.425 72.4231 34.28 71.5231 34.82C70.6681 35.36 69.7231 35.675 68.7331 35.675C64.0081 35.675 61.9381 33.29 61.9381 28.07C61.9381 22.265 66.0331 20.87 70.6231 18.98C73.0981 17.945 73.9981 16.82 73.5031 14.75C73.2331 13.625 72.3331 13.445 70.7581 13.445C68.1031 13.445 67.6531 14.84 67.6981 17.135H62.1181C62.0731 12.32 63.6481 8.945 70.9831 8.945C78.9481 8.945 79.4431 13.13 79.3531 16.46V31.445C79.3531 32.66 79.5331 33.83 79.8481 35ZM73.5031 24.38V21.635C72.0631 22.625 70.3081 23.615 68.7781 24.875C67.9231 25.595 67.7881 26.855 67.7881 27.935C67.7881 29.87 68.3731 31.175 70.5331 31.175C73.9981 31.175 73.3681 26.81 73.5031 24.38ZM93.8881 30.5V35.09C90.4231 35.495 85.5631 35.81 85.5631 31.085V13.895H83.1781V9.62H85.5181V2.645H91.4131V9.62H93.8881V13.895H91.4131V29.645C91.5481 30.725 93.1681 30.59 93.8881 30.5ZM97.4575 25.01V18.35C97.1875 12.365 100.248 8.945 106.008 8.945C114.153 8.945 115.008 13.175 115.008 20.105V23.525H103.308V27.215C103.353 30.545 104.613 31.175 106.368 31.175C108.528 31.175 109.158 29.6 109.068 26.405H114.918C115.143 32.075 112.803 35.675 106.818 35.675C100.068 35.675 97.3225 32.48 97.4575 25.01ZM103.308 19.025H109.158V16.82C109.113 14.255 108.438 13.445 106.098 13.445C103.173 13.445 103.308 15.695 103.308 17.99V19.025ZM138.138 24.38V35H131.838V1.25H141.873L145.248 16.91C145.788 19.475 146.148 22.085 146.418 24.695H146.508C146.823 21.365 147.048 19.115 147.498 16.91L150.873 1.25H160.863V35H154.563V24.38C154.563 17.675 154.698 10.97 155.103 4.265H155.013L148.263 35H144.438L137.823 4.265H137.598C138.003 10.97 138.138 17.675 138.138 24.38ZM166.232 25.01V18.35C165.962 12.365 169.022 8.945 174.782 8.945C182.927 8.945 183.782 13.175 183.782 20.105V23.525H172.082V27.215C172.127 30.545 173.387 31.175 175.142 31.175C177.302 31.175 177.932 29.6 177.842 26.405H183.692C183.917 32.075 181.577 35.675 175.592 35.675C168.842 35.675 166.097 32.48 166.232 25.01ZM172.082 19.025H177.932V16.82C177.887 14.255 177.212 13.445 174.872 13.445C171.947 13.445 172.082 15.695 172.082 17.99V19.025ZM195.167 9.62V12.23H195.257C196.562 9.44 198.947 9.035 200.837 8.945C202.997 8.9 205.877 9.845 206.237 12.23H206.327C207.452 10.025 209.297 8.945 212.177 8.945C216.497 8.945 218.387 11.645 218.387 14.345V35H212.537V17.855C212.537 15.56 212.312 13.31 209.747 13.445C207.227 13.58 206.777 15.335 206.777 18.305V35H200.927V17.54C200.927 15.29 200.747 13.4 198.047 13.445C195.302 13.49 195.167 15.515 195.167 18.305V35H189.317V9.62H195.167ZM230.101 19.07V26.675C230.101 29.6 231.046 31.175 232.936 31.175C234.736 31.175 235.366 29.24 235.501 26.81V18.35C235.321 15.83 235.591 13.445 232.846 13.445C230.101 13.445 230.011 17.045 230.101 19.07ZM224.251 35V1.25H230.101V9.35C230.101 10.16 230.011 10.97 229.966 12.185H230.056C231.226 9.755 232.801 8.9 235.276 8.945C239.056 9.035 241.216 10.97 241.351 17.945V27.125C241.216 31.175 240.226 35.675 235.276 35.675C232.846 35.54 231.226 34.82 229.921 32.3H229.831V35H224.251ZM246.256 25.01V18.35C245.986 12.365 249.046 8.945 254.806 8.945C262.951 8.945 263.806 13.175 263.806 20.105V23.525H252.106V27.215C252.151 30.545 253.411 31.175 255.166 31.175C257.326 31.175 257.956 29.6 257.866 26.405H263.716C263.941 32.075 261.601 35.675 255.616 35.675C248.866 35.675 246.121 32.48 246.256 25.01ZM252.106 19.025H257.956V16.82C257.911 14.255 257.236 13.445 254.896 13.445C251.971 13.445 252.106 15.695 252.106 17.99V19.025ZM274.696 9.62V14.12H274.786C275.506 12.275 276.226 11.24 277.081 10.52C278.746 9.125 279.871 9.215 280.726 9.17V16.1C277.486 15.785 275.011 16.595 274.921 20.33V35H269.071V9.62H274.696Z" fill="white"/>
            </g>
            <defs>
            <filter id="filter0_i_464_2202" x="0.03125" y="0.440002" width="280.695" height="39.37" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
            <feFlood flood-opacity="0" result="BackgroundImageFix"/>
            <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
            <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
            <feOffset dy="4"/>
            <feGaussianBlur stdDeviation="2"/>
            <feComposite in2="hardAlpha" operator="arithmetic" k2="-1" k3="1"/>
            <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/>
            <feBlend mode="normal" in2="shape" result="effect1_innerShadow_464_2202"/>
            </filter>
            </defs>
        </svg>
    </div>
    <form class="p-4 md:p-5" >
        <div class="my-5">
            <div class="w-full">
                <div class="text-[#f7d4b2] font-semibold font-lg">Name</div>
                <div class="relative">
                    <input type="text" placeholder="" class="shadow-lg focus:ring-2 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full  py-2 text-sm leading-6 text-slate-900 rounded-md" bind:value={member_name} required>
                </div>
            </div>
        </div>
        <div class="my-5">
            <div class="w-full">
                <div class="text-[#f7d4b2] font-semibold font-lg">Phone number</div>
                <div class="relative">
                    <input type="text" placeholder="" class="shadow-lg focus:ring-2 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full  py-2 text-sm leading-6 text-slate-900 rounded-md" bind:value={member_phone_number} required>
                </div>
            </div>
        </div>
        <div class="my-5">
            <div class="w-full">
                <div class="text-[#f7d4b2] font-semibold font-lg">Join Date</div>
                <div class="relative">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="stroke-[2px] absolute h-5 w-5 top-2.5 left-3 text-[#3d4c52] ">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                    </svg>
                    <input type="text" placeholder="" class="shadow-lg focus:ring-2 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full px-10 py-2 text-sm leading-6 text-slate-900 rounded-md " bind:value={member_join_date} readonly>
                </div>
            </div>
        </div>
        <div class="flex items-center justify-center font-roboto">
            <button
            on:click={() => NewMember()}
               type="submit" 
               class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center ">
               Save
            </button>
         </div>

    </form>
 </TaskModal>
{:else if showModal === 2}
    <TaskModal open={showModal} onClose={() => closeModal()} color={"#3d4c52"}>
        <div class="flex items-center justify-center pt-8">
            <svg width="307" height="43" viewBox="0 0 307 43" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g filter="url(#filter0_i_464_2317)">
                <path d="M15.983 23.245V0.249997H22.283V23.785C22.283 31.255 19.853 34.81 11.618 34.81C3.29301 34.81 0.863009 31.255 0.863009 23.785V0.249997H7.16301V23.245C7.16301 26.485 7.38801 29.725 11.663 29.725C15.758 29.725 15.983 26.485 15.983 23.245ZM26.6178 25.63H32.4678C32.0178 30.31 33.8178 30.175 35.1678 30.175C36.8328 30.175 38.0028 28.96 37.5978 27.34C37.5078 25.9 35.8428 25.09 34.7178 24.325L31.5228 22.12C28.5978 20.095 26.7078 17.755 26.7078 14.11C26.7078 10.195 29.8128 7.945 35.4378 7.945C41.1078 7.945 43.7178 10.915 43.5828 16.36H37.7328C37.8678 13.525 37.0578 12.445 35.0328 12.445C33.6378 12.445 32.5578 13.075 32.5578 14.515C32.5578 16 33.6378 16.675 34.7628 17.44L39.5328 20.68C41.0178 21.535 43.3578 23.965 43.5378 25.675C44.0328 30.085 42.9528 34.675 34.8528 34.675C31.7478 34.675 25.9428 33.37 26.6178 25.63ZM47.6929 24.01V17.35C47.4229 11.365 50.4829 7.945 56.2429 7.945C64.3879 7.945 65.2429 12.175 65.2429 19.105V22.525H53.5429V26.215C53.5879 29.545 54.8479 30.175 56.6029 30.175C58.7629 30.175 59.3929 28.6 59.3029 25.405H65.1529C65.3779 31.075 63.0379 34.675 57.0529 34.675C50.3029 34.675 47.5579 31.48 47.6929 24.01ZM53.5429 18.025H59.3929V15.82C59.3479 13.255 58.6729 12.445 56.3329 12.445C53.4079 12.445 53.5429 14.695 53.5429 16.99V18.025ZM88.3729 23.38V34H82.0729V0.249997H92.1079L95.4829 15.91C96.0229 18.475 96.3829 21.085 96.6529 23.695H96.7429C97.0579 20.365 97.2829 18.115 97.7329 15.91L101.108 0.249997H111.098V34H104.798V23.38C104.798 16.675 104.933 9.97 105.338 3.265H105.248L98.4979 34H94.6729L88.0579 3.265H87.8329C88.2379 9.97 88.3729 16.675 88.3729 23.38ZM116.467 24.01V17.35C116.197 11.365 119.257 7.945 125.017 7.945C133.162 7.945 134.017 12.175 134.017 19.105V22.525H122.317V26.215C122.362 29.545 123.622 30.175 125.377 30.175C127.537 30.175 128.167 28.6 128.077 25.405H133.927C134.152 31.075 131.812 34.675 125.827 34.675C119.077 34.675 116.332 31.48 116.467 24.01ZM122.317 18.025H128.167V15.82C128.122 13.255 127.447 12.445 125.107 12.445C122.182 12.445 122.317 14.695 122.317 16.99V18.025ZM145.402 8.62V11.23H145.492C146.797 8.44 149.182 8.035 151.072 7.945C153.232 7.9 156.112 8.845 156.472 11.23H156.562C157.687 9.025 159.532 7.945 162.412 7.945C166.732 7.945 168.622 10.645 168.622 13.345V34H162.772V16.855C162.772 14.56 162.547 12.31 159.982 12.445C157.462 12.58 157.012 14.335 157.012 17.305V34H151.162V16.54C151.162 14.29 150.982 12.4 148.282 12.445C145.537 12.49 145.402 14.515 145.402 17.305V34H139.552V8.62H145.402ZM180.337 18.07V25.675C180.337 28.6 181.282 30.175 183.172 30.175C184.972 30.175 185.602 28.24 185.737 25.81V17.35C185.557 14.83 185.827 12.445 183.082 12.445C180.337 12.445 180.247 16.045 180.337 18.07ZM174.487 34V0.249997H180.337V8.35C180.337 9.16 180.247 9.97 180.202 11.185H180.292C181.462 8.755 183.037 7.9 185.512 7.945C189.292 8.035 191.452 9.97 191.587 16.945V26.125C191.452 30.175 190.462 34.675 185.512 34.675C183.082 34.54 181.462 33.82 180.157 31.3H180.067V34H174.487ZM196.492 24.01V17.35C196.222 11.365 199.282 7.945 205.042 7.945C213.187 7.945 214.042 12.175 214.042 19.105V22.525H202.342V26.215C202.387 29.545 203.647 30.175 205.402 30.175C207.562 30.175 208.192 28.6 208.102 25.405H213.952C214.177 31.075 211.837 34.675 205.852 34.675C199.102 34.675 196.357 31.48 196.492 24.01ZM202.342 18.025H208.192V15.82C208.147 13.255 207.472 12.445 205.132 12.445C202.207 12.445 202.342 14.695 202.342 16.99V18.025ZM224.932 8.62V13.12H225.022C225.742 11.275 226.462 10.24 227.317 9.52C228.982 8.125 230.107 8.215 230.962 8.17V15.1C227.722 14.785 225.247 15.595 225.157 19.33V34H219.307V8.62H224.932ZM232.897 25.63H238.747C238.297 30.31 240.097 30.175 241.447 30.175C243.112 30.175 244.282 28.96 243.877 27.34C243.787 25.9 242.122 25.09 240.997 24.325L237.802 22.12C234.877 20.095 232.987 17.755 232.987 14.11C232.987 10.195 236.092 7.945 241.717 7.945C247.387 7.945 249.997 10.915 249.862 16.36H244.012C244.147 13.525 243.337 12.445 241.312 12.445C239.917 12.445 238.837 13.075 238.837 14.515C238.837 16 239.917 16.675 241.042 17.44L245.812 20.68C247.297 21.535 249.637 23.965 249.817 25.675C250.312 30.085 249.232 34.675 241.132 34.675C238.027 34.675 232.222 33.37 232.897 25.63ZM260.182 34H254.332V0.249997H260.182V11.23H260.272C261.937 8.26 264.277 7.945 265.537 7.945C268.867 7.945 271.567 9.88 271.387 14.425V34H265.537V16.63C265.537 14.155 265.267 12.535 263.062 12.445C260.857 12.355 260.092 14.425 260.182 17.125V34ZM283.267 34H277.417V8.62H283.267V34ZM283.267 5.56H277.417V0.249997H283.267V5.56ZM295.072 18.07V25.675C295.072 28.6 296.017 30.175 297.907 30.175C299.707 30.175 300.337 28.24 300.472 25.81V17.35C300.292 14.83 300.562 12.445 297.817 12.445C295.072 12.445 294.982 16.045 295.072 18.07ZM295.072 8.62V11.275H295.162C296.242 8.8 297.817 7.9 300.247 7.945C304.027 8.035 306.187 10.06 306.322 17.035V26.215C306.187 30.265 305.197 34.675 300.247 34.675C297.952 34.54 296.332 33.955 294.892 31.39H294.802V42.505H289.222V8.62H295.072Z" fill="white"/>
                </g>
                <defs>
                <filter id="filter0_i_464_2317" x="0.859375" y="0.25" width="305.461" height="46.255" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
                <feFlood flood-opacity="0" result="BackgroundImageFix"/>
                <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
                <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
                <feOffset dy="4"/>
                <feGaussianBlur stdDeviation="2"/>
                <feComposite in2="hardAlpha" operator="arithmetic" k2="-1" k3="1"/>
                <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/>
                <feBlend mode="normal" in2="shape" result="effect1_innerShadow_464_2317"/>
                </filter>
                </defs>
            </svg>
        </div>
        <form class="p-4 md:p-5 font-roboto" >
            <div class="my-5">
                <div class="w-full">
                    <div class="text-[#f7d4b2] font-semibold font-lg">Phone number</div>
    
                    <div class="relative">
                        <input type="text" placeholder="" class="shadow-lg focus:ring-2 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full  py-2 text-sm leading-6 text-slate-900 rounded-md" bind:value={member_phone_number} required>
                    </div>
                </div>
            </div>
            <div class="flex items-center justify-center">
                <button
                on:click={() => checkPhoneNumber()}
                   type="submit" 
                   class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center ">
                   Load
                </button>
             </div>
        </form>
    </TaskModal>
{:else}
    <TaskModal open={showModal} onClose={() => closeModal()} color={"#3d4c52"}>
        <div class="flex items-center justify-center pt-8 pb-4">
            <svg width="307" height="43" viewBox="0 0 307 43" fill="none" xmlns="http://www.w3.org/2000/svg">
                <g filter="url(#filter0_i_464_2317)">
                <path d="M15.983 23.245V0.249997H22.283V23.785C22.283 31.255 19.853 34.81 11.618 34.81C3.29301 34.81 0.863009 31.255 0.863009 23.785V0.249997H7.16301V23.245C7.16301 26.485 7.38801 29.725 11.663 29.725C15.758 29.725 15.983 26.485 15.983 23.245ZM26.6178 25.63H32.4678C32.0178 30.31 33.8178 30.175 35.1678 30.175C36.8328 30.175 38.0028 28.96 37.5978 27.34C37.5078 25.9 35.8428 25.09 34.7178 24.325L31.5228 22.12C28.5978 20.095 26.7078 17.755 26.7078 14.11C26.7078 10.195 29.8128 7.945 35.4378 7.945C41.1078 7.945 43.7178 10.915 43.5828 16.36H37.7328C37.8678 13.525 37.0578 12.445 35.0328 12.445C33.6378 12.445 32.5578 13.075 32.5578 14.515C32.5578 16 33.6378 16.675 34.7628 17.44L39.5328 20.68C41.0178 21.535 43.3578 23.965 43.5378 25.675C44.0328 30.085 42.9528 34.675 34.8528 34.675C31.7478 34.675 25.9428 33.37 26.6178 25.63ZM47.6929 24.01V17.35C47.4229 11.365 50.4829 7.945 56.2429 7.945C64.3879 7.945 65.2429 12.175 65.2429 19.105V22.525H53.5429V26.215C53.5879 29.545 54.8479 30.175 56.6029 30.175C58.7629 30.175 59.3929 28.6 59.3029 25.405H65.1529C65.3779 31.075 63.0379 34.675 57.0529 34.675C50.3029 34.675 47.5579 31.48 47.6929 24.01ZM53.5429 18.025H59.3929V15.82C59.3479 13.255 58.6729 12.445 56.3329 12.445C53.4079 12.445 53.5429 14.695 53.5429 16.99V18.025ZM88.3729 23.38V34H82.0729V0.249997H92.1079L95.4829 15.91C96.0229 18.475 96.3829 21.085 96.6529 23.695H96.7429C97.0579 20.365 97.2829 18.115 97.7329 15.91L101.108 0.249997H111.098V34H104.798V23.38C104.798 16.675 104.933 9.97 105.338 3.265H105.248L98.4979 34H94.6729L88.0579 3.265H87.8329C88.2379 9.97 88.3729 16.675 88.3729 23.38ZM116.467 24.01V17.35C116.197 11.365 119.257 7.945 125.017 7.945C133.162 7.945 134.017 12.175 134.017 19.105V22.525H122.317V26.215C122.362 29.545 123.622 30.175 125.377 30.175C127.537 30.175 128.167 28.6 128.077 25.405H133.927C134.152 31.075 131.812 34.675 125.827 34.675C119.077 34.675 116.332 31.48 116.467 24.01ZM122.317 18.025H128.167V15.82C128.122 13.255 127.447 12.445 125.107 12.445C122.182 12.445 122.317 14.695 122.317 16.99V18.025ZM145.402 8.62V11.23H145.492C146.797 8.44 149.182 8.035 151.072 7.945C153.232 7.9 156.112 8.845 156.472 11.23H156.562C157.687 9.025 159.532 7.945 162.412 7.945C166.732 7.945 168.622 10.645 168.622 13.345V34H162.772V16.855C162.772 14.56 162.547 12.31 159.982 12.445C157.462 12.58 157.012 14.335 157.012 17.305V34H151.162V16.54C151.162 14.29 150.982 12.4 148.282 12.445C145.537 12.49 145.402 14.515 145.402 17.305V34H139.552V8.62H145.402ZM180.337 18.07V25.675C180.337 28.6 181.282 30.175 183.172 30.175C184.972 30.175 185.602 28.24 185.737 25.81V17.35C185.557 14.83 185.827 12.445 183.082 12.445C180.337 12.445 180.247 16.045 180.337 18.07ZM174.487 34V0.249997H180.337V8.35C180.337 9.16 180.247 9.97 180.202 11.185H180.292C181.462 8.755 183.037 7.9 185.512 7.945C189.292 8.035 191.452 9.97 191.587 16.945V26.125C191.452 30.175 190.462 34.675 185.512 34.675C183.082 34.54 181.462 33.82 180.157 31.3H180.067V34H174.487ZM196.492 24.01V17.35C196.222 11.365 199.282 7.945 205.042 7.945C213.187 7.945 214.042 12.175 214.042 19.105V22.525H202.342V26.215C202.387 29.545 203.647 30.175 205.402 30.175C207.562 30.175 208.192 28.6 208.102 25.405H213.952C214.177 31.075 211.837 34.675 205.852 34.675C199.102 34.675 196.357 31.48 196.492 24.01ZM202.342 18.025H208.192V15.82C208.147 13.255 207.472 12.445 205.132 12.445C202.207 12.445 202.342 14.695 202.342 16.99V18.025ZM224.932 8.62V13.12H225.022C225.742 11.275 226.462 10.24 227.317 9.52C228.982 8.125 230.107 8.215 230.962 8.17V15.1C227.722 14.785 225.247 15.595 225.157 19.33V34H219.307V8.62H224.932ZM232.897 25.63H238.747C238.297 30.31 240.097 30.175 241.447 30.175C243.112 30.175 244.282 28.96 243.877 27.34C243.787 25.9 242.122 25.09 240.997 24.325L237.802 22.12C234.877 20.095 232.987 17.755 232.987 14.11C232.987 10.195 236.092 7.945 241.717 7.945C247.387 7.945 249.997 10.915 249.862 16.36H244.012C244.147 13.525 243.337 12.445 241.312 12.445C239.917 12.445 238.837 13.075 238.837 14.515C238.837 16 239.917 16.675 241.042 17.44L245.812 20.68C247.297 21.535 249.637 23.965 249.817 25.675C250.312 30.085 249.232 34.675 241.132 34.675C238.027 34.675 232.222 33.37 232.897 25.63ZM260.182 34H254.332V0.249997H260.182V11.23H260.272C261.937 8.26 264.277 7.945 265.537 7.945C268.867 7.945 271.567 9.88 271.387 14.425V34H265.537V16.63C265.537 14.155 265.267 12.535 263.062 12.445C260.857 12.355 260.092 14.425 260.182 17.125V34ZM283.267 34H277.417V8.62H283.267V34ZM283.267 5.56H277.417V0.249997H283.267V5.56ZM295.072 18.07V25.675C295.072 28.6 296.017 30.175 297.907 30.175C299.707 30.175 300.337 28.24 300.472 25.81V17.35C300.292 14.83 300.562 12.445 297.817 12.445C295.072 12.445 294.982 16.045 295.072 18.07ZM295.072 8.62V11.275H295.162C296.242 8.8 297.817 7.9 300.247 7.945C304.027 8.035 306.187 10.06 306.322 17.035V26.215C306.187 30.265 305.197 34.675 300.247 34.675C297.952 34.54 296.332 33.955 294.892 31.39H294.802V42.505H289.222V8.62H295.072Z" fill="white"/>
                </g>
                <defs>
                <filter id="filter0_i_464_2317" x="0.859375" y="0.25" width="305.461" height="46.255" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
                <feFlood flood-opacity="0" result="BackgroundImageFix"/>
                <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
                <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
                <feOffset dy="4"/>
                <feGaussianBlur stdDeviation="2"/>
                <feComposite in2="hardAlpha" operator="arithmetic" k2="-1" k3="1"/>
                <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/>
                <feBlend mode="normal" in2="shape" result="effect1_innerShadow_464_2317"/>
                </filter>
                </defs>
            </svg>
        </div>
        <form class="p-4 md:p-5 font-roboto" >
            <div class="grid gap-3 font-roboto font-semibold">
                <div class="flex justify-between">
                    <div class="text-[#f7d4b2]">Phone number</div>
                    <div class="text-white">{member.member_phone_number}</div>
                 </div>
                <div class="flex justify-between">
                  <div class="text-[#f7d4b2]">Name</div>
                  <div class="text-white">{member.member_name}</div>
               </div>
               
               <div class="flex justify-between">
                  <div class="text-[#f7d4b2]">Join date</div>
                  <div class="text-white">
                    <DateConverter value={member.member_join_date} date={true} hour={false} second={false} ampm={false} monthNumber={true} dash={false} dateFirst={false}/>
                  </div>
               </div>
               <div class="flex justify-between">
                    <div class="text-[#f7d4b2]">Points</div>
                    <div class="text-white">{member.member_points}</div>
               </div>
               <div class="flex justify-between">
                    <div class="text-[#f7d4b2]">Use points</div>
                    <button on:click={toggleUse} class="ml-2">
                    {#if !use}
                        <i class="text-white fa-regular fa-square-check fa-lg"></i>
                    {:else}
                        <i class="text-[#f7d4b2] fa-solid fa-square-check fa-lg"></i>
                    {/if}
                    </button>

               </div>
               
               <div class="flex items-center justify-center">
                    {#if member.member_points > 0}  
                <button
                  on:click={() => {usePoints()}}
                     type="submit" 
                     class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center ">
                     Save
                  </button>
                  {:else}
                    <button
                        on:click={() => closeModal()}
                        type="button" 
                        class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center ">
                        Close
                    </button>
                  {/if}
               </div>
            </div>
         </form>
    </TaskModal>
{/if}