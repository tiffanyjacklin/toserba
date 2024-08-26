<script>
	export let title = 'Toserba';
   import { goto } from '$app/navigation';
</script>
<nav class="fixed top-0 z-40 w-full bg-peach">
   <div class="px-5 py-3 ml-auto select-none	">
      <div class="flex items-center justify-start">
         <div class="w-0 lg:w-64 md:w-64"></div>
         <div class="flex items-center justify-start rtl:justify-end">
            <button data-drawer-target="logo-sidebar" data-drawer-toggle="logo-sidebar" aria-controls="logo-sidebar" type="button" class="inline-flex items-center p-2 text-sm text-gray-500 rounded-lg sm:hidden hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600">
                <span class="sr-only">Open sidebar</span>
                <svg class="w-6 h-6" aria-hidden="true" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                   <path clip-rule="evenodd" fill-rule="evenodd" d="M2 4.75A.75.75 0 012.75 4h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 4.75zm0 10.5a.75.75 0 01.75-.75h7.5a.75.75 0 010 1.5h-7.5a.75.75 0 01-.75-.75zM2 10a.75.75 0 01.75-.75h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 10z"></path>
                </svg>
             </button>
         </div>
         <span class="ml-2 text-xl font-extrabold sm:text-2xl whitespace-nowrap text-darkGray uppercase">{title}</span>
         <slot/>
         
         <div class="flex items-center ml-auto">
            <button on:click={() => goto('/help')} class="flex items-center mx-8 hover:text-[#404c54]" type="button">
               <i class="fa-regular fa-circle-question fa-lg mr-2"></i> 
               <div class="font-xl font-bold font-roboto">Help</div>
            </button>
            <button on:click={() => goto('/notifications')} class="flex mr-4 hover:text-[#404c54]" type="button">
               <i class="fa-regular fa-bell fa-lg"></i>
            </button>
         </div>
      </div>
   </div>
</nav>