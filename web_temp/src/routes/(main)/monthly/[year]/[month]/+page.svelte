<script>
    import { browser } from '$app/environment';
    import { goto } from '$app/navigation';
    import { currentDate, monthYear, gotoPreviousMonth, gotoNextMonth, gotoToday, updateMonthYear, daysInMonth, tasksStore, loadTasks} from '$lib/monthyear';
	import { thisMonth } from '$lib/this_month.js';
    import { onMount } from 'svelte';

    export let data;

    const days_name = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    let tasks = {}; 
    $: selectedYear = data.year;
    $: selectedMonth = data.month;
    $: formattedMonthYear = `${new Date(selectedYear, selectedMonth - 1).toLocaleDateString('en-US', { month: 'long' })} ${selectedYear}`;
    $: daysInMonthArray = [];
    const unsubscribe = daysInMonth.subscribe(value => {
        daysInMonthArray = value;
    });
    $: tasksStoreValue = {};
    const unsubscribeTasks = tasksStore.subscribe(value => {
        tasksStoreValue = value;
        tasks = tasksStoreValue;
    });
    
    onMount(() => {
        if (browser) {
            currentDate.setFullYear(selectedYear);
            currentDate.setMonth(selectedMonth - 1);
            updateMonthYear();
            
            const numDays = new Date(selectedYear, selectedMonth, 0).getDate(); 
            const startDay = new Date(selectedYear, selectedMonth - 1, 1).getDay(); 

            for (let day = 1; day <= numDays; day++) {
                const dateKey = `tasks_${selectedYear}_${selectedMonth}_${day}`;
                const existingTasks = JSON.parse(localStorage.getItem(dateKey)) || [];
                if (existingTasks.length > 0) {
                    tasks[dateKey] = existingTasks;
                }
            }
        }
    });

    function handleDayClick(day, index = null) {
        if (index === null) {
            goto(`/monthly/${selectedYear}/${selectedMonth}/${day}/new`);
        } else {
            goto(`/monthly/${selectedYear}/${selectedMonth}/${day}/edit/${index}`);
        }
    }



</script>
<div class=" flex justify-center">
	<div class="flex items-center mb-4">
		<div class="text-lg text-gray-600 font-normal">{formattedMonthYear}</div>
		<button type="button" on:click={gotoPreviousMonth} class="px-0.5 py-0.5 ml-3 text-sm font-medium text-gray-600 bg-transparent hover:bg-gray-100 focus:bg-gray-200 rounded-full ">
			<svg class="w-6 h-6 text-gray-600 dark:text-white" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
				<path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m14 8-4 4 4 4"/>
			</svg>
		</button>
		<button type="button" on:click={gotoNextMonth} class="px-0.5 py-0.5 mr-3 text-sm font-medium text-gray-600 bg-transparent hover:bg-gray-100 focus:bg-gray-200 rounded-full ">
			<svg class="w-6 h-6 text-gray-600 dark:text-white" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24">
				<path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m10 16 4-4-4-4"/>
			</svg>
		</button>
		<button type="button" on:click={gotoToday} class="text-gray-800 bg-white border border-gray-300 focus:outline-none hover:bg-gray-50 font-medium rounded text-[13px] px-2.5 py-1.5">
			Today
		</button>
	</div>
</div>

<div class="grid grid-cols-7 gap-0">
    {#each days_name as day}
        <div class="border-r border-t p-0 pt-1 text-gray-500 text-xs font-medium text-center">
            {day}
        </div>
    {/each}
    
    {#each daysInMonthArray as day, i}
        <div class="border-r border-b pt-1 p-0 min-h-24 text-xs font-medium text-center cursor-pointer"
             on:click={() => handleDayClick(day)}>
            {#if day}
                {day}
                {#if tasks[`tasks_${selectedYear}_${selectedMonth}_${day}`]}
                    <ul>
                        {#each tasks[`tasks_${selectedYear}_${selectedMonth}_${day}`] as task, index}
                            <li class="z-50" on:click={(e) => {
                                e.stopPropagation();
                                handleDayClick(day, index);
                            }}>
                                <div class="bg-pink-100 m-1 px-2 text-xs rounded flex justify-start">
                                    {task}
                                </div>
                            </li>
                        {/each}
                    </ul>
                {/if}
            {/if}
        </div>
    {/each}
</div>