<script>
    import { currentDate, monthYear, gotoPreviousMonth, gotoNextMonth } from '$lib/monthyear';
	import dots_menu from '$lib/assets/dots-menu.svg';
	import caret from '$lib/assets/caret-down-sharp.svg';
	import logo from '$lib/assets/naver1.png';
    import coups from '$lib/assets/coups.png';
	export let title = 'Calendar';

	
	let isHelpDropdownOpen = false;
    let isSettingsDropdownOpen = false;
    let isCalendarDropdownOpen = false;

    const toggleDropdown = (dropdown) => {
        if (dropdown === 'help') {
            isHelpDropdownOpen = !isHelpDropdownOpen;
            isSettingsDropdownOpen = false;
            isCalendarDropdownOpen = false;
        } else if (dropdown === 'settings') {
            isSettingsDropdownOpen = !isSettingsDropdownOpen;
            isHelpDropdownOpen = false;
            isCalendarDropdownOpen = false;
        } else if (dropdown === 'calendar') {
            isCalendarDropdownOpen = !isCalendarDropdownOpen;
            isHelpDropdownOpen = false;
            isSettingsDropdownOpen = false;
        }
    };

    const handleDropdownFocusLoss = (event, dropdown) => {
        if (event.relatedTarget && event.currentTarget.contains(event.relatedTarget)) return;
        toggleDropdown(dropdown);
    };
