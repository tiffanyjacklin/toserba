<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyInput from '$lib/MoneyInput.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import { getFormattedDate, isInTimeRange } from '$lib/DateNow.js';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId, user } from '$lib/uri.js';
    import user_pp from "$lib/assets/user.png";

    let searchQuery = '';
    // $: tampilan = "manage";
    $: showModal = null;

    let handled_store = [];
    let users = [];
    $: filtered_users = [];

    //FILTER
    let showFilter = false;
    $: filter_start_date = '';
    $: filter_end_date = '';
    $: filter_role_id = '';
    $: filter_gender = '';

    //ADD NEW EMPLOYEE
    let username = "";
    let user_password = "";
    let user_fullname = "";
    let user_address = "";
    let user_gender = "";
    let user_birthdate = "";
    let user_email = "";
    let user_phone_number = "";

    let role_id = 0;
    let store_warehouse_id = 0;

    let role_to_assign = [];

    function toggleFilter() {
        showFilter = !showFilter;
    }
   function closeModal() {
        showModal = null;
   }

  async function fetchUsersbySW(sw_id){
        const response = await fetch(`http://${$uri}:8888/user/store_warehouse/${sw_id}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch user by SW', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch user by SW', data);
            return;
        }

        return data.data;
        
    }

  async function fetchUsers(){
      for (let i = 0; i < handled_store.length; i++) {
          let tmp_user = await fetchUsersbySW(handled_store[i].StoreWarehouses.store_warehouse_id)
          let tmp_sw_id = handled_store[i].StoreWarehouses.store_warehouse_id;
          for (let i = 0; i < tmp_user.length; i++) {
            tmp_user[i].sw_id = tmp_sw_id
              users.push(tmp_user[i])
          }
      }
      filtered_users = structuredClone(users);
      console.log("users",users)
    }
  
  async function fetchSW(){
        const response = await fetch(`http://${$uri}:8888/store_warehouses/${$userId}/${$roleId}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch SW failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch SW', data);
            return;
        }

        handled_store = data.data;

        console.log("handled_store",handled_store)
    }
  
  async function fetchUserFiltered(start_date,end_date,role_id,gender){
      const response = await fetch(`http://${$uri}:8888/user/${start_date}/${end_date}/''/${role_id}/${gender}/100/0`, {
          method: 'GET',
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('fetch user failed', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid fetch user', data);
          return;
      }

      let tmp = data.data;
      console.log(tmp);

      filtered_users = [];

      for (let i = 0; i < tmp.length; i++) {
        let tmp_di_user = users.find((user) => user.user_id == tmp[i].user_id && user.role_id == tmp[i].role_id);
        filtered_users.push(tmp_di_user);
      }

      console.log("filtered", filtered_users)
  }

  async function getLastUserId(){
        const response = await fetch(`http://${$uri}:8888/user/last`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch SW failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch SW', data);
            return;
        }

        return data.data.user_id
        console.log("last",data.data.user_id)
    }

  async function addUser() {
      const response = await fetch(`http://${$uri}:8888/user/add`, {
          method: 'POST',
          body: JSON.stringify({
            username,
            user_password,
            user_fullname,
            user_address,
            user_gender,
            user_birthdate,
            user_email,
            user_phone_number
          })
      });

      if (!response.ok) {
          console.error('POST add new employee gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid POST new employee', data);
          return;
      }
      console.log("Add new employee berhasil")
    }

  async function addRoletoUser(atribut) {
    const response = await fetch(`http://${$uri}:8888/user/roles/add`, {
        method: 'POST',
        body: JSON.stringify([atribut])
    });

    if (!response.ok) {
        console.error('POST role to user gagal', response);
        return;
    }

    const data = await response.json();

    if (data.status !== 200) {
        console.error('Invalid post role to user ', data);
        return;
    }
    console.log("role to user berhasil")
  }

  async function addEmployee() {
    await addUser();
    username = "";
    user_password = "";
    user_fullname = "";
    user_address = "";
    user_gender = "";
    user_birthdate = "";
    user_email = "";
    user_phone_number = "";

    let last_user_id = await getLastUserId();

    let atribut = {
      user_id: last_user_id,
      role_id: role_id,
      store_warehouse_id: store_warehouse_id,
      custom: 0
    }

    console.log(JSON.stringify(atribut))
    await addRoletoUser(atribut);

    Swal.fire({
      title: "Add Employee Berhasil",
      icon: "success",
      color: "white",
      background: "#364445",
      confirmButtonColor: '#F2AA7E'
    });

    await fetchUsers();
    closeModal();
  }

  async function fetchRoletoAssign(){
      const response = await fetch(`http://${$uri}:8888/roles/all/''/100/0`, {
          method: 'GET',
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('fetch SW failed', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid fetch SW', data);
          return;
      }

      role_to_assign = data.data;

      console.log("role_to_assign",role_to_assign)
  }

    onMount(async () => {
      await fetchSW();
      await fetchUsers();
      await fetchRoletoAssign();
    });

    $: if (searchQuery.length > 0) {
      filtered_users = users.filter(item => 
            item.roles_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            item.user_fullname.toLowerCase().includes(searchQuery)
        );
    } else {
      filtered_users = [...users];
    }
  
  </script>
  
   <div class="mx-8  mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Employees</span>

        <div class="w-11/12 flex items-center">
            <div class="relative w-9/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg mr-4">
                <input 
                    type="text" 
                    id="voice-search" 
                    bind:value={searchQuery}
                    class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                    placeholder="Search..."/>
                <button on:click={toggleFilter}
                    type="button" 
                    class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                    <i class="fa-solid fa-sliders fa-xl mr-2"></i>
                </button>
                {#if showFilter}
                    <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-3/4 bg-gray-100 p-4 rounded-lg font-roboto">
                    <div class="w-full flex justify-end">
                      <button on:click={async() => {await fetchUsers(); toggleFilter()}} class="text-peach2 p-1 rounded hover:bg-peach hover:text-darkGray">Reset</button>
                    </div>
                    <span class="font-bold text-xl mb-1">Join Date</span>
                    <div class="flex">
                        <div class="w-1/2 flex items-center justify-end pr-2">
                            <label class="block font-semibold text-gray-700 mr-2">From</label>
                            <input type="date" bind:value={filter_start_date} class="w-32 p-2 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] rounded-xl" />
                        </div>
                        <div class="w-1/2 flex items-center">
                            <label class="block font-semibold text-gray-700 mr-2">to</label>
                            <input type="date" bind:value={filter_end_date} class="w-32 p-2 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] rounded-xl" />
                        </div>
                    </div>

                    <span class="font-bold text-xl mb-1">Role</span>
                    <div class="flex w-full flex-wrap">
                        <button on:click={() => {filter_role_id = 1;  console.log(filter_role_id)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_role_id === 1 ? "border-peach2 text-peach2" : "text-darkGray"}`}>Cashier</button>
                        <button on:click={() => {filter_role_id = 2;  console.log(filter_role_id)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_role_id === 2 ? "border-peach2 text-peach2" : "text-darkGray"}`}>Inventory Store Employee</button>
                        <button on:click={() => {filter_role_id = 3;  console.log(filter_role_id)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_role_id === 3 ? "border-peach2 text-peach2" : "text-darkGray"}`}>Warehouse Employee</button>
                        <button on:click={() => {filter_role_id = 4;  console.log(filter_role_id)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_role_id === 4 ? "border-peach2 text-peach2" : "text-darkGray"}`}>Warehouse Operational Staff</button>
                        <button on:click={() => {filter_role_id = 0;  console.log(filter_role_id)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_role_id === 0 ? "border-peach2 text-peach2" : "text-darkGray"}`}>Custom</button>
                    </div>
                    
                    <span class="font-bold text-xl mb-1">Gender</span>
                    <div class="flex w-full flex-wrap">
                        <button on:click={() => {filter_gender = "L";  console.log(filter_gender)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_gender === "L" ? "border-peach2 text-peach2" : "text-darkGray"}`}>Male</button>
                        <button on:click={() => {filter_gender = "P";  console.log(filter_gender)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_gender === "P" ? "border-peach2 text-peach2" : "text-darkGray"}`}>Female</button>
                    </div>
                    
                    <div class="flex justify-between font-semibold mt-4">
                        <button on:click={() => { filter_start_date = ''; filter_end_date = ''; filter_gender = ""; filter_role_id = null }} class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" >Clear</button>
                        <button on:click={() => {fetchUserFiltered(filter_start_date,filter_end_date,filter_role_id,filter_gender); toggleFilter()}} class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded">Apply</button>
                    </div>
                    </div>
                {/if}
            </div>
            <div class="relative w-3/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-xl">
                <button on:click={() => {showModal = "add_employee"}} class="w-full py-4 rounded-xl bg-peach font-semibold text-lg text-darkGray border-2 border-darkGray"><i class="fa-solid fa-plus mr-2"></i>Add New Employee</button>
            </div>
        </div>
         
        <!-- <div class="w-11/12 my-10">
            <div class="grid grid-cols-4 gap-x-2 gap-y-4">
                {#if tampilan == "manage"}
                    <button on:click={() => {tampilan = "manage"; tampilan = tampilan;}} class="bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Manage Employee</button>
                {:else}
                    <button on:click={() => {tampilan = "manage"; tampilan = tampilan;}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Manage Employee</button>
                {/if}
                {#if tampilan == "edit"}
                    <button on:click={() => {tampilan = "edit"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Edit Role & Privilege</button>
                {:else}
                    <button on:click={() => {tampilan = "edit"; tampilan = tampilan;}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Edit Role & Privilege</button>
                {/if}
            </div>
        </div> -->

      <nav class="my-8 ">
        <ul class="flex items-center -space-x-px h-8 text-sm">
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
              <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                 <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
               </svg>
              Previous
            </a>
          </li>
  
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">1</a>
          </li>
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">2</a>
          </li>
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">3</a>
          </li>
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg ">...</a>
          </li>
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">67</a>
          </li>
          <li>
            <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">68</a>
          </li>
         
          <li>
            <a href="#" class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
              Next
              <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                 <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
               </svg>
            </a>
          </li>
        </ul>
      </nav>

      <!-- {#if tampilan == "manage"} -->
        {#each filtered_users as user}
        {#if user.role_id != 5 && user.role_id != 6}
          <button on:click={() => {goto(`/manage_employee_admin/manage/${user.user_id}/${user.role_id}/${user.sw_id}`)}} class="w-[96%] font-roboto">
            <div class="relative overflow-x-auto sm:rounded-lg">
                <div class="flex items-center border-2 rounded-xl ml-auto border-gray-700 m-3">                        
                    <div class="m-4 w-1/12 flex">
                        <img class="rounded-lg border border-darkGray" src={user_pp} alt="">
                    </div>
                    <div class="flex flex-col items-start font-semibold text-lg">
                        <span class="">{user.user_fullname}</span>
                        <span class="">{user.roles_name}</span>
                        <span class="">Join Date: {new Date(user.user_created_at).toJSON().slice(0, 10)}</span>
                    </div>
                </div>
            </div>
          </button>
        {/if}
      {/each}
     <!-- {:else if tampilan == "edit"}
     <div class="w-[96%] my-5 font-roboto">
        <div class="relative overflow-x-auto sm:rounded-lg">
                <div class="flex items-center border-2 rounded-xl ml-auto border-gray-700 m-3 pr-4">                        
                    <div class="m-4 w-1/12 flex">
                        <img class="rounded-lg border border-darkGray" src={user_pp} alt="">
                    </div>
                    <div class="w-9/12 flex flex-col font-semibold text-lg">
                        <span class="">NAMA ROLE</span>
                        <span class="">Default XXX</span>
                    </div>
                    <div class="w-2/12 flex justify-end items-center">
                        <button on:click={() => goto(``)} class="p-4 bg-peach text-darkGray rounded-xl flex items-center"><svg width="56" height="54" viewBox="0 0 56 54" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M2.33594 27C2.33594 27 11.6693 9 28.0026 9C44.3359 9 53.6693 27 53.6693 27C53.6693 27 44.3359 45 28.0026 45C11.6693 45 2.33594 27 2.33594 27Z" stroke="#3E4E50" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                            <path d="M28.0026 33.75C31.8686 33.75 35.0026 30.7279 35.0026 27C35.0026 23.2721 31.8686 20.25 28.0026 20.25C24.1366 20.25 21.0026 23.2721 21.0026 27C21.0026 30.7279 24.1366 33.75 28.0026 33.75Z" stroke="#3E4E50" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                                                       
                          </button>
                      </div>
                </div>
        </div>
     </div>
     {/if} -->
      
  
       <nav class="my-8 ">
          <ul class="flex items-center -space-x-px h-8 text-sm">
            <li>
              <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                   <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
                 </svg>
                Previous
              </a>
            </li>
    
            <li>
              <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">1</a>
            </li>
            <li>
              <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">2</a>
            </li>
            <li>
              <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">3</a>
            </li>
            <li>
              <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg ">...</a>
            </li>
            <li>
              <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">67</a>
            </li>
            <li>
              <a href="#" class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">68</a>
            </li>
           
            <li>
              <a href="#" class="flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                Next
                <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                   <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
                 </svg>
              </a>
            </li>
          </ul>
        </nav>
       
   </div>

   <!-- ADD NEW EMPLOYEE -->
{#if showModal == "add_employee" }
<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Add New Employee</div>
  </div>
  <div class="flex flex-col justify-center p-8">
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Employee Profile Picture</span>
      <input class="block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 focus:outline-none" aria-describedby="file_input_help" type="file">
    </div>
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Employee Full Name</span>
      <input type="text" bind:value={user_fullname} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
    </div>
    <div class="flex flex-col my-2">
        <span class="text-peach font-semibold mb-1">Employee Role</span>
        <select bind:value={role_id} class="w-full p-2 rounded-xl">
          {#each role_to_assign as role}
            {#if role.roles_id != 5 && role.roles_id != 6}
              <option value={role.roles_id}>{role.roles_name}</option>
            {/if}
          {/each}
        </select>
    </div>
    <div class="flex my-2">
        <div class="flex flex-col my-2 w-1/2 pr-1">
            <span class="text-peach font-semibold mb-1">Employee Email</span>
            <input type="text" bind:value={user_email} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
        <div class="flex flex-col my-2 w-1/2 pl-1">
            <span class="text-peach font-semibold mb-1">Employee Phone</span>
            <input type="text" bind:value={user_phone_number} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
    </div>
    <div class="flex my-2">
        <div class="flex flex-col my-2 w-1/2 pr-1">
            <span class="text-peach font-semibold mb-1">Employee Username</span>
            <input type="text" bind:value={username} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
        <div class="flex flex-col my-2 w-1/2 pl-1">
            <span class="text-peach font-semibold mb-1">Employee Password</span>
            <input type="text" bind:value={user_password} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
    </div>
    <div class="flex flex-col my-2">
        <span class="text-peach font-semibold mb-1">Employee Address</span>
        <textarea rows="4" type="text" bind:value={user_address} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2"></textarea>
    </div>
    <div class="flex my-2">
        <div class="flex flex-col my-2 w-1/2 pr-1">
            <span class="text-peach font-semibold mb-1">Employee Gender</span>
            <select bind:value={user_gender} class="p-2 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                <option value="L">Male</option>
                <option value="P">Female</option>
            </select>        </div>
        <div class="flex flex-col my-2 w-1/2 pl-1">
            <span class="text-peach font-semibold mb-1">Employee Birthday</span>
            <input type="date" bind:value={user_birthdate} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
    </div>

    <div class="flex flex-col my-1">
      <span class="text-peach font-semibold mb-1">Assigned Location</span>
      <select bind:value={store_warehouse_id} class="w-full p-2 rounded-xl">
        {#each handled_store as store}
            <option value={store.StoreWarehouses.store_warehouse_id}>{store.StoreWarehouses.store_warehouse_name}</option>
        {/each}
      </select>
    </div>
    <div class="flex mt-8 items-center justify-center">
      <button on:click={() => closeModal()} class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
      <button on:click={() => {addEmployee()}} class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Add</button>
    </div>
  </div>
</TaskModal> 
{/if}