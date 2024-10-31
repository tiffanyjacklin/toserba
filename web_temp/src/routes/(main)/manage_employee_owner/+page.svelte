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
    let searchQueryEdit = '';
    $: tampilan = "manage";
    $: showModal = null;

    $: limit = 10; 
    $: offset = 0;
    $: currentPage = 1; 
    $: totalRows = 0;
    $: totalPages = Math.ceil(totalRows/limit);
    let searchQuery_temp = '';

    let users = [];
    let filtered_users = [];
    // let listAdmin = [];
    let stores = [];

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
    let filtered_role_to_assign = [];

    //ADD NEW PRIVILEGE
    let privilege_name = "";
    let show_on_navbar = 0;

    //ADD NEW ROLE
    let roles_name = "";
    let roles_id = 0;
    let all_privilege = [];
    let list_new_priv_id = [];

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
   
    function toggleShowNavbar(){
        if (show_on_navbar == 0){
            show_on_navbar = 1; 
            show_on_navbar = show_on_navbar;
        } else if (show_on_navbar == 1){
            show_on_navbar = 0; 
            show_on_navbar = show_on_navbar
        }
    }

    function closeModal() {
        showModal = null;
    }
  
  async function fetchUsers(){
        const response = await fetch(`http://${$uri}:8888/user/${filter_start_date}/${filter_end_date}/${searchQuery}/${filter_role_id}/${filter_gender}/${limit}/${offset}`, {
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

        users = data.data;
        totalRows = data.total_rows;
        totalPages = Math.ceil(totalRows/limit);
        console.log("data total", data)
        // console.log("users length", users.length)

        // let adminNotShow = 0;

        // for (let i = 0; i < users.length; i++) {
        //   users[i].show = true
        //   if (users[i].role_id == 5){
        //     if (listAdmin.find((user_id) => user_id == users[i].user_id) != null){
        //       users[i].show = false
        //       adminNotShow += 1;
        //     } else {
        //       listAdmin.push(users[i].user_id)
        //       users[i].total_sw = await getAdminTotalSW(users[i].user_id,users[i].role_id);
        //       // filtered_users.push(users[i])
        //       console.log("listAdmin",listAdmin)
        //     }
        //   } else {
        //     users[i].sw_name = await getStoreWarehouse(users[i].store_warehouse_id)
        //     // filtered_users.push(users[i])
        //   }
        // }
        
        for (let i = 0; i < users.length; i++) {
          users[i].show = true
          if (users[i].role_id == 5){
              users[i].total_sw = await getAdminTotalSW(users[i].user_id,users[i].role_id);
          } else {
            users[i].sw_name = await getStoreWarehouse(users[i].store_warehouse_id)
          }
          if (users[i].user_photo_profile.String == "-"){
            users[i].user_pp_fetched = "-"
          } else {
            users[i].user_pp_fetched = await fetchUserPP(users[i].user_photo_profile.String)
          }
        }
        
        filtered_users = structuredClone(users);
        console.log("users",users)
        console.log("totalRows",totalRows);
    }
  
  // async function fetchUserFiltered(start_date,end_date,role_id,gender){
  //     const response = await fetch(`http://${$uri}:8888/user/${start_date}/${end_date}/''/${role_id}/${gender}/100/0`, {
  //         method: 'GET',
  //         headers: {
  //             'Content-Type': 'application/json'
  //         }
  //     });

  //     if (!response.ok) {
  //         console.error('fetch user failed', response);
  //         return;
  //     }

  //     const data = await response.json();

  //     if (data.status !== 200) {
  //         console.error('Invalid fetch user', data);
  //         return;
  //     }

  //     totalRows = data.total_rows;
  //     filtered_users = data.data;
  //     filtered_users = filtered_users;

  //     // for (let i = 0; i < tmp.length; i++) {
  //     //   let tmp_di_user = users.find((user) => user.user_id == tmp[i].user_id && user.role_id == tmp[i].role_id);
  //     //   filtered_users.push(tmp_di_user);
  //     // }


  //     console.log("filtered", filtered_users)
  // }

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

      let nama_wr = data.data.store_warehouse_name ;
      return nama_wr;
  }

  async function getAdminTotalSW(user_id,role_id){
        const response = await fetch(`http://${$uri}:8888/store_warehouses/${user_id}/${role_id}/''/${limit}/${offset}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch sw failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch sw', data);
            return;
        }

        // console.log("user id ", user_id, "total sw : ", data.total_rows);
        return data.total_rows;
    }

  async function fetchSW(){
    const response = await fetch(`http://${$uri}:8888/store_warehouses/all`, {
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

    stores = data.data;

    // console.log("stores",stores)
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

      totalRows = data.total_rows;
      totalPages = Math.ceil(totalRows/limit);
      role_to_assign = data.data;
      filtered_role_to_assign = structuredClone(role_to_assign);

      console.log("role_to_assign",role_to_assign)
  }

  async function fetchAllPrivilege(){
        const response = await fetch(`http://${$uri}:8888/privileges/all/''/100/0`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch all privilege failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch all privilege', data);
            return;
        }

        all_privilege = data.data;

        console.log("all_privilege",all_privilege)
    }

  function addPrivilegetoList(priv_id){
      let priv = list_new_priv_id.find((id) => id == priv_id)
      if (priv != null){
        let index = list_new_priv_id.findIndex((id) => id == priv_id)
        list_new_priv_id.splice(index,1);
        console.log("list_new_priv_id",list_new_priv_id);

      } else {
        list_new_priv_id.push(priv_id);
        console.log("list_new_priv_id",list_new_priv_id);
      }
    }

  async function addNewRoleName() {
    console.log(JSON.stringify([{roles_name: roles_name}]))
      const response = await fetch(`http://${$uri}:8888/roles/add`, {
          method: 'POST',
          body: JSON.stringify([{roles_name: roles_name}])
      });

      if (!response.ok) {
          console.error('POST add new role name gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid POST new role name', data);
          return;
      }
      console.log("Add new role name berhasil")
    }

  async function getRoleData(role_name){
        const response = await fetch(`http://${$uri}:8888/roles/all/${role_name}/100/0`, {
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

        return data.data[0].roles_id;
    }

  async function addPrivilegeNew(priv) {
    console.log(JSON.stringify(priv))
      const response = await fetch(`http://${$uri}:8888/owner/roles/default/add`, {
          method: 'POST',
          body: JSON.stringify(priv)
      });

      if (!response.ok) {
          console.error('POST add new priv default gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid POST new priv default', data);
          return;
      }
      console.log("Add new priv default berhasil")
    }

  async function addNewRole(){
    await addNewRoleName();

    console.log(roles_name);
    roles_id = await getRoleData(roles_name);
    console.log("roles_id",roles_id);

    let tmp_list_priv = [];
    for (let i = 0; i < list_new_priv_id.length; i++) {
      tmp_list_priv.push({roles_id: roles_id, privileges_id: list_new_priv_id[i]});
    }
  
    await addPrivilegeNew(tmp_list_priv);
    
    list_new_priv_id = [];
    await fetchRoletoAssign();
    closeModal();
    Swal.fire({
                title: "Privilege user berhasil diupdate",
                icon: "success",
                color: "white",
                background: "#364445",
                confirmButtonColor: '#F2AA7E'
            });
  
  }

  async function addNewPriv() {
    console.log(JSON.stringify([{privileges_name: privilege_name, Navbar: show_on_navbar}]))
      const response = await fetch(`http://${$uri}:8888/privileges/add`, {
          method: 'POST',
          body: JSON.stringify([{privileges_name: privilege_name, Navbar: show_on_navbar}])
      });

      if (!response.ok) {
          console.error('POST add new priv gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid POST new priv', data);
          return;
      }
    }
  
  async function checkAddNewPriv() {
      if(privilege_name != ""){
        await addNewPriv();
        
        privilege_name = "";
        await fetchAllPrivilege();
        Swal.fire({
                title: "Privilege user berhasil ditambahkan",
                icon: "success",
                color: "white",
                background: "#364445",
                confirmButtonColor: '#F2AA7E'
            });
      }
  }

  function clearVariable(){
    filter_start_date = ''; 
    filter_end_date = ''; 
    filter_gender = ''; 
    filter_role_id = ''; 
  }

  async function goToPage(page) {
        if (page < 1 || page > Math.ceil(totalRows / limit)) return;

        currentPage = page;
        offset = (currentPage - 1) * limit;
        // listAdmin = [];
        if (tampilan == "manage"){
          await fetchUsers();
        } else if (tampilan == "edit"){
          await fetchRoletoAssign();
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

    onMount(async () => {
      await fetchUsers();
      await fetchRoletoAssign();
      await fetchAllPrivilege();      
      await goToPage(1);
    });

    // $: if (searchQuery.length > 0) {
    //   filtered_users = users.filter(item => 
    //         item.roles_name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    //         item.user_fullname.toLowerCase().includes(searchQuery)
    //     );
    // } else {
    //   filtered_users = [...users];
    // }

    $: if ((searchQuery_temp !== searchQuery) ){
        console.log(searchQuery);
        fetchUsers();
        searchQuery_temp = searchQuery;
      } else{
        searchQuery_temp = '';
      }

    $: if (searchQueryEdit.length > 0) {
      filtered_role_to_assign = role_to_assign.filter(item => 
            item.roles_name.toLowerCase().includes(searchQueryEdit.toLowerCase())
        );
    } else {
      filtered_role_to_assign = [...role_to_assign];
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

      <div class="w-11/12 mb-10">
        <div class="grid grid-cols-4 gap-x-2 gap-y-4">
            {#if tampilan == "manage"}
                <button on:click={() => {tampilan = "manage"; tampilan = tampilan;}} class="bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Manage Employee</button>
            {:else}
                <button on:click={() => {tampilan = "manage"; tampilan = tampilan; goToPage(1)}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Manage Employee</button>
            {/if}
            {#if tampilan == "edit"}
                <button on:click={() => {tampilan = "edit"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Edit Role & Privilege</button>
            {:else}
                <button on:click={() => {tampilan = "edit"; tampilan = tampilan; goToPage(1)}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Edit Role & Privilege</button>
            {/if}
            {#if tampilan == "add_priv"}
                <button on:click={() => {tampilan = "add_priv"; tampilan = tampilan;}} class=" bg-peach2 text-darkGray font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Add Privilege</button>
            {:else}
                <button on:click={() => {tampilan = "add_priv"; tampilan = tampilan;}} class="bg-darkGray text-white font-semibold text-xl w-56 py-2 rounded-3xl border-2 border-darkGray">Add Privilege</button>
            {/if}
        </div>
    </div>

    {#if tampilan != "add_priv"}
        <div class="w-11/12 flex items-center">
            <div class="relative w-9/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-lg mr-4">
                
                {#if tampilan == "manage"}
                <input 
                    type="text" 
                    id="voice-search" 
                    bind:value={searchQuery}
                    class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                    placeholder="Search employee by name..."/>
                <button on:click={toggleFilter}
                    type="button" 
                    class="absolute inset-y-0 end-0 flex items-center pe-3 ">
                    <i class="fa-solid fa-sliders fa-xl mr-2"></i>
                </button>
                {#if showFilter}
                    <div class="shadow-[0_2px_3px_rgba(0,0,0,0.3)] absolute right-0 z-10 mt-2 w-3/4 bg-gray-100 p-4 rounded-lg font-roboto">
                    <div class="w-full flex justify-end">
                    <button on:click={() => {clearVariable(); fetchUsers(); toggleFilter(); goToPage(1)}} class="text-peach2 p-1 rounded hover:bg-peach hover:text-darkGray">Reset</button>
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
                        <button on:click={() => {filter_role_id = 5;  console.log(filter_role_id)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_role_id === 5 ? "border-peach2 text-peach2" : "text-darkGray"}`}>Admin</button>
                        <button on:click={() => {filter_role_id = 0;  console.log(filter_role_id)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_role_id === 0 ? "border-peach2 text-peach2" : "text-darkGray"}`}>Custom</button>
                    </div>
                    
                    <span class="font-bold text-xl mb-1">Gender</span>
                    <div class="flex w-full flex-wrap">
                        <button on:click={() => {filter_gender = "L";  console.log(filter_gender)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_gender === "L" ? "border-peach2 text-peach2" : "text-darkGray"}`}>Male</button>
                        <button on:click={() => {filter_gender = "P";  console.log(filter_gender)}} class={`w-fit mx-1 my-1 bg-white rounded-2xl p-2 border hover:border-peach2 hover:text-peach2 ${filter_gender === "P" ? "border-peach2 text-peach2" : "text-darkGray"}`}>Female</button>
                    </div>
                    
                    <div class="flex justify-between font-semibold mt-4">
                        <button on:click={() => {clearVariable()}} class="bg-gray-200 hover:bg-gray-300 transition-colors duration-200 ease-in-out px-4 py-2 rounded" >Clear</button>
                        <button on:click={() => {fetchUsers(); toggleFilter();  currentPage = 1;  goToPage(1);}} class="bg-[#f2b082] hover:bg-[#f7d4b2] transition-colors duration-200 ease-in-out text-[#364445] px-4 py-2 rounded">Apply</button>
                    </div>
                    </div>
                {/if}
                {:else if tampilan === "edit"}
                <input 
                    type="text" 
                    id="voice-search" 
                    bind:value={searchQuery}
                    class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
                    placeholder="Search role by role name..."/>
                {/if}
            </div>
            <div class="relative w-3/12 shadow-[0_2px_3px_rgba(0,0,0,0.3)] rounded-xl">
                {#if tampilan == "manage"}
                  <button on:click={async() => {showModal = "add_employee"; await fetchSW();}} class="w-full py-4 rounded-xl bg-peach font-semibold text-lg text-darkGray border-2 border-darkGray"><i class="fa-solid fa-plus mr-2"></i>Add New Employee</button>
                {:else if tampilan == "edit"}
                  <button on:click={async() => {showModal = "add_role";}} class="w-full py-4 rounded-xl bg-peach font-semibold text-lg text-darkGray border-2 border-darkGray"><i class="fa-solid fa-plus mr-2"></i>Add New Role</button>
                {/if}
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
     
    <!-- {:else if tampilan == "edit"} -->
      <!-- <div class="w-11/12 flex items-center">
          <input 
              type="text" 
              id="voice-search" 
              bind:value={searchQueryEdit}
              class="py-5 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-lg focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
              placeholder="Search..."/>
      </div> -->
    {/if}

      {#if tampilan == "manage"}
        {#if filtered_users.length > 0}
          {#each filtered_users as user}
          {#if user.role_id != 6 && user.show == true}
          <!-- {#if user.role_id != 6} -->
            <button on:click={() => {goto(`/manage_employee_owner/manage/${user.user_id}/${user.role_id}/${user.store_warehouse_id}`)}} class="w-[96%] font-roboto">
              <div class="relative overflow-x-auto sm:rounded-lg">
                  <div class="flex items-center border-2 rounded-xl ml-auto border-gray-700 m-3">                        
                      <div class="m-4 w-1/12 flex">
                        {#if user.user_pp_fetched != '-'}
                          <img class="rounded-lg border border-darkGray" src={user.user_pp_fetched} alt="">
                        {:else}
                            <img class="rounded-lg border border-darkGray" src={user_pp} alt="">
                        {/if}
                      </div>
                      <div class="flex w-full pr-6 items-center justify-between font-semibold text-lg">
                        <div class="flex flex-col items-start">
                          <span class="text-xl">{user.user_fullname}</span>
                          <span class="">{user.roles_name}</span>
                        </div>
                        <div class="flex flex-col items-start">
                          {#if user.role_id == 5}
                            <span class="">Total Store/Warehouse: {user.total_sw}</span>
                          {:else}
                            <span class="">{user.sw_name}</span>
                          {/if}
                          <span class="">Join Date: {new Date(user.user_created_at).toJSON().slice(0, 10)}</span>
                        </div>
                      </div>
                  </div>
              </div>
            </button>
          {/if}
          { /each}
        {/if}
     {:else if tampilan == "edit"}
     <div class="w-[96%] my-5 font-roboto">
        <div class="relative overflow-x-auto sm:rounded-lg">
          {#each filtered_role_to_assign as role}
            <div class="flex items-center border-2 rounded-xl ml-auto border-gray-700 m-3 pr-4">                        
                <div class="m-4 w-1/12 flex">
                    <img class="rounded-lg border border-darkGray" src={user_pp} alt="">
                </div>
                <div class="w-9/12 flex flex-col font-semibold text-lg">
                    <span class="text-2xl">{role.roles_name}</span>
                    <!-- <span class="">Default XXX</span> -->
                </div>
                <div class="w-2/12 flex justify-end items-center">
                    <button on:click={() => goto(`/manage_employee_owner/edit/${role.roles_id}`)} class="p-4 bg-peach2 text-darkGray rounded-xl flex items-center"><svg width="56" height="54" viewBox="0 0 56 54" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M2.33594 27C2.33594 27 11.6693 9 28.0026 9C44.3359 9 53.6693 27 53.6693 27C53.6693 27 44.3359 45 28.0026 45C11.6693 45 2.33594 27 2.33594 27Z" stroke="#3E4E50" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M28.0026 33.75C31.8686 33.75 35.0026 30.7279 35.0026 27C35.0026 23.2721 31.8686 20.25 28.0026 20.25C24.1366 20.25 21.0026 23.2721 21.0026 27C21.0026 30.7279 24.1366 33.75 28.0026 33.75Z" stroke="#3E4E50" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/>
                        </svg>
                                                    
                    </button>
                </div>
            </div>
          {/each}
        </div>
     </div>
     {:else if tampilan == "add_priv"}
     <div class="w-[96%] my-5 font-roboto">
        <div class="relative overflow-x-auto sm:rounded-lg">
          <div class="flex flex-col">
            <span class="text-lg font-semibold text-darkGray">Privilege Name</span>
            <input type="text" bind:value={privilege_name} class="p-3 rounded-xl focus:ring-peach2 w-96">
            <div class="flex items-center my-2">
              <span class="text-darkGray text-lg font-semibold mr-2">Show in Navbar</span>
              <input on:change={() => {toggleShowNavbar(); console.log(show_on_navbar)}} class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white  mr-2" type="checkbox">
            </div>
          </div>
          <div class="mt-10 mb-5 flex justify-center">
            <button on:click={() => {showModal = "confirm_req_priv"; showModal = showModal}} class="bg-peach text-darkGray hover:bg-[#F2AA7E] font-semibold w-60 py-4 text-lg border-2 border-darkGray rounded-xl">Request Privilege</button>
          </div>
        </div>
     </div>
     {/if}
      
      {#if tampilan == "manage"}
      
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
   
      {/if}
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
            {#if role.roles_id != 6}
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
        {#each stores as store}
          <option value={store.store_warehouse_id}>{store.store_warehouse_name}</option>
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

<!-- ADD NEW ROLE -->
{#if showModal == "add_role" }
<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Add New Employee</div>
  </div>
  <div class="flex flex-col justify-center p-8">
    <div class="flex flex-col my-2">
      <span class="text-peach font-semibold mb-1">Role Name</span>
      <input type="text" bind:value={roles_name} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
    </div>
   
    <!-- CHOOSE PRIVILEGE (PRIVILEGE LIST) -->
    <div class="flex flex-col my-1">
      <div class="flex items-center mb-1">
        <span class="text-peach font-semibold mr-2">Permissions</span>
      </div>
      
      <ul class="font-semibold text-white ml-2">
        {#each all_privilege as privilege}
            <li class="mb-1 text-darkGray">
                <div class="flex items-center">
                    <input on:change={() => {addPrivilegetoList(privilege.privileges_id)}} class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white checked:border-white mr-2" type="checkbox">
                    <span class="text-white">{privilege.privileges_name}</span>
                </div>
            </li>
        {/each}
      </ul>
    </div>

    <div class="flex mt-8 items-center justify-center">
      <button on:click={() => closeModal()} class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
      <button on:click={() => {addNewRole()}} class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Create</button>
    </div>
  </div>
</TaskModal> 
{/if}

<!-- MODAL CONFIRM ADD PRIV-->
{#if showModal == "confirm_req_priv" }
<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <i class="mx-4 fa-solid fa-triangle-exclamation fa-2x" style="color: #dc2626;"></i>
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Request New Privilege</div>
    <i class="mx-4 fa-solid fa-triangle-exclamation fa-2x" style="color: #dc2626;"></i>
  </div>
  <form class="my-4 p-4 md:p-5 font-roboto text-xl">
        <div class="text-red-600 font-semibold text-xl text-center mb-8">
          Are you sure you want to request the new privilege for the developers to make?
        </div>
        <div class="flex items-center justify-center gap-4">
            <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
              Back
            </button>
            <button type="button" on:click={async() => {await checkAddNewPriv(); closeModal()}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
              Request
            </button>
        </div>
  </form>
</TaskModal> 
{/if}