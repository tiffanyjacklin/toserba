<script>
	import { browser } from '$app/environment';
	import { goto } from '$app/navigation';
    import { onMount } from 'svelte';
    export let data;    
    let title = '';
    export let tasks = [];

    onMount(() => {
		if (browser){
			const existingTasks = JSON.parse(localStorage.getItem(`tasks_${data.year}_${data.month}_${data.day}`)) || [];
        	tasks = existingTasks;
		}
    });
	function cancelAdd() {
        goto(`/monthly/${data.year}/${data.month}`);
    }
    function saveTask() {
		if (browser){
			if (title.trim()) {
				tasks = [...tasks, title];
				localStorage.setItem(`tasks_${data.year}_${data.month}_${data.day}`, JSON.stringify(tasks));
				title = '';
			}
			console.log(tasks);
			goto(`/monthly/${data.year}/${data.month}`); 
		}
       
    }
	function getMonthName(month) {
		const months = [
			'January', 'February', 'March', 'April', 'May', 'June',
			'July', 'August', 'September', 'October', 'November', 'December'
		];
		return months[month - 1];
	}
</script>
<div class="container mx-auto p-6 max-w-md bg-white shadow-lg rounded-lg">
    <h1 class="text-2xl font-semibold mb-4">
        Add New Task for {data.day} {getMonthName(data.month)} {data.year}
    </h1>

    <div class="mb-4">
        <label for="task-title" class="block text-sm font-medium text-gray-700 mb-2">
            Task Title
        </label>
        <input
            id="task-title"
            type="text"
            bind:value={title}
            placeholder="Enter task title"
            class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        />
    </div>

    <div class="flex justify-between">
        <button
            on:click={cancelAdd}
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-gray-700 bg-gray-200 hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
        >
            Back
        </button>
		<button
            on:click={saveTask}
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-500 hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
            Add
        </button>
        
    </div>
</div>
