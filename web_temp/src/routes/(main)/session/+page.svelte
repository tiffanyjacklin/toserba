<script>
   import TaskModal from '$lib/TaskModal.svelte';
   import MoneyInput from '$lib/MoneyInput.svelte';
   import MoneyConverter from '$lib/MoneyConverter.svelte';
   import DateConverter from '$lib/DateConverter.svelte';
   import { onMount } from 'svelte';
   import { browser } from '$app/environment';
	import { stringify } from 'postcss';
	import { goto } from '$app/navigation';
   // import { goto } from '$app/navigation';
   import { uri, userId, roleId, sessionId, user } from '$lib/uri.js';
   import { get } from 'svelte/store';
   let opening_notes = "Session starting earlier than expected.";
   let showModal = false;
   function closeModal() {
      showModal = false;
      start_time = start_time;
   }
   function handleClick() {
      showModal = true;
      start_time = new Date();
      start_time = start_time.getUTCFullYear() + '-' +
      ('00' + (start_time.getUTCMonth()+1)).slice(-2) + '-' +
      ('00' + start_time.getUTCDate()).slice(-2) + ' ' + 
      ('00' + (start_time.getUTCHours()+7)).slice(-2) + ':' + 
      ('00' + start_time.getUTCMinutes()).slice(-2) + ':' + 
      ('00' + start_time.getUTCSeconds()).slice(-2);
      start_time = String(start_time);
   }

   let opening_cash = 0;
   // console.log(opening_cash);
   // let opening_notes = "";
   // let $userId = parseInt(data.userId);
   // let roleId = data.roleId;

   let last_session = [];
   let full_name = "Loading...";

   let start_time = new Date();
      start_time = start_time.getUTCFullYear() + '-' +
      ('00' + (start_time.getUTCMonth()+1)).slice(-2) + '-' +
      ('00' + start_time.getUTCDate()).slice(-2) + ' ' + 
      ('00' + (start_time.getUTCHours()+7)).slice(-2) + ':' + 
      ('00' + start_time.getUTCMinutes()).slice(-2) + ':' + 
      ('00' + start_time.getUTCSeconds()).slice(-2);
      start_time = String(start_time)

   async function fetchLast() {
        const response = await fetch(`http://${$uri}:8888/cashier/session/last`, {
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

        last_session = data.data;
        console.log("last_session",last_session);
    }

    async function NewSession() {
      
      const response = await fetch(`http://${$uri}:8888/cashier/session/new`, {
            method: 'POST',
            body: JSON.stringify({
               "user_id": Number($userId),
               "start_time": start_time,
               "opening_cash": opening_cash,
               "opening_notes": opening_notes,
            })
      });

      if (!response.ok) {
         
         Swal.fire({
            title: "Error",
            text: "POST new session gagal",
            icon: "error",
            color: "white",
            background: "#364445",
            confirmButtonColor: '#F2AA7E'
         });
         // console.error('POST new session gagal', response);
         return;
      }

      const data = await response.json();

      if (data.status !== 200) {
         Swal.fire({
            title: "Error",
            text: "Invalid post new session",
            icon: "error",
            color: "white",
            background: "#364445",
            confirmButtonColor: '#F2AA7E'
         });
         // console.error('Invalid post new session', data);
         return;
      }
      console.log(data);
      sessionId.set(String(data.data.session_id));
      Swal.fire({
         title: "Session berhasil dimulai.",
         icon: "success",
         color: "white",
         background: "#364445",
         timer: 1000,
         showConfirmButton: false,
      });
      closeModal();
      goto(`/session_main`);
      // goto(`/session_main`);
   }

   function backToSession() {
      sessionId.set(String(last_session.session_id));
      goto(`/session_main`);
   }

    async function fetchUser() {
      // const user_id = get(userId);
      // const role_id = get(roleId);

      const response = await fetch(`http://${$uri}:8888/user/${$userId}/${$roleId}`, {
            method: 'GET',
            headers: {
               'Content-Type': 'application/json'
            }
      });

      if (!response.ok) {
            const errorText = await response.text();
            console.error('Roles fetch failed', response.status, errorText);
            return;
      }

      const data = await response.json();

      if (data.status !== 200) {
            console.error('Invalid user roles', data);
            return;
      }

      full_name = data.data.user_fullname;
      
    }

    onMount(() => {
        fetchLast();
        fetchUser();
    });


    function formatCurrency(value) {
        return "Rp " + Number(value).toLocaleString('id-ID', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }
    
    function formatDate(value) {
      let text = String(value);
      const arr = text.split(" ");
      
      let tmp_jam = String(arr[1]).split(":");
      let jam = tmp_jam[0] +":"+ tmp_jam[1];

      let tmp_bulan = String(arr[0]).split("-");
      let bulan = "January";
      if (tmp_bulan[1] != "01"){
         if (tmp_bulan[1] == "02"){bulan = "February"}
         else if (tmp_bulan[1] == "03"){bulan = "March"}
         else if (tmp_bulan[1] == "04"){bulan = "April"}
         else if (tmp_bulan[1] == "05"){bulan = "May"}
         else if (tmp_bulan[1] == "06"){bulan = "June"}
         else if (tmp_bulan[1] == "07"){bulan = "July"}
         else if (tmp_bulan[1] == "08"){bulan = "August"}
         else if (tmp_bulan[1] == "09"){bulan = "September"}
         else if (tmp_bulan[1] == "10"){bulan = "October"}
         else if (tmp_bulan[1] == "11"){bulan = "November"}
         else if (tmp_bulan[1] == "12"){bulan = "Desember"}

      }

      return jam + ", " + tmp_bulan[2] + " " + bulan + " " + tmp_bulan[0];
    }

    
   
</script>
<!-- tes -->
<div class="p-4 pt-20 flex items-center justify-center">
    <div class="p-6 rounded-2xl w-[32rem] bg-[#3d4c52] shadow-[0_6px_0px_0px_rgba(242,176,130,1)]">
      <div class="flex flex-col mb-4 rounded font-roboto font-medium">
         <div class="flex items-center justify-center py-2">
            <svg width="213" height="27" viewBox="0 0 284 36" fill="none" xmlns="http://www.w3.org/2000/svg">
               <g filter="url(#filter0_i_318_57)">
               <path d="M19.9447 11.51H13.8697C13.9147 8.495 13.6447 5.525 10.1797 5.525C8.06473 5.525 6.71473 6.38 6.71473 8.675C6.71473 11.24 8.33473 12.23 10.3147 13.49C12.3847 14.795 16.2097 17.315 17.9647 19.025C20.1247 21.14 20.7997 23.165 20.7997 26.09C20.7997 32.48 16.5697 35.81 10.4047 35.81C2.84473 35.81 0.144728 31.58 0.144728 25.55V23.075H6.44473V25.055C6.30973 28.34 7.29973 30.725 10.4047 30.725C13.0597 30.725 14.3197 29.33 14.3197 26.765C14.3197 24.785 13.4197 23.435 11.7997 22.31C8.51473 19.745 4.41973 17.9 1.85473 14.525C0.819728 12.995 0.234728 11.15 0.234728 9.35C0.234728 3.59 3.47473 0.44 10.1347 0.44C20.1697 0.44 19.8997 8.18 19.9447 11.51ZM25.3296 25.01V18.35C25.0596 12.365 28.1196 8.945 33.8796 8.945C42.0246 8.945 42.8796 13.175 42.8796 20.105V23.525H31.1796V27.215C31.2246 30.545 32.4846 31.175 34.2396 31.175C36.3996 31.175 37.0296 29.6 36.9396 26.405H42.7896C43.0146 32.075 40.6746 35.675 34.6896 35.675C27.9396 35.675 25.1946 32.48 25.3296 25.01ZM31.1796 19.025H37.0296V16.82C36.9846 14.255 36.3096 13.445 33.9696 13.445C31.0446 13.445 31.1796 15.695 31.1796 17.99V19.025ZM46.7496 26.63H52.5996C52.1496 31.31 53.9496 31.175 55.2996 31.175C56.9646 31.175 58.1346 29.96 57.7296 28.34C57.6396 26.9 55.9746 26.09 54.8496 25.325L51.6546 23.12C48.7296 21.095 46.8396 18.755 46.8396 15.11C46.8396 11.195 49.9446 8.945 55.5696 8.945C61.2396 8.945 63.8496 11.915 63.7146 17.36H57.8646C57.9996 14.525 57.1896 13.445 55.1646 13.445C53.7696 13.445 52.6896 14.075 52.6896 15.515C52.6896 17 53.7696 17.675 54.8946 18.44L59.6646 21.68C61.1496 22.535 63.4896 24.965 63.6696 26.675C64.1646 31.085 63.0846 35.675 54.9846 35.675C51.8796 35.675 46.0746 34.37 46.7496 26.63ZM66.7447 26.63H72.5947C72.1447 31.31 73.9447 31.175 75.2947 31.175C76.9597 31.175 78.1297 29.96 77.7247 28.34C77.6347 26.9 75.9697 26.09 74.8447 25.325L71.6497 23.12C68.7247 21.095 66.8347 18.755 66.8347 15.11C66.8347 11.195 69.9397 8.945 75.5647 8.945C81.2347 8.945 83.8447 11.915 83.7097 17.36H77.8597C77.9947 14.525 77.1847 13.445 75.1597 13.445C73.7647 13.445 72.6847 14.075 72.6847 15.515C72.6847 17 73.7647 17.675 74.8897 18.44L79.6597 21.68C81.1447 22.535 83.4847 24.965 83.6647 26.675C84.1597 31.085 83.0797 35.675 74.9797 35.675C71.8747 35.675 66.0697 34.37 66.7447 26.63ZM94.6148 35H88.7648V9.62H94.6148V35ZM94.6148 6.56H88.7648V1.25H94.6148V6.56ZM106.194 18.26V26.72C106.194 29.825 106.464 31.175 109.299 31.175C111.999 31.175 112.224 29.825 112.224 26.72V18.26C112.224 15.875 112.224 13.445 109.299 13.445C106.194 13.445 106.194 15.875 106.194 18.26ZM109.299 35.675C101.604 35.81 100.299 32.03 100.344 23.21C100.389 14.525 100.479 8.945 109.299 8.945C117.984 8.945 118.029 14.525 118.074 23.21C118.119 32.03 116.859 35.81 109.299 35.675ZM129.054 9.62V12.23H129.144C130.449 9.305 133.059 8.945 134.409 8.945C137.739 8.945 140.439 10.88 140.259 15.425V35H134.409V18.08C134.409 15.605 134.139 13.985 131.934 13.895C129.729 13.805 128.964 15.875 129.054 18.575V35H123.204V9.62H129.054ZM163.749 30.05H166.494C172.119 30.05 172.479 27.08 172.479 17.315C172.479 9.35 171.669 6.2 167.889 6.2H163.749V30.05ZM169.104 35H157.449V1.25H170.589C172.119 1.25 175.179 1.925 177.114 5.075C178.554 7.415 178.959 11.15 178.959 16.73C178.959 23.39 178.959 31.085 173.784 34.1C172.389 34.91 170.679 35 169.104 35ZM184.104 25.01V18.35C183.834 12.365 186.894 8.945 192.654 8.945C200.799 8.945 201.654 13.175 201.654 20.105V23.525H189.954V27.215C189.999 30.545 191.259 31.175 193.014 31.175C195.174 31.175 195.804 29.6 195.714 26.405H201.564C201.789 32.075 199.449 35.675 193.464 35.675C186.714 35.675 183.969 32.48 184.104 25.01ZM189.954 19.025H195.804V16.82C195.759 14.255 195.084 13.445 192.744 13.445C189.819 13.445 189.954 15.695 189.954 17.99V19.025ZM215.559 30.5V35.09C212.094 35.495 207.234 35.81 207.234 31.085V13.895H204.849V9.62H207.189V2.645H213.084V9.62H215.559V13.895H213.084V29.645C213.219 30.725 214.839 30.59 215.559 30.5ZM236.543 35H231.008C230.603 34.19 230.558 33.29 230.648 32.39H230.558C229.883 33.425 229.118 34.28 228.218 34.82C227.363 35.36 226.418 35.675 225.428 35.675C220.703 35.675 218.633 33.29 218.633 28.07C218.633 22.265 222.728 20.87 227.318 18.98C229.793 17.945 230.693 16.82 230.198 14.75C229.928 13.625 229.028 13.445 227.453 13.445C224.798 13.445 224.348 14.84 224.393 17.135H218.813C218.768 12.32 220.343 8.945 227.678 8.945C235.643 8.945 236.138 13.13 236.048 16.46V31.445C236.048 32.66 236.228 33.83 236.543 35ZM230.198 24.38V21.635C228.758 22.625 227.003 23.615 225.473 24.875C224.618 25.595 224.483 26.855 224.483 27.935C224.483 29.87 225.068 31.175 227.228 31.175C230.693 31.175 230.063 26.81 230.198 24.38ZM248.423 35H242.573V9.62H248.423V35ZM248.423 6.56H242.573V1.25H248.423V6.56ZM260.948 35H255.098V1.25H260.948V35ZM265.597 26.63H271.447C270.997 31.31 272.797 31.175 274.147 31.175C275.812 31.175 276.982 29.96 276.577 28.34C276.487 26.9 274.822 26.09 273.697 25.325L270.502 23.12C267.577 21.095 265.687 18.755 265.687 15.11C265.687 11.195 268.792 8.945 274.417 8.945C280.087 8.945 282.697 11.915 282.562 17.36H276.712C276.847 14.525 276.037 13.445 274.012 13.445C272.617 13.445 271.537 14.075 271.537 15.515C271.537 17 272.617 17.675 273.742 18.44L278.512 21.68C279.997 22.535 282.337 24.965 282.517 26.675C283.012 31.085 281.932 35.675 273.832 35.675C270.727 35.675 264.922 34.37 265.597 26.63Z" fill="white"/>
               </g>
               <defs>
               <filter id="filter0_i_318_57" x="0.144531" y="0.439941" width="282.867" height="39.3701" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
               <feFlood flood-opacity="0" result="BackgroundImageFix"/>
               <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
               <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
               <feOffset dy="4"/>
               <feGaussianBlur stdDeviation="2"/>
               <feComposite in2="hardAlpha" operator="arithmetic" k2="-1" k3="1"/>
               <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/>
               <feBlend mode="normal" in2="shape" result="effect1_innerShadow_318_57"/>
               </filter>
               </defs>
            </svg>
         </div>
         <div class="text-start ">
            <div class="pb-3 pt-6">
               <div class="text-[#f7d4b2] ">
                  Last Closing Date
               </div>
               <div class="text-white text-2xl">
                  <DateConverter value={last_session.end_time} date={true} hour={true} second={false} ampm={false} monthNumber={false} dash={false} dateFirst={false}/>
               </div>
            </div>
            
            <div class="py-3">
               <div class="text-[#f7d4b2] ">
                  Last Closing Cash Balance
               </div>
               <div class="text-white text-2xl">
                  <MoneyConverter value={last_session.actual_closing_cash} currency={true} decimal={true}/>
               </div>
            </div>
         </div>

         <div class="flex items-center justify-center  pt-12 ">
            {#if (last_session.end_time === "0000-00-00 00:00:00" && last_session.$userId === $userId)}
            <button type="button" 
               on:click={() => backToSession()}
               class="h-10 w-1/2 px-6 text-xl inline-flex items-center justify-center font-bold rounded-md bg-[#f7d4b2] hover:bg-[#f2b082] text-[#3d4c52] hover:shadow-2xl">
                  Continue Session
            </button>
            {:else}
            <button type="button" 
               on:click={() => handleClick()}
               class="h-10 w-1/2 px-6 text-xl inline-flex items-center justify-center font-bold rounded-md bg-[#f7d4b2] hover:bg-[#f2b082] text-[#3d4c52] hover:shadow-2xl">
                  New Session
            </button>
            {/if}
         </div>
         
      </div>
    </div>
</div>

<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
   <div class="flex items-center justify-center py-8 ">
      <svg width="213" height="27" viewBox="0 0 284 36" fill="none" xmlns="http://www.w3.org/2000/svg">
         <g filter="url(#filter0_i_434_825)">
         <path d="M19.9904 11.3171H13.9154C13.9604 8.30213 13.6904 5.33213 10.2254 5.33213C8.11038 5.33213 6.76038 6.18713 6.76038 8.48213C6.76038 11.0471 8.38038 12.0371 10.3604 13.2971C12.4304 14.6021 16.2554 17.1221 18.0104 18.8321C20.1704 20.9471 20.8454 22.9721 20.8454 25.8971C20.8454 32.2871 16.6154 35.6171 10.4504 35.6171C2.89038 35.6171 0.190382 31.3871 0.190382 25.3571V22.8821H6.49038V24.8621C6.35538 28.1471 7.34538 30.5321 10.4504 30.5321C13.1054 30.5321 14.3654 29.1371 14.3654 26.5721C14.3654 24.5921 13.4654 23.2421 11.8454 22.1171C8.56038 19.5521 4.46538 17.7071 1.90038 14.3321C0.865382 12.8021 0.280382 10.9571 0.280382 9.15713C0.280382 3.39713 3.52038 0.247129 10.1804 0.247129C20.2154 0.247129 19.9454 7.98713 19.9904 11.3171ZM25.3753 24.8171V18.1571C25.1053 12.1721 28.1653 8.75213 33.9253 8.75213C42.0703 8.75213 42.9253 12.9821 42.9253 19.9121V23.3321H31.2253V27.0221C31.2703 30.3521 32.5303 30.9821 34.2853 30.9821C36.4453 30.9821 37.0753 29.4071 36.9853 26.2121H42.8353C43.0603 31.8821 40.7203 35.4821 34.7353 35.4821C27.9853 35.4821 25.2403 32.2871 25.3753 24.8171ZM31.2253 18.8321H37.0753V16.6271C37.0303 14.0621 36.3553 13.2521 34.0153 13.2521C31.0903 13.2521 31.2253 15.5021 31.2253 17.7971V18.8321ZM46.7953 26.4371H52.6453C52.1953 31.1171 53.9953 30.9821 55.3453 30.9821C57.0103 30.9821 58.1803 29.7671 57.7753 28.1471C57.6853 26.7071 56.0203 25.8971 54.8953 25.1321L51.7003 22.9271C48.7753 20.9021 46.8853 18.5621 46.8853 14.9171C46.8853 11.0021 49.9903 8.75213 55.6153 8.75213C61.2853 8.75213 63.8953 11.7221 63.7603 17.1671H57.9103C58.0453 14.3321 57.2353 13.2521 55.2103 13.2521C53.8153 13.2521 52.7353 13.8821 52.7353 15.3221C52.7353 16.8071 53.8153 17.4821 54.9403 18.2471L59.7103 21.4871C61.1953 22.3421 63.5353 24.7721 63.7153 26.4821C64.2103 30.8921 63.1303 35.4821 55.0303 35.4821C51.9253 35.4821 46.1203 34.1771 46.7953 26.4371ZM66.7904 26.4371H72.6404C72.1904 31.1171 73.9904 30.9821 75.3404 30.9821C77.0054 30.9821 78.1754 29.7671 77.7704 28.1471C77.6804 26.7071 76.0154 25.8971 74.8904 25.1321L71.6954 22.9271C68.7704 20.9021 66.8804 18.5621 66.8804 14.9171C66.8804 11.0021 69.9854 8.75213 75.6104 8.75213C81.2804 8.75213 83.8904 11.7221 83.7554 17.1671H77.9054C78.0404 14.3321 77.2304 13.2521 75.2054 13.2521C73.8104 13.2521 72.7304 13.8821 72.7304 15.3221C72.7304 16.8071 73.8104 17.4821 74.9354 18.2471L79.7054 21.4871C81.1904 22.3421 83.5304 24.7721 83.7104 26.4821C84.2054 30.8921 83.1254 35.4821 75.0254 35.4821C71.9204 35.4821 66.1154 34.1771 66.7904 26.4371ZM94.6605 34.8071H88.8105V9.42713H94.6605V34.8071ZM94.6605 6.36713H88.8105V1.05713H94.6605V6.36713ZM106.24 18.0671V26.5271C106.24 29.6321 106.51 30.9821 109.345 30.9821C112.045 30.9821 112.27 29.6321 112.27 26.5271V18.0671C112.27 15.6821 112.27 13.2521 109.345 13.2521C106.24 13.2521 106.24 15.6821 106.24 18.0671ZM109.345 35.4821C101.65 35.6171 100.345 31.8371 100.39 23.0171C100.435 14.3321 100.525 8.75213 109.345 8.75213C118.03 8.75213 118.075 14.3321 118.12 23.0171C118.165 31.8371 116.905 35.6171 109.345 35.4821ZM129.1 9.42713V12.0371H129.19C130.495 9.11213 133.105 8.75213 134.455 8.75213C137.785 8.75213 140.485 10.6871 140.305 15.2321V34.8071H134.455V17.8871C134.455 15.4121 134.185 13.7921 131.98 13.7021C129.775 13.6121 129.01 15.6821 129.1 18.3821V34.8071H123.25V9.42713H129.1ZM163.795 29.8571H166.54C172.165 29.8571 172.525 26.8871 172.525 17.1221C172.525 9.15713 171.715 6.00713 167.935 6.00713H163.795V29.8571ZM169.15 34.8071H157.495V1.05713H170.635C172.165 1.05713 175.225 1.73213 177.16 4.88213C178.6 7.22213 179.005 10.9571 179.005 16.5371C179.005 23.1971 179.005 30.8921 173.83 33.9071C172.435 34.7171 170.725 34.8071 169.15 34.8071ZM184.15 24.8171V18.1571C183.88 12.1721 186.94 8.75213 192.7 8.75213C200.845 8.75213 201.7 12.9821 201.7 19.9121V23.3321H190V27.0221C190.045 30.3521 191.305 30.9821 193.06 30.9821C195.22 30.9821 195.85 29.4071 195.76 26.2121H201.61C201.835 31.8821 199.495 35.4821 193.51 35.4821C186.76 35.4821 184.015 32.2871 184.15 24.8171ZM190 18.8321H195.85V16.6271C195.805 14.0621 195.13 13.2521 192.79 13.2521C189.865 13.2521 190 15.5021 190 17.7971V18.8321ZM215.605 30.3071V34.8971C212.14 35.3021 207.28 35.6171 207.28 30.8921V13.7021H204.895V9.42713H207.235V2.45213H213.13V9.42713H215.605V13.7021H213.13V29.4521C213.265 30.5321 214.885 30.3971 215.605 30.3071ZM236.589 34.8071H231.054C230.649 33.9971 230.604 33.0971 230.694 32.1971H230.604C229.929 33.2321 229.164 34.0871 228.264 34.6271C227.409 35.1671 226.464 35.4821 225.474 35.4821C220.749 35.4821 218.679 33.0971 218.679 27.8771C218.679 22.0721 222.774 20.6771 227.364 18.7871C229.839 17.7521 230.739 16.6271 230.244 14.5571C229.974 13.4321 229.074 13.2521 227.499 13.2521C224.844 13.2521 224.394 14.6471 224.439 16.9421H218.859C218.814 12.1271 220.389 8.75213 227.724 8.75213C235.689 8.75213 236.184 12.9371 236.094 16.2671V31.2521C236.094 32.4671 236.274 33.6371 236.589 34.8071ZM230.244 24.1871V21.4421C228.804 22.4321 227.049 23.4221 225.519 24.6821C224.664 25.4021 224.529 26.6621 224.529 27.7421C224.529 29.6771 225.114 30.9821 227.274 30.9821C230.739 30.9821 230.109 26.6171 230.244 24.1871ZM248.469 34.8071H242.619V9.42713H248.469V34.8071ZM248.469 6.36713H242.619V1.05713H248.469V6.36713ZM260.994 34.8071H255.144V1.05713H260.994V34.8071ZM265.643 26.4371H271.493C271.043 31.1171 272.843 30.9821 274.193 30.9821C275.858 30.9821 277.028 29.7671 276.623 28.1471C276.533 26.7071 274.868 25.8971 273.743 25.1321L270.548 22.9271C267.623 20.9021 265.733 18.5621 265.733 14.9171C265.733 11.0021 268.838 8.75213 274.463 8.75213C280.133 8.75213 282.743 11.7221 282.608 17.1671H276.758C276.893 14.3321 276.083 13.2521 274.058 13.2521C272.663 13.2521 271.583 13.8821 271.583 15.3221C271.583 16.8071 272.663 17.4821 273.788 18.2471L278.558 21.4871C280.043 22.3421 282.383 24.7721 282.563 26.4821C283.058 30.8921 281.978 35.4821 273.878 35.4821C270.773 35.4821 264.968 34.1771 265.643 26.4371Z" fill="white"/>
         </g>
         <defs>
         <filter id="filter0_i_434_825" x="0.191406" y="0.24707" width="282.867" height="39.3701" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
         <feFlood flood-opacity="0" result="BackgroundImageFix"/>
         <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
         <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
         <feOffset dy="4"/>
         <feGaussianBlur stdDeviation="2"/>
         <feComposite in2="hardAlpha" operator="arithmetic" k2="-1" k3="1"/>
         <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/>
         <feBlend mode="normal" in2="shape" result="effect1_innerShadow_434_825"/>
         </filter>
         </defs>
      </svg>   
   </div>

   <form class="p-4 md:p-5" >
      <div class="grid gap-3 font-roboto font-semibold">
         <div class="flex justify-between">
            <div class="text-[#f7d4b2]">
               Cashier
            </div>
            <div class="text-white">
               {full_name}
            </div>
         </div>
         <!-- part ini otomatis ya sob -->
         <div class="flex justify-between"> 
            <div class="text-[#f7d4b2]">
               Start time
            </div>
            <div class="text-white">
               {start_time}
            </div>
         </div>
         <!-- <div class="flex justify-between">
            <div class="text-[#f7d4b2]">
               Closing time
            </div>
            <div class="text-white">
               12:04 PM, 12 July 2024
            </div>
         </div> -->
         <div class="flex justify-between">
            <div class="text-[#f7d4b2]">
               Opening cash
            </div>
            <div class="">
               <MoneyInput bind:value={opening_cash} />
            </div>
         </div>
         <div class="text-[#f7d4b2]">
            <div class="pb-3">Opening notes</div>
            <textarea id="opening_notes" rows="4" class="shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] w-full p-2.5 " 
            bind:value={opening_notes}></textarea>                    
         </div>

         <div class="flex items-center justify-center">
            <button on:click={() => {console.log(last_session.deposit_difference);opening_cash == last_session.deposit_difference ? NewSession() : Swal.fire({
               title: "Opening Cash Invalid",
               text: "Opening Cash harus sama dengan Deposit Difference",
               icon: "error",
               color: "white",
               background: "#364445",
               confirmButtonColor: '#F2AA7E'
             })}} type="submit" class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082] focus:ring-4 focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
               Save
            </button>
         </div>
      </div>
  </form>


</TaskModal>
 