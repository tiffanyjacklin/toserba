<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import receipt from '$lib/assets/receipt-1.png';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { privileges, uri } from '$lib/uri.js';
    import user_pp from "$lib/assets/user.png";
	// import { npm_execpath } from '$env/static/private';

    export let data;
    let role_id = parseInt(data.role_id);
    // console.log(role_id)
    
    $: role_name = "";
    let all_privilege = [];
    $: priv_template_role = [];

    $: new_template_role = [];

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

    async function getRoleName(){
        const response = await fetch(`http://${$uri}:8888/roles/${role_id}`, {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) {
            console.error('fetch role name failed', response);
            return;
        }

        const data = await response.json();

        if (data.status !== 200) {
            console.error('Invalid fetch role name', data);
            return;
        }

        role_name = data.data.roles_name;
        console.log(data.data)
        role_name = role_name;
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
      let priv = new_template_role.find((priv) => priv.privileges_id == priv_id)
      if (priv != null){
        let index = new_template_role.findIndex((priv) => priv.privileges_id == priv_id)
        new_template_role.splice(index,1);
        console.log("new_template_role",new_template_role);

      } else {
        new_template_role.push({roles_id:role_id, privileges_id: priv_id});
        console.log("new_template_role",new_template_role);
      }
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

        for (let i = 0; i < priv_template_role.length; i++) {
            new_template_role.push({roles_id: parseInt(role_id), privileges_id: priv_template_role[i].Privileges.privileges_id});
        }

        console.log("new_template_role", new_template_role);
    }

    async function deleteAllDefaultPriv() {
      const response = await fetch(`http://${$uri}:8888/user/all/roles/default/${role_id}`, {
          method: 'DELETE'
      });

      if (!response.ok) {
          console.error('DELETE default priv gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid DELETE default priv', data);
          return;
      }
      console.log("delete default priv berhasil")
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
    
    async function editRoleName(atribut) {
    console.log(JSON.stringify({roles_name: atribut}))
      const response = await fetch(`http://${$uri}:8888/roles/edit/name/${role_id}`, {
          method: 'PUT',
          body: JSON.stringify({roles_name: atribut})
      });

      if (!response.ok) {
          console.error('PUT edit role name gagal', response);
          return;
      }

      const data = await response.json();

      if (data.status !== 200) {
          console.error('Invalid PUT edit role name', data);
          return;
      }
      console.log("edit role name berhasil")
    }

    async function saveDefaultPrivilege() {
        await editRoleName(role_name);

        if (priv_template_role.length > 0){
            await deleteAllDefaultPriv();
        }

        if (new_template_role.length > 0){
            await addPrivilegeNew(new_template_role);

            new_template_role = [];
            await fetchTemplatePriv();
            closeModal();
        }
        Swal.fire({
                title: "Privilege user berhasil diupdate",
                icon: "success",
                color: "white",
                background: "#364445",
                confirmButtonColor: '#F2AA7E'
            });

  }

    onMount(async () => {
      await getRoleName();
      await fetchAllPrivilege();
      await fetchTemplatePriv();
    });
   
  </script>

  <div class="mt-[90px] mx-8 mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={backToManageEmployee} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Edit Role & Privilege</span>       

    <div class="flex flex-col w-full px-8 mb-10">
        <div class="flex p-6 border-4 border-red-500 rounded-2xl mb-8">
            <div class="w-2/12 flex items-center justify-center">
                <i class="fa-solid fa-triangle-exclamation fa-5x" style="color: #dc2626;"></i>
            </div>
            <div class="w-10/12 flex flex-col">
                <span class="font-bold text-red-600 my-2 text-2xl">WARNING!</span>
                <p class="text-red-600 my-2 text-lg">Perubahan pada privilege default suatu role akan mempengaruhi semua employee dengan role tersebut.
                    <span class="font-bold">Pastikan perubahan privilege default dilakukan diluar jam kerja.</span>
                </p>
            </div>
        </div>
        <div class="flex flex-col my-1">
            <span class="text-darkGray font-semibold mb-1">Role Name</span>
            <input type="text" bind:value={role_name} class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
        <div class="flex flex-col my-1">
          <span class="text-darkGray font-semibold mb-1">Permissions</span>
          <ul class="font-semibold text-white ml-2">
            {#each all_privilege as privilege}
                <li class="mb-1 text-darkGray">
                    <div class="flex items-center">
                        {#if (priv_template_role.find((priv) => priv.Privileges.privileges_id == privilege.privileges_id) != null)}
                            <input on:change={() => {addPrivilegetoList(privilege.privileges_id)}} checked class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white  mr-2" type="checkbox">
                        {:else}
                            <input on:change={() => {addPrivilegetoList(privilege.privileges_id)}} class="border-2 border-darkGray bg-white focus:bg-darkGray focus:text-white checked:bg-darkGray checked:text-white  mr-2" type="checkbox">
                        {/if}
                        <span class="">{privilege.privileges_name}</span>
                    </div>
                </li>
            {/each}
          </ul>
        </div>
    </div>
    

    <div class="flex mb-10">
        <button on:click={() => {goto(`/manage_employee_owner`)}} class="w-48 py-3 bg-darkGray text-white font-semibold rounded-2xl text-xl hover:bg-[#252f30] mx-4">Close</button>
        <button on:click={() => {showModal = "confirm_edit"; showModal = showModal}} class="w-48 py-3 bg-peach text-darkGray font-semibold border border-darkGray rounded-2xl text-xl hover:bg-[#F2AA7E] mx-4">Save</button>    
    </div>

</div>

<!-- MODAL CONFIRM EDIT-->
{#if showModal == "confirm_edit" }
<TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
  <div class="flex items-center justify-center pt-8 font-roboto">
    <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Edit Role Default</div>
  </div>
  <form class="my-4 p-4 md:p-5 font-roboto text-xl">
        <div class="text-[#f7d4b2] font-medium text-center mb-8">
          Are you sure you want to submit the changes you've made?
        </div>
        <div class="flex items-center justify-center gap-4">
            <button type="button" on:click={() => closeModal()} class="mt-2 flex w-1/4 items-center justify-center bg-[#3d4c52] hover:bg-darkGray outline  hover:outline-[#f2b082] hover:text-[#f2b082] outline-[#f7d4b2] text-[#f7d4b2]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
              Back
            </button>
            <button type="button" on:click={async() => {await saveDefaultPrivilege(); closeModal()}} class="mt-2 flex w-1/4 items-center justify-center text-[#3d4c52] bg-[#f7d4b2] hover:bg-[#f2b082]  focus:outline-none font-semibold rounded-lg text-2xl px-6 py-1.5 text-center">
              Save
            </button>
        </div>
  </form>
</TaskModal> 
{/if}


  
  