</script>
	<div class=" flex items-center gap-4 p-2 px-4 select-none border-b">

		<a href="/"><img src={logo} class="w-5"></a>
		<div class="text-lg	text-gray-600 font-medium"><a href="/">{title}</a></div>
		<slot />
		

		
		<div class="ml-auto flex items-center gap-3 text-gray-500 bold">
			<!-- Search Button -->
			<button type="button" class="px-1.5 py-1.5 text-sm font-medium text-gray-600 bg-transparent hover:bg-gray-100 focus:bg-gray-200 rounded-full">
				<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
					<path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
				</svg>
			</button>
		
			<!-- Help Button -->
			<button id="helpButton" type="button" class="px-1.5 py-1.5 text-sm font-medium text-gray-600 bg-transparent hover:bg-gray-100 focus:bg-gray-200 rounded-full dropdown"
				on:click={() => toggleDropdown('help')}
				on:focusout={(e) => handleDropdownFocusLoss(e, 'help')}>
				<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
					<path stroke-linecap="round" stroke-linejoin="round" d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 5.25h.008v.008H12v-.008Z" />
				</svg>
			</button>
			<div id="helpDropdown" class={isHelpDropdownOpen ? 'absolute pt-1 pb-1 top-[52px] w-max origin-top-right block bg-white divide-y divide-gray-100 rounded shadow-[0_0_5px_1px_rgba(0,0,0,0.2)]' : 'z-10 hidden'}>
				<ul class="py-2 text-sm text-gray-600 dark:text-gray-200" aria-labelledby="helpButton">
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Help</a></li>
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Training</a></li>
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Updates</a></li>
				</ul>
				<ul class="py-2 text-sm text-gray-600 dark:text-gray-200" aria-labelledby="settingsButton">
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Send feedback to Tiffany</a></li>
				</ul>
			</div>
		
			<!-- Settings Button -->
			<button id="settingsButton" type="button" class="px-1.5 py-1.5 text-sm font-medium text-gray-600 bg-transparent hover:bg-gray-100 focus:bg-gray-200 rounded-full dropdown"
				on:click={() => toggleDropdown('settings')}
				on:focusout={(e) => handleDropdownFocusLoss(e, 'settings')}>
				<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
					<path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.325.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.241-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.124.072-.044.146-.086.22-.128.332-.183.582-.495.644-.869l.214-1.28Z" />
					<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
				</svg>
			</button>
			<div id="settingsDropdown" class={isSettingsDropdownOpen ? 'absolute pt-1 pb-1 top-[52px] w-max  block bg-white divide-y divide-gray-100 rounded shadow-[0_0_5px_1px_rgba(0,0,0,0.2)]' : 'z-10 hidden'}>
				<ul class="py-2 text-sm text-gray-600 dark:text-gray-200" aria-labelledby="settingsButton">
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Settings</a></li>
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Trash</a></li>
				</ul>
				<ul class="py-2 text-sm text-gray-600 dark:text-gray-200" aria-labelledby="settingsButton">
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Density and color</a></li>
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Print</a></li>
				</ul>
				<ul class="py-2 text-sm text-gray-600 dark:text-gray-200" aria-labelledby="settingsButton">
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white">Get add-ons</a></li>
				</ul>
			</div>
		
			<!-- Calendar Dropdown Button -->
			<button id="CalendarDropdownButton" type="button" class="text-gray-800 bg-white border border-gray-300 hover:bg-gray-50 focus:bg-gray-200 font-medium rounded text-[13px] ml-2 px-2.5 py-1.5 text-center inline-flex items-center dropdown"
				on:click={() => toggleDropdown('calendar')}
				on:focusout={(e) => handleDropdownFocusLoss(e, 'calendar')}>
				Month
				<img src="{caret}" alt="" img="dots-menu" class="ml-3 w-2" />
			</button>
		
			<!-- Calendar Dropdown Menu -->
			<div id="CalendarDropdown" class={isCalendarDropdownOpen ? ' absolute pt-1 pb-1 top-[52px] w-max  block bg-white divide-y divide-gray-100 rounded shadow-[0_0_5px_1px_rgba(0,0,0,0.2)]' : 'z-10 hidden'}>
				<ul class="py-2 text-sm text-gray-700" aria-labelledby="CalendarDropdownButton">
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 justify-between flex">
						<p>Day</p>
						<p class="text-gray-500">D</p>
					</a></li>
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 justify-between flex">
						<p>Week</p>
						<p class="text-gray-500">W</p>
					</a></li>
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 justify-between flex">
						<p>Month</p>
						<p class="text-gray-500">M</p>
					</a></li>
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 justify-between flex">
						<p>Year</p>
						<p class="text-gray-500">Y</p>
					</a></li>
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 justify-between flex">
						<p>Schedule</p>
						<p class="text-gray-500">A</p>
					</a></li>
					<li><a href="#" class="block px-4 py-2 hover:bg-gray-100 justify-between flex">
						<p>4 days</p>
						<p class="text-gray-500">X</p>
						
					</a></li>
				</ul>
				<ul class="py-2 text-sm text-gray-700" >
					<li>
						<a href="#" class=" w-full px-4 py-2 text-left text-sm flex gap-4 hover:bg-gray-100">
							<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-5">
								<path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
							</svg>
							Show weekends
						</a>
					</li>
					<li>
						<a href="#" class=" w-full px-4 py-2 text-left text-sm flex gap-4 hover:bg-gray-100">
							<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-5">
								<path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
							</svg>
							Show declined events
						</a>
					</li>
					<li>
						<a href="#" class=" w-full px-4 py-2 text-left text-sm flex gap-4 hover:bg-gray-100">
							<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-5">
								<path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
							</svg>
							Show completed tasks
						</a>
					</li>
					<li>
						<a href="#" class=" w-full px-4 py-2 text-left text-sm flex gap-4 hover:bg-gray-100">
							<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-5">
								<path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5" />
							</svg>
							<div>Show appointment schedule</div>
						</a>
					</li>
				</ul>
			</div>
			<div class="ml-auto inline-flex rounded-md shadow-sm" role="group">
				<button type="button" class="px-4 py-1.5 text-sm font-medium text-blue-600 bg-blue-100 border border-gray-200 rounded-s">
					<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
						<path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5m-9-6h.008v.008H12v-.008ZM12 15h.008v.008H12V15Zm0 2.25h.008v.008H12v-.008ZM9.75 15h.008v.008H9.75V15Zm0 2.25h.008v.008H9.75v-.008ZM7.5 15h.008v.008H7.5V15Zm0 2.25h.008v.008H7.5v-.008Zm6.75-4.5h.008v.008h-.008v-.008Zm0 2.25h.008v.008h-.008V15Zm0 2.25h.008v.008h-.008v-.008Zm2.25-4.5h.008v.008H16.5v-.008Zm0 2.25h.008v.008H16.5V15Z" />
					</svg>
				</button>
				<button type="button" disabled class="px-4 py-1.5 text-sm font-medium text-gray-900 bg-white border border-gray-200 rounded-e hover:bg-gray-100 focus:z-10 focus:ring-2 focus:ring-blue-700 focus:text-blue-700 ">
					<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5">
						<path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
					</svg>
				</button>
			</div>
			<button type="button" class="px-2.5 py-2.5 text-sm font-medium text-gray-600 bg-transparent hover:bg-gray-200 focus:bg-gray-200 rounded-full ">
				<img src={dots_menu} alt="" img="dots-menu" class="w-3.5" />
			</button>
			<div class="ml-auto border rounded-full w-8 h-8 flex items-center justify-center overflow-hidden ">
				<img src={coups} class="rounded-full w-full">
			</div>
		</div>


	</div>
