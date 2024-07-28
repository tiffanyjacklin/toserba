<script>
    import { browser } from '$app/environment';
    import { onMount } from 'svelte';
	import { goto } from '$app/navigation';
    export let data; 
    let title = '';
    let tasks = [];

    onMount(() => {
        if (browser) {
            const existingTasks = JSON.parse(localStorage.getItem(`tasks_${data.year}_${data.month}_${data.day}`)) || [];
            tasks = existingTasks;

            if (data.index !== undefined && data.index >= 0 && data.index < tasks.length) {
                title = tasks[data.index];
            }
        }
    });
	function saveTask() {
        if (browser) {
            if (title.trim() && data.index !== undefined) {
                tasks[data.index] = title; 
                localStorage.setItem(`tasks_${data.year}_${data.month}_${data.day}`, JSON.stringify(tasks));
                title = ''; 
                goto(`/monthly/${data.year}/${data.month}`);
            }
        }
    }
	function removeTask() {
        if (browser && data.index !== undefined && data.index >= 0 && data.index < tasks.length) {
            console.log('Removing task at index:', data.index);
            console.log('Tasks before removal:', tasks);

            const index = Number(data.index);
            if (isNaN(index)) {
                console.error('Invalid index:', data.index);
                return;
            }

            tasks = tasks.filter((_, i) => i !== index);

            console.log('Tasks after removal:', tasks);

            localStorage.setItem(`tasks_${data.year}_${data.month}_${data.day}`, JSON.stringify(tasks));

            goto(`/monthly/${data.year}/${data.month}`);
        } else {
            console.error('Invalid data.index or browser environment');
        }
    }


    function cancelEdit() {
        goto(`/monthly/${data.year}/${data.month}`); 
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
    <div class="text-2xl font-semibold mb-4 flex justify-between">
        <div>Edit Task for {data.day} {getMonthName(data.month)} {data.year}</div>
		<button
            on:click={removeTask}
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-red-600  hover:bg-pink-100"
        >
		<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-6">
			<path fill-rule="evenodd" d="M16.5 4.478v.227a48.816 48.816 0 0 1 3.878.512.75.75 0 1 1-.256 1.478l-.209-.035-1.005 13.07a3 3 0 0 1-2.991 2.77H8.084a3 3 0 0 1-2.991-2.77L4.087 6.66l-.209.035a.75.75 0 0 1-.256-1.478A48.567 48.567 0 0 1 7.5 4.705v-.227c0-1.564 1.213-2.9 2.816-2.951a52.662 52.662 0 0 1 3.369 0c1.603.051 2.815 1.387 2.815 2.951Zm-6.136-1.452a51.196 51.196 0 0 1 3.273 0C14.39 3.05 15 3.684 15 4.478v.113a49.488 49.488 0 0 0-6 0v-.113c0-.794.609-1.428 1.364-1.452Zm-.355 5.945a.75.75 0 1 0-1.5.058l.347 9a.75.75 0 1 0 1.499-.058l-.346-9Zm5.48.058a.75.75 0 1 0-1.498-.058l-.347 9a.75.75 0 0 0 1.5.058l.345-9Z" clip-rule="evenodd" />
		  </svg>
		  
        </button>
    </div>

    <div class="mb-4">
        <label for="task-title" class="block text-sm font-medium text-gray-700 mb-2">
            Task Title
        </label>
        <input
            id="task-title"
            type="text"
            bind:value={title}
            placeholder="Edit task title"
            class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
        />
    </div>

    <div class="flex justify-between">
        <button
            on:click={cancelEdit}
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-gray-700 bg-gray-200 hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500"
        >
            Back
        </button>
		<button
            on:click={saveTask}
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-500 hover:bg-blue-600 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
        >
            Save
        </button>
        
        
    </div>
</div>
