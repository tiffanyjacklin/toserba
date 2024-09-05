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


    // onMount(async () => {
    //   await getAddStocktDetails();
    // });
   
  </script>

  <div class="mt-[90px] mx-8 mb-10 pb-10 p-3 flex flex-col items-center justify-center bg-white shadow-[inset_0_2px_3px_rgba(0,0,0,0.2)] rounded-lg">
    <div class="w-full flex justify-start">
        <button on:click={backToManageEmployee} class="text-xl font-bold self-start p-4 hover:bg-gray-300 rounded-xl"><i class="fa-solid fa-less-than mr-2"></i>Back</button>  
    </div>
    <span class="text-4xl font-bold font-roboto text-[#364445] my-10">Edit Role & Privilege</span>       

    <div class="flex flex-col w-full px-8 mb-10">
        <div class="flex flex-col my-1">
            <span class="text-darkGray font-semibold mb-1">Role Name</span>
            <input type="text" value="nama role" class="rounded-xl focus:ring-peach2 focus:border focus:border-peach2">
        </div>
        <div class="flex flex-col my-1">
            <span class="text-darkGray font-semibold mb-1">Role Description</span>
            <textarea type="text" rows="4" value="desc role baru" class=" rounded-xl focus:ring-peach2 focus:border focus:border-peach2"></textarea>
        </div>
        <div class="flex flex-col my-1">
          <span class="text-darkGray font-semibold mb-1">Permissions</span>
          <ul class="font-semibold text-white ml-2">
              <li class="mb-1 text-darkGray">
                <div class="flex items-center">
                  <input value="null" class="border border-darkGray bg-white  mr-2" type="checkbox">
                  <span class="">nama Permissions</span>
                </div>
              </li>
              <li class="mb-1 text-darkGray">
                <div class="flex items-center">
                  <input value="null" class="border border-darkGray bg-white  mr-2" type="checkbox">
                  <span class="">nama Permissions</span>
                </div>
              </li>
              <li class="mb-1 text-darkGray">
                <div class="flex items-center">
                  <input value="null" class="border border-darkGray bg-white  mr-2" type="checkbox">
                  <span class="">nama Permissions</span>
                </div>
              </li>
              <li class="mb-1 text-darkGray">
                <div class="flex items-center">
                  <input value="null" class="border border-darkGray bg-white  mr-2" type="checkbox">
                  <span class="">nama Permissions</span>
                </div>
              </li>
          </ul>
        </div>
    </div>
    

    <div class="flex mb-10">
        <button class="w-48 py-3 bg-darkGray text-white font-semibold rounded-2xl text-xl hover:bg-[#252f30] mx-4">Close</button>
        <button class="w-48 py-3 bg-peach text-darkGray font-semibold border border-darkGray rounded-2xl text-xl hover:bg-[#F2AA7E] mx-4">Save</button>
    </div>

</div>


  
  
