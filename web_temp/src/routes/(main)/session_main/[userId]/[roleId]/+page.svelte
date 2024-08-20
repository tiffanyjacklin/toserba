<script>
    import SessionHistory from "$lib/SessionHistory.svelte";
    import TransactionHistory from "$lib/TransactionHistory.svelte"
    import TransactionHistoryDetails from "$lib/TransactionHistoryDetails.svelte"
    import ProdukMain from "$lib/ProdukMain.svelte"

    import produk from "$lib/assets/produk.png";

    let window = "payment";

    function plus(idBarang){
        var value = document.getElementById(idBarang).value;
        value++;
        document.getElementById(idBarang).value = value;
    }
    
    function minus(idBarang){
        var value = document.getElementById(idBarang).value;
        if (value > 1){
            value--;
        }
        document.getElementById(idBarang).value = value;
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
            <button class="mx-3 hover:bg-gray-300 p-2 rounded-lg"><i class="fa-solid fa-arrow-right-from-bracket mr-1"></i>Close Session</button>
            <button on:click={() => window = "session_history"} class="mx-3 hover:bg-gray-300 p-2 rounded-lg"><i class="fa-regular fa-clock mr-1"></i>Session History</button>
        </div>
        <div class="h-auto overflow-auto no-scrollbar">
            {#if window == "payment"}
                <ProdukMain></ProdukMain>
            {:else if window == "session_history"}
                <SessionHistory></SessionHistory>
            {:else if window == "transaction_list"}
                <TransactionHistory></TransactionHistory>
            {/if}
            <!-- <TransactionHistoryDetails></TransactionHistoryDetails> -->
            
        
        </div>
        
        
    </div>
    <div class="w-5/12 flex flex-col bg-darkGray h-full border-l-8 border-l-peach">
        <div class="flex justify-around text-white font-semibold mt-4 mb-2">
            <button on:click={() =>  window = "payment"} class="mx-2 p-2 rounded-lg hover:bg-peach hover:text-darkGray"><span><i class="fa-solid fa-dollar-sign mr-2" style="color: #F2AA7E;"></i></span>Payment</button>
            <button on:click={() =>  window = "transaction_list"} class="mx-2 p-2 rounded-lg hover:bg-peach hover:text-darkGray"><span><i class="fa-solid fa-list mr-2" style="color: #F2AA7E;"></i></span>View Transaction List</button>
            <button class="mx-2 p-2 rounded-lg hover:bg-peach hover:text-darkGray flex"><span class="mr-2"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
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
            <!-- Item -->
            <div class="flex py-1 my-1 w-full">
                <div class="w-9/12 text-white">
                    <p class="font-semibold truncate">Gelas Kaca Teh Cangkir Saringan Walauweeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee</p>
                    <p class="font-semibold ml-8">2 unit (Rp 35,000.00/unit)</p>
                </div>
                <div class="w-3/12 text-center">
                    <span class="text-peach font-semibold">Rp 70,000.00</span>
                    <div class="flex">
                        <button on:click={() => minus("produk1")} type="button" class="bg-peach rounded-s-xl h-8 p-2">
                            <svg class="w-3 h-3 text-gray-900" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 18 2">
                                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 1h16"/>
                            </svg>
                        </button>
                        <input id="produk1" value=1 type="text" class="h-8 bg-gray-50 border-x-0 border-gray-300 text-center text-gray-900 text-sm w-16" required />
                        <button on:click={() => plus("produk1")} type="button" class="bg-peach rounded-e-xl h-8 p-2">
                            <svg class="w-3 h-3 text-gray-900" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 18 18">
                                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 1v16M1 9h16"/>
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
            <div class="flex py-1 my-1 w-full">
                <div class="w-9/12 text-white">
                    <p class="font-semibold truncate">Beras Pandan Wangi</p>
                    <p class="font-semibold ml-8">2200 grams (Rp 16.65/grams)</p>
                </div>
                <div class="w-3/12 text-center">
                    <span class="text-peach font-semibold">Rp 36,630.00</span>
                    <div class="flex">
                        <button on:click={() => minus("produk2")} type="button" class="bg-peach rounded-s-xl h-8 p-2">
                            <svg class="w-3 h-3 text-gray-900" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 18 2">
                                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 1h16"/>
                            </svg>
                        </button>
                        <input id="produk2" value=1 type="text" class="h-8 bg-gray-50 border-x-0 border-gray-300 text-center text-gray-900 text-sm w-16" required />
                        <button on:click={() => plus("produk2")} type="button" class="bg-peach rounded-e-xl h-8 p-2">
                            <svg class="w-3 h-3 text-gray-900" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 18 18">
                                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 1v16M1 9h16"/>
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
            <!-- PROMO -->
            <div class="flex py-1 my-1 w-full">
                <div class="w-9/12 text-white">
                    <p class="font-semibold truncate text-peach2">Sabun Mandi 750ml</p>
                    <p class="font-semibold ml-8">1 unit (Rp 30,000.00/unit)</p>
                    <p class="font-semibold ml-8 text-peach2">This item has a promo! Promo not yet applied.</p>
                </div>
                <div class="w-3/12 text-center">
                    <span class="text-peach font-semibold">Rp 30,000.00</span>
                    <div class="flex">
                        <button on:click={() => minus("produk3")} type="button" class="bg-peach rounded-s-xl h-8 p-2">
                            <svg class="w-3 h-3 text-gray-900" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 18 2">
                                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 1h16"/>
                            </svg>
                        </button>
                        <input id="produk3" value=1 type="text" class="h-8 bg-gray-50 border-x-0 border-gray-300 text-center text-gray-900 text-sm w-16" required />
                        <button on:click={() => plus("produk3")} type="button" class="bg-peach rounded-e-xl h-8 p-2">
                            <svg class="w-3 h-3 text-gray-900" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 18 18">
                                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 1v16M1 9h16"/>
                            </svg>
                        </button>
                    </div>
                </div>
            </div>
            

        </div>

        <div class="text-end">
            <span class="text-peach font-semibold">Total: Rp 136,630.00</span>
        </div>
        <button class="w-auto bg-peach2 text-darkGray p-2 px-auto rounded-2xl mx-3 my-2 font-semibold">1 item(s) with promo, 0 promo(s) applied</button>
        
        <button class="w-48 bg-peach text-darkGray p-2 px-auto rounded-2xl mx-auto mt-2 mb-4 font-semibold">Pay</button>
        
    </div>
</div>