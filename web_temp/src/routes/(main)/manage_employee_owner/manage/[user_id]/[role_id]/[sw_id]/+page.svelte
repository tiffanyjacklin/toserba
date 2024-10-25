<script>
  import TaskModal from '$lib/TaskModal.svelte';
  import MoneyConverter from '$lib/MoneyConverter.svelte';
  import DateConverter from '$lib/DateConverter.svelte';
  import receipt from '$lib/assets/receipt-1.png';
  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { uri, userId, roleId, sessionId, privileges} from '$lib/uri.js';
  import user_pp from "$lib/assets/user.png";
  import { json } from '@sveltejs/kit';
  import { formatDate } from '$lib/DateNow.js';

  export let data;
  let user_id = data.user_id;
  let role_id = data.role_id;
  let sw_id = data.sw_id;
  let user_pp_fetched = '';
	let files;
	let imageUrl = '';

  let user = [];
  let role_user = [];
  let stores = [];
  let role_to_reassign = [];

  $: role_id_reassign = null;
  $: sw_reassign = 0;

  $: limit = 10;
  $: offset = 0;

  //Untuk edit privilege user
  let all_privilege = [];
  let priv_template_role = [];
  let priv_template_id = [];
  let prev_user_priv = [];
  let custom_user_priv = [];
  $: isUserCustom = false;

  //assign location
  let adminSW = [];
  let prev_adminSW = [];
  let searchQuery = '';
  let filtered_stores = [];

  $: showModal = false;
  function closeModal() {
    showModal = false;
  }
  function handleClick() {
    showModal = true;
  }
  function backToManageEmployee(){
    goto(`/manage_employee_owner`);
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
      user.user_created_at = formatDate(user.user_created_at);
      user.sw_name = await getStoreWarehouse(user.store_warehouse_id);
      console.log(user);

      if (user.custom == 1){
        isUserCustom = true;
        isUserCustom = isUserCustom;
      }
      console.log("isUserCustom",isUserCustom);
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
      filtered_stores = structuredClone(stores)

      console.log("admin_handled_store",stores)
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
  
  async function fetchUserPrivilege(){
      const response = await fetch(`http://${$uri}:8888/user/privileges/${user_id}/${role_id}`, {
          method: 'GET',
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('fetch user privilege failed', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid fetch user privilege', data);
          return;
      }

      prev_user_priv = data.data;
      // console.log("prev_user_priv",prev_user_priv)

      for (let i = 0; i < prev_user_priv.length; i++) {
        // if (priv_template_role.find((priv) => priv.Privileges.privileges_id == prev_user_priv[i].privilege_id) == null){
        //     custom_user_priv.push({privilege_id: prev_user_priv[i].privilege_id})
        //     isUserCustom = true;
        //     console.log("isUserCustom",isUserCustom)
        // }
        custom_user_priv.push({privilege_id:prev_user_priv[i].privilege_id})
      }
      console.log("custom_user_priv",custom_user_priv)
  }

  async function fetchTemplatePriv(){
      const response = await fetch(`http://${$uri}:8888/user/roles/default/${role_id}`, {
          method: 'GET',
          headers: {
              'Content-Type': 'application/json'
          }
      });

      if (!response.ok) {
          console.error('fetch all template role failed', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid fetch all template role', data);
          return;
      }

      priv_template_role = data.data;

      for(let i = 0; i < priv_template_role.length; i++){
        priv_template_id.push({privilege_id: priv_template_role[i].Privileges.privileges_id})
      }

      console.log("priv_template_role", priv_template_role);
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

  async function reassignEmployee() {
    let occupied_already = false;
    
    let occupied = role_user.find((role) => role.role_id == role_id_reassign 
    && role.store_warehouse_id == sw_reassign);
    if (occupied != null){
      occupied_already = true;
    }
    
    if (occupied_already == false) {
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
      goto(`/manage_employee_owner`);

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

  async function savePrivilege() {
    // if (isUserCustom == true){
      await deleteCustomPrivUser();
    // }

    console.log("custom_user_priv",JSON.stringify(custom_user_priv))
    console.log("priv_template_id",JSON.stringify(priv_template_id))

    if (JSON.stringify(custom_user_priv) != JSON.stringify(priv_template_id) && (custom_user_priv.length > 0)){
    // for (let i = 0; i < custom_user_priv.length; i++) {
        await addPrivilegeNew(custom_user_priv);
    // }
      custom_user_priv = [];
      await fetchUser();
      await fetchUserPrivilege();
      closeModal();

      Swal.fire({
        title: "Privilege user berhasil diupdate",
        icon: "success",
        color: "white",
        background: "#364445",
        confirmButtonColor: '#F2AA7E'
      });
    } else if (JSON.stringify(custom_user_priv) == JSON.stringify(priv_template_id) && (custom_user_priv.length > 0)){
      custom_user_priv = [];
      await fetchUser();
      await fetchUserPrivilege();
      closeModal();

      Swal.fire({
        title: "Privilege user berhasil diupdate",
        icon: "success",
        color: "white",
        background: "#364445",
        confirmButtonColor: '#F2AA7E'
      });
    } else {
      custom_user_priv = [];
      await fetchUser();
      await fetchUserPrivilege();
      closeModal();

      Swal.fire({
        title: "Privilege user kosong",
        icon: "error",
        color: "white",
        background: "#364445",
        confirmButtonColor: '#F2AA7E'
      });
    }

    
  }
  //post privilege satu2
  async function addPrivilegeNew(priv) {
    console.log(JSON.stringify(priv))
      const response = await fetch(`http://${$uri}:8888/user/privileges/add/new/${user_id}/${role_id}/${sw_id}`, {
          method: 'POST',
          body: JSON.stringify(priv)
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
      console.log("Add new priv satu2 berhasil")
    }
  
  async function deleteCustomPrivUser() {
      const response = await fetch(`http://${$uri}:8888/user/privileges/delete/${user_id}/${role_id}/${sw_id}`, {
          method: 'DELETE'
      });

      if (!response.ok) {
          console.error('DELETE custom priv gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid DELETE custom priv', data);
          return;
      }
      console.log("delete custom priv berhasil")
    }

  function addPrivilegetoList(priv_id){
      let priv = custom_user_priv.find((priv) => priv.privilege_id == priv_id)
      if (priv != null){
        let index = custom_user_priv.findIndex((priv) => priv.privilege_id == priv_id)
        custom_user_priv.splice(index,1);
        console.log("custom_user_priv",custom_user_priv);
      } else {
        custom_user_priv.push({privilege_id: priv_id});
        console.log("custom_user_priv",custom_user_priv);
      }
    }

  async function fetchSWAdmin(){
      const response = await fetch(`http://${$uri}:8888/store_warehouses/${user_id}/${role_id}/''/${limit}/${offset}`, {
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

      let tmp_adminSW = data.data;
      for (let i = 0; i < tmp_adminSW.length; i++){
        adminSW.push(tmp_adminSW[i].StoreWarehouses.store_warehouse_id)
      }

      prev_adminSW = structuredClone(adminSW);

      console.log("adminSW",adminSW)
  }
  
  function addSWtoList(sw_id){
      let sw = adminSW.find((adminSW_id) => adminSW_id == sw_id)
      if (sw != null){
        let index = adminSW.findIndex((adminSW_id) => adminSW_id == sw_id)
        adminSW.splice(index,1);
        console.log("AdminSW",adminSW);
      } else {
        adminSW.push(sw_id);
        console.log("AdminSW",adminSW);
      }
  }
  
  async function relocateAdmin() {
    for (let i = 0; i < prev_adminSW.length; i++){
      console.log(prev_adminSW)
      await deleteRoleUserAdmin(prev_adminSW[i])
    }

    for (let i = 0; i < adminSW.length; i++){
      let tmp_role = [{
        user_id: parseInt(user_id),
        role_id: parseInt(role_id),
        store_warehouse_id: adminSW[i],
        custom: 0
      }]
      await addUserRole(tmp_role);
    }

    prev_adminSW = [];
    adminSW = [];

    await fetchSWAdmin();
    closeModal();

    Swal.fire({
        title: "Store/Warehouse Admin berhasil diupdate",
        icon: "success",
        color: "white",
        background: "#364445",
        confirmButtonColor: '#F2AA7E'
      });

  }

  async function deleteRoleUserAdmin(delete_sw_id) {
      const response = await fetch(`http://${$uri}:8888/user/roles/delete/${user_id}/${role_id}/${delete_sw_id}`, {
          method: 'DELETE'
      });

      if (!response.ok) {
          console.error('DELETE role user admin gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid DELETE role user admin', data);
          return;
      }
      console.log("delete role user admin berhasil")
  }
  
  async function addUserRole(userRole) {
  console.log(JSON.stringify(userRole))
    const response = await fetch(`http://${$uri}:8888/user/roles/add`, {
        method: 'POST',
        body: JSON.stringify(userRole)
    });

    if (!response.ok) {
        console.error('POST add new user role gagal', response);
        return;
    }

    const data = await response.json();

    if (data.status !== 200) {
        console.error('Invalid POST new user role', data);
        return;
    }
    console.log("add user role admin berhasil")
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

    $: if (searchQuery.length > 0) {
      filtered_stores = stores.filter(item => 
            item.store_warehouse_name.toLowerCase().includes(searchQuery.toLowerCase())
        );
    } else {
      filtered_stores = [...stores];
    }

  $: editMode = false;
  onMount(async () => {
    await fetchUser();
    if (user.user_photo_profile.String !== '-'){
      await fetchUserPP();
    }
    await fetchSWAdmin();
    await fetchSW();
    await fetchRoleUser();
    await fetchRoleReassign();
    await fetchAllPrivilege();
    await fetchTemplatePriv();
    await fetchUserPrivilege();
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
      <button on:click={() => {showModal = "edit_privilege"}} class="w-48 rounded-2xl bg-peach2 text-darkGray font-semibold py-2 border border-darkGray hover:bg-darkGray hover:text-peach mx-2 shadow">Edit Privilege</button>
      {#if user.role_id == 5}
        <button on:click={() => {showModal = "assign_location"}} class="w-48 rounded-2xl bg-peach2 text-darkGray font-semibold py-2 border border-darkGray hover:bg-darkGray hover:text-peach mx-2 shadow">Assign Location</button>
      {/if}  
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
              <span class="text-peach2">Assigned At</span>
              <span class="">{user.sw_name}</span>
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
            if (user.user_photo_profile.String !== '-'){
              await fetchUserPP();
            }
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
          {#if role.roles_id != 6}
            <option value={role.roles_id}>{role.roles_name}</option>
          {/if}
        {/each}
      </select>
    </div>
    <div class="flex flex-col my-1">
      <span class="text-peach font-semibold">Assigned Location</span>
      <select bind:value={sw_reassign} class="w-full p-2 rounded-xl">
        {#each stores as store}
          {#if role_id_reassign == 1 || role_id_reassign == 2}
            {#if store.store_warehouse_type == "STORE"}
              <option value={store.store_warehouse_id}>{store.store_warehouse_name}</option>
            {/if}
          {:else if role_id_reassign == 3 || role_id_reassign == 4}
            {#if store.store_warehouse_type == "WAREHOUSE"}
              <option value={store.store_warehouse_id}>{store.store_warehouse_name}</option>
            {/if}
          {:else}
            <option value={store.store_warehouse_id}>{store.store_warehouse_name}</option>
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

<!-- MODAL EDIT PRIVILEGE EMPLOYEE -->
{#if showModal == "edit_privilege" }
<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Edit Employee Privilege</div>
  </div>
  <div class="flex flex-col justify-center p-8 font-semibold">
    <div class="flex flex-col my-2">
      <span class="text-peach">Employee Profile Picture</span>
      <img src={user_pp} class="w-40 rounded-xl border border-darkGray">
    </div>
    <div class="flex flex-col my-2">
      <span class="text-peach">Employee Full Name</span>
        <span class="text-white">{user.user_fullname}</span>
    </div>
    <div class="flex flex-col my-2">
        <span class="text-peach">Employee Role</span>
        <span class="text-white">{user.roles_name}</span>
    </div>
    
    
    <div class="flex flex-col my-2">
        <span class="text-peach">Permissions</span>
          <div class="mt-4 flex flex-col">
            <span class="text-peach2">Default : </span>
              <ul class="font-semibold text-white ml-2">
                <!-- {#each priv_template_role as priv_def}
                <li class="mb-1">
                  <div class="flex items-center">
                    <input disabled checked class="border border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white checked:border-white  mr-2" type="checkbox">
                    <span class="">{priv_def.Privileges.privileges_name}</span>
                  </div>
                </li>
                {/each} -->
                {#each priv_template_role as privilege}
                    <li class="mb-1">
                      <div class="flex items-center">
                          {#if (prev_user_priv.find((priv) => priv.privilege_id == privilege.Privileges.privileges_id) != null)}
                            <!-- <input on:change={() => {addStoreToList(store.store_warehouse_id)}} class="border border-white bg-darkGray  mr-2" type="checkbox"> -->
                            <input on:change={() => {addPrivilegetoList(privilege.Privileges.privileges_id)}} checked class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white checked:border-white  mr-2" type="checkbox">
                          {:else}
                            <input on:change={() => {addPrivilegetoList(privilege.Privileges.privileges_id)}} class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white checked:border-white mr-2" type="checkbox">
                          {/if}
                            <span class="">{privilege.Privileges.privileges_name}</span>
                        </div>
                    </li>
                {/each}
              </ul>
          </div>
          
          <div class="mt-4 flex flex-col">
            <span class="text-peach2">Custom : </span>
              <ul class="font-semibold text-white ml-2">
                {#each all_privilege as privilege}
                  {#if (priv_template_role.find((priv) => priv.Privileges.privileges_id == privilege.privileges_id) == null)}
                    <li class="mb-1">
                      <div class="flex items-center">
                          {#if (prev_user_priv.find((priv) => priv.privilege_id == privilege.privileges_id) != null)}
                            <!-- <input on:change={() => {addStoreToList(store.store_warehouse_id)}} class="border border-white bg-darkGray  mr-2" type="checkbox"> -->
                            <input on:change={() => {addPrivilegetoList(privilege.privileges_id)}} checked class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white checked:border-white  mr-2" type="checkbox">
                          {:else}
                            <input on:change={() => {addPrivilegetoList(privilege.privileges_id)}} class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white checked:border-white mr-2" type="checkbox">
                          {/if}
                            <span class="">{privilege.privileges_name}</span>
                        </div>
                    </li>
                  {/if}
                {/each}
              </ul>
          </div>
    </div>

    <div class="flex mt-8 items-center justify-center">
      <button on:click={() => closeModal()} class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
      <button on:click={() => {savePrivilege()}} class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Save</button>
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

<!-- MODAL ASSIGN LOCATION EMPLOYEE -->
{#if showModal == "assign_location" }
<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Assign Location to Manage</div>
  </div>
  <div class="flex flex-col justify-center p-8">
    <input 
      type="text" 
      id="voice-search" 
      bind:value={searchQuery}
      class="py-2 border-0 shadow-[inset_0_2px_3px_rgba(0,0,0,0.3)] bg-gray-50 text-gray-900 text-sm rounded-xl focus:shadow-[inset_0_0_5px_#FACFAD] focus:ring-peach focus:border-peach block w-full " 
      placeholder="Search Location Name..."/>
    <div class="flex flex-col my-1">
      <div class="mt-4 flex flex-col">
        <span class="text-peach mb-1 font-semibold">Stores : </span>
          <ul class="font-semibold text-white ml-2">
            {#each filtered_stores as sw}
              {#if sw.store_warehouse_type == "STORE"}
                <li class="mb-1">
                  <div class="flex items-center">
                      {#if (adminSW.find((sw_id) => sw_id == sw.store_warehouse_id) != null)}
                        <!-- <input on:change={() => {addStoreToList(store.store_warehouse_id)}} class="border border-white bg-darkGray  mr-2" type="checkbox"> -->
                        <input on:change={() => {addSWtoList(sw.store_warehouse_id)}} checked class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white checked:border-white  mr-2" type="checkbox">
                      {:else}
                        <input on:change={() => {addSWtoList(sw.store_warehouse_id)}} class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white checked:border-white mr-2" type="checkbox">
                      {/if}
                        <span class="">{sw.store_warehouse_name}</span>
                    </div>
                </li>
                {/if}
            {/each}
          </ul>
      </div>
    <div class="flex flex-col my-1">
      <div class="mt-4 flex flex-col">
        <span class="text-peach mb-1 font-semibold">Warehouses : </span>
          <ul class="font-semibold text-white ml-2">
            {#each filtered_stores as sw}
              {#if sw.store_warehouse_type == "WAREHOUSE"}
                <li class="mb-1">
                  <div class="flex items-center">
                      {#if (adminSW.find((sw_id) => sw_id == sw.store_warehouse_id) != null)}
                        <!-- <input on:change={() => {addStoreToList(store.store_warehouse_id)}} class="border border-white bg-darkGray  mr-2" type="checkbox"> -->
                        <input on:change={() => {addSWtoList(sw.store_warehouse_id)}} checked class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white checked:border-white  mr-2" type="checkbox">
                      {:else}
                        <input on:change={() => {addSWtoList(sw.store_warehouse_id)}} class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white checked:border-white mr-2" type="checkbox">
                      {/if}
                        <span class="">{sw.store_warehouse_name}</span>
                    </div>
                </li>
                {/if}
            {/each}
          </ul>
      </div>
    <div class="flex mt-8 items-center justify-center">
      <button on:click={() => closeModal()} class="w-36 py-2 bg-darkGray text-peach border border-peach mx-4 rounded-xl font-semibold">Back</button>
      <button on:click={() => relocateAdmin()} class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Relocate</button>
    </div>
  </div>
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



