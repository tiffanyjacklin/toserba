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

    import { loading } from '$lib/loading';

    let searchQuery = '';
    // $: tampilan = "manage";
    $: showModal = null;

    $: limit = 10; 
    $: offset = 0;
    $: currentPage = 1; 
    $: totalRows = 0;
    $: totalPages = Math.ceil(totalRows/limit);

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
	let files;
	let imageUrl = '';
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

    $: if (files && (files.length > 0 || files !== '') ) {
		// Get the first file (for the avatar input)
		const file = files[0];

		// Check if the file is an image (optional)
		if (file && (file.type.startsWith('image/'))) {
			// Create an object URL for the image file
			imageUrl = URL.createObjectURL(file);
		} else {
			imageUrl = ''; // Clear the image URL if the file is not an image
		}
	}
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
            if (tmp_user[i].user_photo_profile.String == "-"){
                tmp_user[i].user_pp_fetched = "-"
            } else {
                tmp_user[i].user_pp_fetched = await fetchUserPP(tmp_user[i].user_photo_profile.String)
            }
            if (tmp_user[i].role_id != 5 && tmp_user[i].role_id != 6){
                users.push(tmp_user[i])
            }
          }
      }
      filtered_users = structuredClone(users);
      totalRows = users.length;
      totalPages = Math.ceil(totalRows/limit);
      console.log("users",users);
    }
  
  async function fetchSW(){
        const response = await fetch(`http://${$uri}:8888/store_warehouses/${$userId}/${$roleId}/''/${limit}/${offset}`, {
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
        let tmp_di_user = users.find((user) => user.user_id == tmp[i].user_id && user.role_id == tmp[i].role_id && user.store_warehouse_id == tmp[i].store_warehouse_id);
        if (tmp_di_user != null){
          filtered_users.push(tmp_di_user);
        }
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
            user_phone_number: '0' + String(user_phone_number),
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

  async function addProfilePictureUser(user_id, files) {
    const formData = new FormData();
    formData.append('folder', 'users');
    formData.append('file', files[0]); // Assuming you're sending the first file from the FileList
    formData.append('id', user_id);
    formData.append('kolom_id', 'user');
    formData.append('kolom_name', 'user_photo_profile');

    const response = await fetch(`http://${$uri}:8888/file/upload`, {
        method: 'POST',
        body: formData
    });

    if (!response.ok) {
        console.error('POST add pp new employee gagal', response);
        return;
    }

    const data = await response.json();

    if (data.status !== 200) {
        console.error('Invalid POST pp new employee', data);
        return;
    }
    console.log("Add pp new employee berhasil");
  }
  async function addEmployee() {
    await addUser();
    let last_user_id = await getLastUserId();
    await addProfilePictureUser(last_user_id, files);
    username = "";
    user_password = "";
    user_fullname = "";
    user_address = "";
    user_gender = "";
    user_birthdate = "";
    user_email = "";
    user_phone_number = "";
    files = '';


    let atribut = {
      user_id: last_user_id,
      role_id: role_id,
      store_warehouse_id: store_warehouse_id,
      custom: 0
    }

    console.log(JSON.stringify(atribut))
    await addRoletoUser(atribut);

    let description = "User ID "+$userId+" membuat user baru dengan ID user "+ last_user_id;
    //20 Create New User
    await insertNotif(description,20)

    Swal.fire({
      title: "Add Employee Berhasil",
      icon: "success",
      color: "white",
      background: "#364445",
      confirmButtonColor: '#F2AA7E'
    });

    users = [];
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

  async function fetchUserPP(user_pp_fetched){
      const response = await fetch(`http://${$uri}:8888/file/${user_pp_fetched}`, {
          method: 'GET',
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('fetch user pp failed', response);
          return;
      }

        // Instead of expecting a JSON response, we handle the image as a blob
        const blob = await response.blob();

        // Convert the blob to an object URL so it can be used as the image source
        return URL.createObjectURL(blob);
    }

  async function goToPage(page) {
        $loading = true;
        if (page < 1 || page > Math.ceil(totalRows / limit)) return;

        currentPage = page;
        offset = (currentPage - 1) * limit;
        users = [];
        await fetchUsers();
        $loading = false;
    }

    onMount(async () => {
        $loading = true;
        await fetchSW();
        await fetchUsers();
        await fetchRoletoAssign();
        $loading = false;
    });

    $: if (searchQuery.length > 0) {
      filtered_users = users.filter(item => 
            item.roles_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
            item.user_fullname.toLowerCase().includes(searchQuery)
        );
    } else {
      filtered_users = [...users];
    }
  
    function handleInput(e) {
        const input = e.target;

        // Store the current cursor position
        const cursorPos = input.selectionStart;

        // Remove all characters except digits
        input.value = input.value.replace(/[^0-9]/g, '');

        // Limit the length to 12 digits
        if (input.value.length > 12) {
            input.value = input.value.slice(0, 12);
        }

        // Update the bound value
        user_phone_number = input.value;

        // Restore the cursor position
        input.setSelectionRange(cursorPos, cursorPos);
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
                    placeholder="Search by employee's name or role..."/>
                <button on:click={toggleFilter}
                    type="button" 
                    class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                    <i class="fa-solid fa-sliders fa-xl mr-2"></i>
                </button>
                {#if showFilter}
                    <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-3/4 bg-gray-100 p-4 rounded-lg font-roboto">
                    <div class="w-full flex justify-end">
                      <button on:click={async() => {users = []; await fetchUsers(); toggleFilter()}} class="text-peach2 p-1 rounded hover:bg-peach hover:text-darkGray">Reset</button>
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
                        <button on:click={() => {fetchUserFiltered(filter_start_date,filter_end_date,filter_role_id,filter_gender); toggleFilter();  currentPage = 1;}} class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded">Apply</button>
                    </div>
                    </div>
                {/if}
            </div>
            <div class="relative w-3/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-xl">
                <button on:click={() => {showModal = "add_employee"}} class="w-full py-4 rounded-xl bg-peach font-semibold text-lg text-darkGray border-2 border-darkGray"><i class="fa-solid fa-plus mr-2"></i>Add New Employee</button>
            </div>
        </div>

        <nav class="my-8 flex justify-center">
          <ul class="flex items-center -space-x-px h-8 text-sm">
          {#if totalRows !== 0}
          <li>
              <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="{currentPage === 1 ? 'opacity-50 cursor-not-allowed' : 'hover:text-white hover:bg-black'} mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
              <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                  <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
              </svg>
              Previous
              </a>
          </li>
          {/if}
      
          {#if totalPages <= 5}
              {#each Array(totalPages) as _, i}
              <li>
                  <a 
                      href="#" 
                      on:click|preventDefault={() => goToPage(i + 1)} 
                      class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                          {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                      {i + 1}
                  </a>
              </li>
              {/each}
          {:else}
              {#if currentPage > 3}
              <li>
                  <a 
                      href="#" 
                      on:click|preventDefault={() => goToPage(1)} 
                      class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                      1
                  </a>
              </li>
              <li class="mx-1 flex items-center justify-center px-3 h-8">...</li>
              {/if}

              {#each Array(5) as _, index}
                  {#if currentPage <= 3}
                      {#if index < 5 && index < totalPages}
                      <li>
                          <a 
                              href="#" 
                              on:click|preventDefault={() => goToPage(index + 1)} 
                              class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                                  {currentPage === index + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                              {index + 1}
                          </a>
                      </li>
                      {/if}
                  {:else if currentPage >= totalPages - 2}
                      {#if index + totalPages - 5 >= 0}
                      <li>
                          <a 
                              href="#" 
                              on:click|preventDefault={() => goToPage(index + totalPages - 5 + 1)} 
                              class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                                  {currentPage === index + totalPages - 5 + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                              {index + totalPages - 5 + 1}
                          </a>
                      </li>
                      {/if}
                  {:else}
                      {#if index + currentPage - 2 >= 0 && index + currentPage - 2 < totalPages}
                      <li>
                          <a 
                              href="#" 
                              on:click|preventDefault={() => goToPage(index + currentPage - 2)} 
                              class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                                  {currentPage === index + currentPage - 2 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                              {index + currentPage - 2}
                          </a>
                      </li>
                      {/if}
                  {/if}
              {/each}

              {#if currentPage < totalPages - 2}
              <li class="mx-1 flex items-center justify-center px-3 h-8">...</li>
              <li>
                  <a 
                      href="#" 
                      on:click|preventDefault={() => goToPage(totalPages)} 
                      class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                      {totalPages}
                  </a>
              </li>
              {/if}
          {/if}

          {#if totalRows !== 0}
          <li>
              <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="{currentPage === (Math.ceil(totalRows / limit)) ? 'opacity-50 cursor-not-allowed' : 'hover:text-white hover:bg-black'} flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
              Next
              <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                  <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
              </svg>
              </a>
          </li>
          {/if}
          </ul>
        </nav>
     

        {#each filtered_users as user}
        <!-- {#if user.role_id != 5 && user.role_id != 6} -->
          <button on:click={() => {goto(`/manage_employee_admin/manage/${user.user_id}/${user.role_id}/${user.sw_id}`)}} class="w-[96%] font-roboto">
            <div class="relative overflow-x-auto sm:rounded-lg">
                <div class="flex items-center border-2 rounded-xl ml-auto border-gray-700 m-3">                        
                    <div class="m-4 w-1/12 flex">
                        {#if user.user_pp_fetched != '-'}
                            <img class="rounded-lg border border-darkGray" src={user.user_pp_fetched} alt="">
                        {:else}
                            <img class="rounded-lg border border-darkGray" src={user_pp} alt="">
                        {/if}
                    </div>
                    <div class="flex flex-col items-start font-semibold text-lg">
                        <span class="">{user.user_fullname}</span>
                        <span class="">{user.roles_name}</span>
                        <span class="">Join Date: {new Date(user.user_created_at).toJSON().slice(0, 10)}</span>
                    </div>
                </div>
            </div>
          </button>
        <!-- {/if} -->
      {/each}
      
  
      <nav class="my-8 flex justify-center">
        <ul class="flex items-center -space-x-px h-8 text-sm">
        {#if totalRows !== 0}
        <li>
            <a href="#" on:click|preventDefault={() => goToPage(currentPage - 1)} class="{currentPage === 1 ? 'opacity-50 cursor-not-allowed' : 'hover:text-white hover:bg-black'} mx-1 flex items-center justify-center px-3 h-8 ms-0 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
            <svg class="w-3.5 h-3.5 me-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5H1m0 0 4 4M1 5l4-4"/>
            </svg>
            Previous
            </a>
        </li>
        {/if}
    
        {#if totalPages <= 5}
            {#each Array(totalPages) as _, i}
            <li>
                <a 
                    href="#" 
                    on:click|preventDefault={() => goToPage(i + 1)} 
                    class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                        {currentPage === i + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                    {i + 1}
                </a>
            </li>
            {/each}
        {:else}
            {#if currentPage > 3}
            <li>
                <a 
                    href="#" 
                    on:click|preventDefault={() => goToPage(1)} 
                    class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                    1
                </a>
            </li>
            <li class="mx-1 flex items-center justify-center px-3 h-8">...</li>
            {/if}

            {#each Array(5) as _, index}
                {#if currentPage <= 3}
                    {#if index < 5 && index < totalPages}
                    <li>
                        <a 
                            href="#" 
                            on:click|preventDefault={() => goToPage(index + 1)} 
                            class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                                {currentPage === index + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                            {index + 1}
                        </a>
                    </li>
                    {/if}
                {:else if currentPage >= totalPages - 2}
                    {#if index + totalPages - 5 >= 0}
                    <li>
                        <a 
                            href="#" 
                            on:click|preventDefault={() => goToPage(index + totalPages - 5 + 1)} 
                            class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                                {currentPage === index + totalPages - 5 + 1 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                            {index + totalPages - 5 + 1}
                        </a>
                    </li>
                    {/if}
                {:else}
                    {#if index + currentPage - 2 >= 0 && index + currentPage - 2 < totalPages}
                    <li>
                        <a 
                            href="#" 
                            on:click|preventDefault={() => goToPage(index + currentPage - 2)} 
                            class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg 
                                {currentPage === index + currentPage - 2 ? 'bg-black text-white' : 'hover:text-white hover:bg-black'}">
                            {index + currentPage - 2}
                        </a>
                    </li>
                    {/if}
                {/if}
            {/each}

            {#if currentPage < totalPages - 2}
            <li class="mx-1 flex items-center justify-center px-3 h-8">...</li>
            <li>
                <a 
                    href="#" 
                    on:click|preventDefault={() => goToPage(totalPages)} 
                    class="mx-1 flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
                    {totalPages}
                </a>
            </li>
            {/if}
        {/if}

        {#if totalRows !== 0}
        <li>
            <a href="#" on:click|preventDefault={() => goToPage(currentPage + 1)} class="{currentPage === (Math.ceil(totalRows / limit)) ? 'opacity-50 cursor-not-allowed' : 'hover:text-white hover:bg-black'} flex items-center justify-center px-3 h-8 leading-tight text-gray-500 rounded-lg hover:text-white hover:bg-black">
            Next
            <svg class="w-3.5 h-3.5 ms-2 rtl:rotate-180" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 10">
                <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M1 5h12m0 0L9 1m4 4L9 9"/>
            </svg>
            </a>
        </li>
        {/if}
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
      <input class="block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 focus:outline-none" aria-describedby="file_input_help" accept="image/png, image/jpeg" bind:files id="avatar" name="avatar" type="file" />
      {#if files}
            {#if imageUrl}
                <img src={imageUrl} alt="Selected image" class="max-w-40 max-h-40 mt-4" />
            {/if}
        {/if}
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

            <div class="relative w-full flex items-center">
                <span class="absolute left-2 text-sm mx-1 text-slate-900">+62</span>
                <div class="absolute left-10 h-full border-l mx-2 border-black"></div>
                <input type="text" on:input={handleInput}  bind:value={user_phone_number} class="pl-14 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
            </div>
        </div>
    </div>
    <div class="flex my-2">
        <div class="flex flex-col my-2 w-1/2 pr-1">
            <span class="text-peach font-semibold mb-1">Employee Username</span>
            <input type="text" bind:value={username} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
        <div class="flex flex-col my-2 w-1/2 pl-1">
            <span class="text-peach font-semibold mb-1">Employee Password</span>
            <input type="password" bind:value={user_password} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
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
      <button on:click={async() => {$loading = true;await addEmployee(); $loading = false;}} class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Add</button>
    </div>
  </div>
</TaskModal> 
{/if}