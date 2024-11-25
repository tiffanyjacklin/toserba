<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import receipt from '$lib/assets/receipt-1.png';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri, userId, roleId, sessionId} from '$lib/uri.js';
    import user_pp from "$lib/assets/user.png";
	import { json } from '@sveltejs/kit';

  import { loading } from '$lib/loading';

    export let data;
    let user_id = data.user_id;
    let role_id = data.role_id;
    let sw_id = data.sw_id;
    
    let user_pp_fetched = '';
    let files;
    let imageUrl = '';

    let user = [];
    let role_user = [];
    let admin_handled_store = [];
    let role_to_reassign = [];

    $: role_id_reassign = null;
    $: sw_reassign = 0;

    $: showModal = false;
    function closeModal() {
      showModal = false;
    }
    function handleClick() {
      showModal = true;
    }
    function backToManageEmployee(){
      goto(`/manage_employee_admin`);
    }

    async function fetchUser(){
        const response = await fetch(`http://${$uri}:8888/user/${user_id}/${role_id}`, {
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

        user = data.data;
        console.log(user);
        
    }
    
    async function fetchUserPP(){
        const response = await fetch(`http://${$uri}:8888/file/${user.user_photo_profile.String}`, {
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
      user_pp_fetched = URL.createObjectURL(blob);
    }

    async function fetchRoleUser(){
        const response = await fetch(`http://${$uri}:8888/user/roles/${user_id}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch all promo failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch all promo', data);
            return;
        }

        role_user = data.data;
        console.log("role_user", role_user);
    }

    async function fetchSW(){
        const response = await fetch(`http://${$uri}:8888/store_warehouses/${$userId}/${$roleId}/''/0/0`, {
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

        admin_handled_store = data.data;
        // filtered_admin_handled_store = structuredClone(admin_handled_store);

        console.log("admin_handled_store",admin_handled_store)
    }

    async function UpdateDataUser(user_id,atribut) {
        const response = await fetch(`http://${$uri}:8888/user/update/${user_id}`, {
            method: 'PUT',
            body: JSON.stringify(atribut)
        });

        if (!response.ok) {
            console.error('PUT data user gagal', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid put update data user', data);
            return;
        }
        console.log("update data user berhasil")
    }
    
    function handleFileSelect(event) {
      files = event.target.files;
      if (files && files.length > 0) {
        imageUrl = URL.createObjectURL(files[0]);
      }
    }
    async function editProfilePictureUser(user_id, files) {
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
    async function UpdateRoleUser(user_id,role_id_lama,atribut) {
      const response = await fetch(`http://${$uri}:8888/user/roles/update/${user_id}/${role_id_lama}`, {
          method: 'PUT',
          body: JSON.stringify(atribut)
      });

      if (!response.ok) {
          console.error('PUT role user gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid put update role user', data);
          return;
      }
      console.log("update role user berhasil")
    }
    
    async function fetchRoleReassign(){
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

        role_to_reassign = data.data;

        console.log("role_to_reassign",role_to_reassign)
    }
    
    async function deleteRoleUser(){
        const response = await fetch(`http://${$uri}:8888/user/roles/delete/${user_id}/${role_id}/${sw_id}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('delete user role failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid delete user role', data);
            return;
        }
    }

    async function reassignEmployee() {
      let occupied_already = false;
      
      let occupied = role_user.find((role) => role.role_id == role_id_reassign 
      && role.store_warehouse_id == sw_reassign);
      if (occupied != null){
        occupied_already = true;
      }
      
      if (occupied_already == false) {
        // if (sw_reassign == 0 && admin_handled_store.length == 1){
        //   sw_reassign == 
        // }
        let atribut = {
          role_id: role_id_reassign,
          store_warehouse_id: sw_reassign,
          custom: 0
        }
        console.log("update role", JSON.stringify(atribut))
        await UpdateRoleUser(user_id, role_id,atribut)

        let description = "User ID "+$userId+" melakukan update role user dengan ID user "+ user_id;
        //21 Update Role User
        await insertNotif(description,21)
        
        Swal.fire({
          title: "Update Role User Berhasil",
          icon: "success",
          color: "white",
          background: "#364445",
          confirmButtonColor: '#F2AA7E'
        });
        closeModal();
        goto(`/manage_employee_admin`);

      } else {
        Swal.fire({
          title: "Update role user gagal role di suatu store/warehouse telah ditempati",
          icon: "error",
          color: "white",
          background: "#364445",
          confirmButtonColor: '#F2AA7E'
        });
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

    $: editMode = false;
    onMount(async () => {
      $loading = true;
      await fetchUser();
      await fetchUserPP();
      await fetchSW();
      await fetchRoleUser();
      await fetchRoleReassign();
      $loading = false;
    });
   
  </script>

  <div class="mt-[90px] mx-8 mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={backToManageEmployee} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Manage Employees</span>       
    <div class="w-full flex justify-start items-center mb-4 px-8">
        {#if editMode == false}
            <button on:click={() => {editMode = true;}} class="w-48 rounded-2xl bg-peach2 text-darkGray font-semibold py-2 border border-darkGray hover:bg-darkGray hover:text-peach mx-2 shadow">Edit</button>
        {:else}
            <button on:click={() => {editMode = false;}} class="w-48 rounded-2xl bg-darkGray text-peach font-semibold py-2 border border-peach mx-2 shadow">Cancel Edit</button>
        {/if}
        <button on:click={() => {showModal = "reassign"}} class="w-48 rounded-2xl bg-peach2 text-darkGray font-semibold py-2 border border-darkGray hover:bg-darkGray hover:text-peach mx-2 shadow">Reassign</button>
    </div>

    <div class="flex w-full mb-10">
        <div class="flex flex-col w-2/3 font-semibold text-darkGray pl-8">
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Full Name</span>
                {#if editMode == false}
                    <span class="">{user.user_fullname}</span>
                {:else}
                    <input type="text" bind:value={user.user_fullname} class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Role</span>
                <span class="">{user.roles_name}</span>
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Email</span>
                {#if editMode == false}
                    <span class="">{user.user_email}</span>
                {:else}
                    <input type="text" bind:value={user.user_email} class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Phone Number</span>
                {#if editMode == false}
                    <span class="">{user.user_phone_number}</span>
                {:else}
                    <input type="text" bind:value={user.user_phone_number} class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2 ">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Join Date</span>
                {#if editMode == false}
                    <span class="">{user.user_created_at}</span>
                {:else}
                    <input type="date" bind:value={user.user_created_at} class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Birthday</span>
                {#if editMode == false}
                    <span class="">{user.user_birthdate}</span>
                {:else}
                    <input type="date" bind:value={user.user_birthdate} class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Gender</span>
                {#if editMode == false}
                  {#if user.user_gender == "P"}
                    <span class="">Perempuan</span>
                  {:else}
                    <span class="">Laki-laki</span>
                  {/if}
                {:else}
                    <select bind:value={user.user_gender} class="w-48 p-2 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                        <option value="L">Male</option>
                        <option value="P">Female</option>
                    </select>
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Address</span>
                {#if editMode == false}
                  <span class="">{user.user_address}</span>
                {:else}
                  <input type="text" bind:value={user.user_address} class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <button on:click={() => {showModal = "confirm_delete"; showModal = showModal;}} class="w-40 py-2 rounded-2xl font-semibold bg-darkGray text-peach2 shadow">Delete Employee</button>
            </div>
        </div>
        <div class="flex flex-col w-1/3">
          <div class="flex flex-col my-2">
            <span class="text-peach font-semibold mb-1">Employee Profile Picture</span>
            {#if editMode == false}
              {#if user_pp_fetched !== ''}
                <img src={user_pp_fetched} class="w-40 rounded-xl border border-darkGray" alt="Profile Picture">
              {:else}
                <img src={user_pp} class="w-40 rounded-xl border border-darkGray" alt="Default Picture">
              {/if}
            {:else}
              <input 
                class="block w-full text-sm text-gray-900 border border-gray-300 rounded-lg cursor-pointer bg-gray-50 focus:outline-none" 
                aria-describedby="file_input_help" 
                accept="image/png, image/jpeg" 
                bind:files 
                id="avatar" 
                name="avatar" 
                type="file" 
                on:change={handleFileSelect} 
              />
              
              {#if files}
                {#if imageUrl}
                  <img src={imageUrl} alt="Selected image" class="mt-4  w-40 rounded-xl border border-darkGray" />
                {/if}
              {:else}
                {#if user_pp_fetched !== ''}
                  <img src={user_pp_fetched} class="mt-4 w-40 rounded-xl border border-darkGray" alt="Profile Picture">
                {:else}
                  <img src={user_pp} class="mt-4 w-40 rounded-xl border border-darkGray" alt="Default Picture">
                {/if}
              {/if}
            {/if}
          </div>
        </div>
    </div>

    <div class="flex mb-10">
        {#if editMode == true}
            <button on:click={async() => {
              let atribut = {
              user_fullname: user.user_fullname,
              user_address: user.user_address,
              user_gender: user.user_gender,
              user_birthdate: user.user_birthdate,
              user_email: user.user_email,
              user_phone_number: user.user_phone_number,
              user_updated_at: user.user_updated_at
              }; console.log(JSON.stringify(atribut)); 
              await UpdateDataUser(user.user_id,atribut);
              await editProfilePictureUser(user.user_id, files);
              await fetchUser();
              await fetchUserPP();
              Swal.fire({
                title: "Update Data User Berhasil",
                icon: "success",
                color: "white",
                background: "#364445",
                confirmButtonColor: '#F2AA7E'
              }); editMode = false; editMode = editMode;
            }} class="w-48 py-3 bg-peach text-darkGray font-semibold border border-darkGray rounded-2xl text-xl hover:bg-[#F2AA7E]">Save</button>
        {/if}
    </div>

</div>


<!-- MODAL REASSIGN EMPLOYEE -->
{#if showModal == "reassign" }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Reassign Employee</div>
    </div>
    <div class="flex flex-col justify-center p-8">
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold">Employee Role</span>
        <select bind:value={role_id_reassign} class="w-full p-2 rounded-xl">
          {#each role_to_reassign as role}
            {#if role.roles_id != 6 && role.roles_id != 5}
              <option value={role.roles_id}>{role.roles_name}</option>
            {/if}
          {/each}
        </select>
      </div>
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold">Assigned Location</span>
        <select bind:value={sw_reassign} on:change={() => {console.log("sw_reassign",sw_reassign)}} class="w-full p-2 rounded-xl">
          <option selected="true" style='display: none'></option>
          {#each admin_handled_store as store}
            {#if role_id_reassign == 1 || role_id_reassign == 2}
              {#if store.StoreWarehouses.store_warehouse_type == "STORE"}
                <option value={store.StoreWarehouses.store_warehouse_id}>{store.StoreWarehouses.store_warehouse_name}</option>
              {/if}
            {:else if role_id_reassign == 3 || role_id_reassign == 4}
              {#if store.StoreWarehouses.store_warehouse_type == "WAREHOUSE"}
                <option value={store.StoreWarehouses.store_warehouse_id}>{store.StoreWarehouses.store_warehouse_name}</option>
              {/if}
            {:else}
              <option value={store.StoreWarehouses.store_warehouse_id}>{store.StoreWarehouses.store_warehouse_name}</option>
            {/if}
          {/each}
        </select>
      </div>
      <div class="flex mt-8 items-center justify-center">
        <button on:click={() => closeModal()} class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
        <button on:click={() => reassignEmployee()} class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Reassign</button>
      </div>
    </div>
  </TaskModal> 
  {/if}

<!-- MODAL DELETE USER ROLE -->
{#if showModal == "confirm_delete" }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Delete User Role</div>
    </div>
    <form class="my-4 p-4 md:p-5 font-roboto text-xl">
          <div class="text-[#f7d4b2] font-medium text-center mb-8">
            Are you sure you want to submit the changes you've made?
          </div>
          <div class="flex items-center justify-center gap-4">
              <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                Back
              </button>
              <button type="button" on:click={() => {deleteRoleUser(); 
              Swal.fire({
                title: "Produk Berhasil Ditambahkan",
                icon: "success",
                color: "white",
                background: "#364445",
                confirmButtonColor: '#F2AA7E'
              }); closeModal(); goto(`/manage_employee_admin`)}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
                Delete
              </button>
          </div>
    </form>
  </TaskModal> 
  {/if}

  <!-- MODAL CREATE NEW ROLE (OWNER AJA) -->
<!-- {#if showModal == "create_role" }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Create New Role</div>
    </div>
    <div class="flex flex-col justify-center p-8">
        <div class="flex flex-col my-1">
            <span class="text-peach font-semibold">Role Name</span>
            <input type="text" value="nama role baru" class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
        <div class="flex flex-col my-1">
            <span class="text-peach font-semibold">Role Description</span>
            <textarea type="text" rows="4" value="desc role baru" class=" rounded-xl focus:ring-peach2 focus:border focus:border-peach2"></textarea>
        </div>
        <div class="flex flex-col my-1">
          <span class="text-peach font-semibold">Permissions</span>
          <ul class="font-semibold text-white ml-2">
              <li class="mb-1">
                <div class="flex items-center">
                  <input value="null" class="border border-white bg-darkGray  mr-2" type="checkbox">
                  <span class="">nama store</span>
                </div>
              </li>
              <li class="mb-1">
                <div class="flex items-center">
                  <input value="null" class="border border-white bg-darkGray  mr-2" type="checkbox">
                  <span class="">nama store</span>
                </div>
              </li>
              <li class="mb-1">
                <div class="flex items-center">
                  <input value="null" class="border border-white bg-darkGray  mr-2" type="checkbox">
                  <span class="">nama store</span>
                </div>
              </li>
          </ul>
        </div>
      <div class="flex mt-8 items-center justify-center">
        <button class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
        <button class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Create</button>
      </div>
    </div>
  </TaskModal> 
  {/if} -->

  
  
