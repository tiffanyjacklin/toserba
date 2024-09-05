<script>
    import TaskModal from '$lib/TaskModal.svelte';
    import MoneyConverter from '$lib/MoneyConverter.svelte';
    import DateConverter from '$lib/DateConverter.svelte';
    import receipt from '$lib/assets/receipt-1.png';
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    import { uri } from '$lib/uri.js';
    import user_pp from "$lib/assets/user.png";

    export let data;
    // let user_id = data.user_id;
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


    $: editMode = false;
    // onMount(async () => {
    //   await getAddStocktDetails();
    // });
   
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
                    <span class="">Alexander Louis</span>
                {:else}
                    <input type="text" value="Alexander Louis" class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Role</span>
                <span class="">Admin</span>
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Email</span>
                {#if editMode == false}
                    <span class="">alexlo@gmail.com</span>
                {:else}
                    <input type="text" value="alexlo@gmail.com" class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Phone Number</span>
                {#if editMode == false}
                    <span class="">08123456789</span>
                {:else}
                    <input type="text" value="08123456789" class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Join Date</span>
                {#if editMode == false}
                    <span class="">XX/XX/20XX</span>
                {:else}
                    <input type="date" class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Birthday</span>
                {#if editMode == false}
                    <span class="">XX/XX/20XX</span>
                {:else}
                    <input type="date" class="w-2/3 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Gender</span>
                {#if editMode == false}
                    <span class="">Male</span>
                {:else}
                    <select class="w-48 p-2 rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                    </select>
                {/if}
            </div>
            <div class="flex flex-col my-2">
                <span class="text-peach2">Employee Address</span>
                <span class="">Jl Jeruk Busuk Jaya Abadi No.52, Kec.Rungkut, Surabaya, Jawa Timur</span>
            </div>
            <div class="flex flex-col my-2">
                <button class="w-40 py-2 rounded-2xl font-semibold bg-darkGray text-peach2 shadow">Delete Employee</button>
            </div>
        </div>
        <div class="flex flex-col w-1/3">
            <img src={user_pp} class="w-60 rounded-xl border border-darkGray">
        </div>
    </div>

    <div class="flex mb-10">
        {#if editMode == false}
            <button class="w-48 py-3 bg-darkGray text-white font-semibold rounded-2xl text-xl hover:bg-[#252f30]">Close</button>
        {:else}
            <button class="w-48 py-3 bg-peach text-darkGray font-semibold border border-darkGray rounded-2xl text-xl hover:bg-[#F2AA7E]">Save</button>
        {/if}
    </div>

</div>


<!-- MODAL REASSIGN EMPLOYEE -->
{#if showModal == "reassign" }
  <TaskModal open={showModal} onClose={closeModal} color={"#3d4c52"}>
    <div class="flex items-center justify-center pt-8 font-roboto">
      <div class="text-shadow-[inset_0_0_5px_rgba(0,0,0,0.6)] text-white font-roboto text-4xl font-medium">Choose Product</div>
    </div>
    <div class="flex flex-col justify-center p-8">
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold">Employee Role</span>
        <select class="w-full p-2 rounded-xl">
            <option value="">Cashier</option>
            <option value="" >Admin</option>
        </select>
        <button on:click={() => {showModal = "create_role"}} class="w-40 bg-peach2 text-darkGray font-semibold py-1.5 rounded-2xl border border-black my-1">+ Add New Role</button>
      </div>
      <div class="flex flex-col my-1">
        <span class="text-peach font-semibold">Assigned Location</span>
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
        <button class="w-36 py-2 bg-peach text-darkGray border border-peach mx-4 rounded-xl font-semibold">Reassign</button>
      </div>
    </div>
  </TaskModal> 
  {/if}

  <!-- MODAL CREATE NEW ROLE -->
{#if showModal == "create_role" }
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
  {/if}

  
  
