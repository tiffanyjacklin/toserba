<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import receipt from '$lib/assets/receipt-1.png';
    
    export let transactionId = 1;
    export let userId = 0;
    export let roleId = 0;

    let showModal = false;
    function closeModal() {
      showModal = false;
    }
    function handleClick() {
      showModal = true;
    }
  </script>
  
  <div class="select-none font-roboto text-[#364445] mx-8 mt-[90px] mb-10 flex flex-col items-center justify-center bg-white shadow-[0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="flex flex-col w-full pb-10 items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
      <div class="text-lg">
        <i class="fa-solid fa-angle-left"></i>
        Back
      </div>
      <span class="text-4xl font-bold   mt-10">TRANSACTION #5260560369532650</span>
          
      <div class="w-full p-10 font-semibold text-xl ">
        <div class="flex justify-between mb-3">
          <div class="">
            Cashier
          </div>
          <div class="">
            Budi Setiawan
          </div>
        </div>
        <div class="flex justify-between mb-3">
            <div class="">
              Time
            </div>
            <div class="">
              08:03 AM, 12 July 2024
            </div>
        </div>
        <div class="flex justify-between">
            <div class="">
              Products
              
            </div>
            <div class="">
  
            </div>
        </div>
        <div class="flex justify-between mb-3">
            <div class="indent-8">
                Permen karet x2
            </div>
            <MoneyConverter value={16000} currency={true} decimal={true}></MoneyConverter>
      </div>
        <div class="flex justify-between mb-3">
            <div class="">
              Total amount 
            </div>
            <MoneyConverter value={16000} currency={true} decimal={true}></MoneyConverter>
        </div>
        <div class="flex justify-between">
            <div class="">
              Payment method
            </div>
            <div class="">
              Cash
            </div>
        </div>
      </div>
      <div class="flex items-center justify-center">
        <button on:click={() => handleClick()} type="button" class="mt-2 flex items-center justify-center text-[#3d4c52] bg-[#F2AA7E] shadow-[0_4px_3px_rgba(0,0,0,0.5)] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg  px-12 py-3 text-center">
          View Receipt
        </button>
      </div>
    </div>
  </div>
  
  
  <TaskModal open={showModal} onClose={() => closeModal()} color={"#3d4c52"}>
    <div class="select-none	flex items-center justify-center py-8 ">
      <svg width="326" height="27" viewBox="0 0 435 36" fill="none" xmlns="http://www.w3.org/2000/svg">
        <g filter="url(#filter0_i_928_2519)">
        <path d="M0.0765235 6.2V1.25H21.0915V6.2H13.7565V35H7.45652V6.2H0.0765235ZM32.2065 20.465H31.0815V35H24.7815V1.25H36.7065C42.1515 1.25 46.2915 3.14 46.2915 9.35C46.2915 13.04 45.3465 16.91 41.1165 17.495V17.585C44.8515 18.08 45.9765 20.465 45.9765 23.705C45.9765 25.1 45.7965 33.38 47.3265 34.37V35H40.3965C39.6315 32.84 39.7665 28.7 39.7215 26.45C39.6765 24.38 39.7215 21.545 37.5615 20.915C35.8515 20.42 34.0065 20.465 32.2065 20.465ZM31.0815 6.2V15.515H36.0315C38.1015 15.38 39.7215 14.03 39.7215 10.655C39.7215 6.875 38.1465 6.245 35.7615 6.2H31.0815ZM56.4763 35H49.7263L57.7813 1.25H66.2863L73.9363 35H67.1863L65.5213 26.45H58.1413L56.4763 35ZM61.0213 11.915L59.1313 21.5H64.5313L62.8213 11.915C62.5063 10.34 62.3713 8.81 62.1913 7.235C62.1463 6.47 62.0563 5.705 61.9663 4.985H61.8763C61.7863 5.705 61.6963 6.47 61.6513 7.235C61.4713 8.81 61.3363 10.34 61.0213 11.915ZM92.4612 7.865V1.25H98.7612V35H92.1912L87.2862 22.985C85.6212 18.98 84.2712 14.885 82.7862 9.575H82.6962C82.9212 12.365 83.1912 15.785 83.3712 19.205C83.5512 22.58 83.6862 25.955 83.6862 28.655V35H77.3862V1.25H83.9112L88.8162 13.535C90.4362 17.45 91.7862 21.455 93.3162 26.945H93.4062C93.1812 23.885 92.9562 20.6 92.7762 17.36C92.5962 14.12 92.4612 10.88 92.4612 7.865ZM123.841 11.51H117.766C117.811 8.495 117.541 5.525 114.076 5.525C111.961 5.525 110.611 6.38 110.611 8.675C110.611 11.24 112.231 12.23 114.211 13.49C116.281 14.795 120.106 17.315 121.861 19.025C124.021 21.14 124.696 23.165 124.696 26.09C124.696 32.48 120.466 35.81 114.301 35.81C106.741 35.81 104.041 31.58 104.041 25.55V23.075H110.341V25.055C110.206 28.34 111.196 30.725 114.301 30.725C116.956 30.725 118.216 29.33 118.216 26.765C118.216 24.785 117.316 23.435 115.696 22.31C112.411 19.745 108.316 17.9 105.751 14.525C104.716 12.995 104.131 11.15 104.131 9.35C104.131 3.59 107.371 0.44 114.031 0.44C124.066 0.44 123.796 8.18 123.841 11.51ZM133.996 35H127.246L135.301 1.25H143.806L151.456 35H144.706L143.041 26.45H135.661L133.996 35ZM138.541 11.915L136.651 21.5H142.051L140.341 11.915C140.026 10.34 139.891 8.81 139.711 7.235C139.666 6.47 139.576 5.705 139.486 4.985H139.396C139.306 5.705 139.216 6.47 139.171 7.235C138.991 8.81 138.856 10.34 138.541 11.915ZM168.541 22.985H174.886C174.841 23.615 174.796 24.29 174.751 24.92C174.436 31.085 172.366 35.81 165.346 35.81C154.996 35.81 154.321 29.24 154.321 20.24V15.425C154.591 6.83 155.266 0.44 165.346 0.44C170.971 0.529999 174.121 3.41 174.571 9.17C174.661 10.025 174.751 10.88 174.706 11.735H168.496C168.226 9.575 168.451 5.525 165.346 5.525C160.396 5.525 160.801 11.42 160.801 14.03V23.39C160.801 26.18 161.026 30.725 165.346 30.725C168.811 30.725 168.406 25.145 168.541 22.985ZM177.616 6.2V1.25H198.631V6.2H191.296V35H184.996V6.2H177.616ZM208.756 35H202.456V1.25H208.756V35ZM214.62 20.24V15.425C214.89 6.83 215.565 0.44 225.645 0.44C235.725 0.44 236.4 6.83 236.67 15.425V20.24C236.67 29.24 235.995 35.81 225.645 35.81C215.295 35.81 214.62 29.24 214.62 20.24ZM221.1 14.03V23.39C221.1 26.18 221.325 30.725 225.645 30.725C230.145 30.725 230.19 26.09 230.19 22.85V14.21C230.19 11.51 230.325 5.525 225.645 5.525C220.695 5.525 221.1 11.42 221.1 14.03ZM257.52 7.865V1.25H263.82V35H257.25L252.345 22.985C250.68 18.98 249.33 14.885 247.845 9.575H247.755C247.98 12.365 248.25 15.785 248.43 19.205C248.61 22.58 248.745 25.955 248.745 28.655V35H242.445V1.25H248.97L253.875 13.535C255.495 17.45 256.845 21.455 258.375 26.945H258.465C258.24 23.885 258.015 20.6 257.835 17.36C257.655 14.12 257.52 10.88 257.52 7.865ZM288.54 20.465H287.415V35H281.115V1.25H293.04C298.485 1.25 302.625 3.14 302.625 9.35C302.625 13.04 301.68 16.91 297.45 17.495V17.585C301.185 18.08 302.31 20.465 302.31 23.705C302.31 25.1 302.13 33.38 303.66 34.37V35H296.73C295.965 32.84 296.1 28.7 296.055 26.45C296.01 24.38 296.055 21.545 293.895 20.915C292.185 20.42 290.34 20.465 288.54 20.465ZM287.415 6.2V15.515H292.365C294.435 15.38 296.055 14.03 296.055 10.655C296.055 6.875 294.48 6.245 292.095 6.2H287.415ZM326.264 35H308.534V1.25H326.264V6.2H314.834V14.705H325.364V19.655H314.834V30.05H326.264V35ZM344.849 22.985H351.194C351.149 23.615 351.104 24.29 351.059 24.92C350.744 31.085 348.674 35.81 341.654 35.81C331.304 35.81 330.629 29.24 330.629 20.24V15.425C330.899 6.83 331.574 0.44 341.654 0.44C347.279 0.529999 350.429 3.41 350.879 9.17C350.969 10.025 351.059 10.88 351.014 11.735H344.804C344.534 9.575 344.759 5.525 341.654 5.525C336.704 5.525 337.109 11.42 337.109 14.03V23.39C337.109 26.18 337.334 30.725 341.654 30.725C345.119 30.725 344.714 25.145 344.849 22.985ZM373.769 35H356.039V1.25H373.769V6.2H362.339V14.705H372.869V19.655H362.339V30.05H373.769V35ZM385.064 35H378.764V1.25H385.064V35ZM397.544 6.2V15.92H400.919C403.664 15.92 405.509 14.75 405.509 10.655C405.509 6.785 403.979 6.2 400.424 6.2H397.544ZM397.544 35H391.244V1.25H404.114C410.144 1.25 411.989 6.11 411.989 10.835C411.989 13.715 411.224 16.955 408.839 18.845C406.859 20.42 404.204 20.915 401.774 20.87H397.544V35ZM413.953 6.2V1.25H434.968V6.2H427.633V35H421.333V6.2H413.953Z" fill="white"/>
        </g>
        <defs>
        <filter id="filter0_i_928_2519" x="0.078125" y="0.439941" width="434.891" height="39.3701" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
        <feFlood flood-opacity="0" result="BackgroundImageFix"/>
        <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
        <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
        <feOffset dy="4"/>
        <feGaussianBlur stdDeviation="2"/>
        <feComposite in2="hardAlpha" operator="arithmetic" k2="-1" k3="1"/>
        <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/>
        <feBlend mode="normal" in2="shape" result="effect1_innerShadow_928_2519"/>
        </filter>
        </defs>
      </svg>
    </div>
    <div class="select-none	mx-8 bg-white p-3 font-roboto text-lg">
      <div class="flex justify-center my-2">
        Toserba XYZ
      </div>
      <div class="flex justify-center">
        Jl. X No. X-XXI KEL. X KEC. X SURABAYA
      </div>
      <div>
        ==================================================
      </div>
      <div class="flex justify-between">
        <div>BON XYXY-123-XYZ123XYZ</div>
        <div>Kasir: Budi</div>
      </div>
      <div>
        ==================================================
      </div>
      <div class="flex justify-between">
        <div class="uppercase flex-[1.5_1.5_0%]">
          Permen Karet
        </div>
        <div class="flex flex-1 justify-end">
          2
        </div>
        <div class="flex flex-1 justify-end">
            <MoneyConverter value={8000} currency={false} decimal={false}></MoneyConverter>
        </div>
        <div class="flex flex-1 justify-end">
            <MoneyConverter value={16000} currency={false} decimal={false}></MoneyConverter>
        </div>
      </div>
      <div>
        ==================================================
      </div>
      <div class="flex justify-between my-2">
        <div class="flex ">
          <div class="w-24">
            Total item
          </div>
          <div>
            2
          </div>
        </div>
        <div>
            <MoneyConverter value={16000} currency={false} decimal={false}></MoneyConverter>
        </div>
      </div>
      <div class="flex justify-between my-2">
        <div>
          Total belanja
        </div>
        <div>
            <MoneyConverter value={16000} currency={false} decimal={false}></MoneyConverter>
        </div>
      </div>
      <div class="flex justify-between my-2">
        <div>
          Tunai
        </div>
        <div>
            <MoneyConverter value={20000} currency={false} decimal={false}></MoneyConverter>
        </div>
      </div>
      <div class="flex justify-between my-2">
        <div>
          Kembalian
        </div>
        <div>
            <MoneyConverter value={4000} currency={false} decimal={false}></MoneyConverter>
        </div>
      </div>
      <div>
        ==================================================
      </div>
      <div class="flex justify-center my-2">
        Tgl. 01-01-2024 06:54:17
      </div>
      <!-- <img src={receipt} class=""> -->
    </div>
    <div class="flex items-center justify-center font-roboto">
      <button on:click={() => closeModal()} type="button" class="mt-6 mb-3 flex items-center justify-center text-[#3d4c52] bg-[#F2AA7E] shadow-[0_2px_3px_rgba(0,0,0,0.3)] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold text-lg rounded-lg  px-12 py-1.5 text-center">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
          <path stroke-linecap="round" stroke-linejoin="round" d="M6.72 13.829c-.24.03-.48.062-.72.096m.72-.096a42.415 42.415 0 0 1 10.56 0m-10.56 0L6.34 18m10.94-4.171c.24.03.48.062.72.096m-.72-.096L17.66 18m0 0 .229 2.523a1.125 1.125 0 0 1-1.12 1.227H7.231c-.662 0-1.18-.568-1.12-1.227L6.34 18m11.318 0h1.091A2.25 2.25 0 0 0 21 15.75V9.456c0-1.081-.768-2.015-1.837-2.175a48.055 48.055 0 0 0-1.913-.247M6.34 18H5.25A2.25 2.25 0 0 1 3 15.75V9.456c0-1.081.768-2.015 1.837-2.175a48.041 48.041 0 0 1 1.913-.247m10.5 0a48.536 48.536 0 0 0-10.5 0m10.5 0V3.375c0-.621-.504-1.125-1.125-1.125h-8.25c-.621 0-1.125.504-1.125 1.125v3.659M18 10.5h.008v.008H18V10.5Zm-3 0h.008v.008H15V10.5Z" />
        </svg>
        Print Receipt
      </button>
    </div>
  </TaskModal>