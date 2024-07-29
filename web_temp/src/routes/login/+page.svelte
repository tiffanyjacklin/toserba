<script>
	// @ts-nocheck

	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
</script>
<div id="cover" class="flex h-screen w-screen">
    <figure class="font-roboto shadow-xl container bg-[#3d4c52] w-11/12 max-w-3xl m-auto rounded-xl p-1 sm:p-2">
        <div class="flex flex-col sm:flex-row">
            <div class="welkombek items-center min-h-10 flex-none w-full sm:w-1/2 relative hidden sm:block max-[640px]:hidden">
                <div class="flex flex-col h-full w-full">
                    <div class="bg-[#f7d4b2] h-1/2 w-full mb-2.5 p-5 rounded-tl-2xl relative text-center">
                        <div class="bg-[#f8be7f] h-4/5 w-1/6 absolute top-0 left-36"></div>
                        <div class="select-none text-7xl text-[#3d4c52] tracking-wider absolute bottom-5 p-5 pb-0 text-center mt-2.5 font-semibold">Welcome</div>
                    </div>
                    <div class="select-none bg-[#f2b082] p-5 text-[#3d4c52] h-1/2 w-full text-8xl text-center rounded-bl-2xl font-semibold">Back.</div>
                </div>
            </div>
            <form action="?/login"
			method="post"
			use:enhance={() => {
				return async ({ result, update }) => {
					await update({ reset: false });
					// alert(result.data.data);
				};
			}} 
		class="flex-auto sm:p-4 sm:pr-2  max-[640px]:p-6  w-full sm:w-1/2 flex flex-col space-y-1">
                <div class="relative flex justify-center items-center pb-6 pt-6 select-none ">
                    <svg width="120" height="38" viewBox="0 0 239 76" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <g filter="url(#filter0_i_313_11)">
                        <path d="M39.0374 74H0.637375V1.99999H14.0774V63.44H39.0374V74ZM47.9654 42.512V32.24C48.5414 13.904 49.9814 0.271999 71.4854 0.271999C92.9894 0.271999 94.4294 13.904 95.0054 32.24V42.512C95.0054 61.712 93.5654 75.728 71.4854 75.728C49.4054 75.728 47.9654 61.712 47.9654 42.512ZM61.7894 29.264V49.232C61.7894 55.184 62.2694 64.88 71.4854 64.88C81.0854 64.88 81.1814 54.992 81.1814 48.08V29.648C81.1814 23.888 81.4694 11.12 71.4854 11.12C60.9254 11.12 61.7894 23.696 61.7894 29.264ZM106.077 42.512V32.24C106.653 13.904 108.093 0.271999 129.597 0.271999C141.117 0.367998 149.085 3.34399 152.157 15.824C152.829 18.704 152.733 21.68 152.829 24.56H139.389C139.197 17.264 138.717 11.504 129.597 11.12C119.037 11.12 119.901 23.696 119.901 29.264V49.232C119.901 55.184 120.381 64.88 129.597 64.88C137.277 64.88 139.773 56.72 139.485 45.872H130.173V35.312H152.541V74H142.461V65.744H142.269C139.581 73.232 134.493 75.344 129.597 75.728C107.517 75.728 106.077 61.712 106.077 42.512ZM179.548 74H166.108V1.99999H179.548V74ZM224.891 16.112V1.99999H238.331V74H224.315L213.851 48.368C210.299 39.824 207.419 31.088 204.251 19.76H204.059C204.539 25.712 205.115 33.008 205.499 40.304C205.883 47.504 206.171 54.704 206.171 60.464V74H192.731V1.99999H206.651L217.115 28.208C220.571 36.56 223.451 45.104 226.715 56.816H226.907C226.427 50.288 225.947 43.28 225.563 36.368C225.179 29.456 224.891 22.544 224.891 16.112Z" fill="#FACFAD"/>
                        </g>
                        <defs>
                            <filter id="filter0_i_313_11" x="0.636719" y="0.271973" width="237.695" height="79.4561" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
                                <feFlood flood-opacity="0" result="BackgroundImageFix"/>
                                <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape"/>
                                <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" result="hardAlpha"/>
                                <feOffset dy="4"/>
                                <feGaussianBlur stdDeviation="2"/>
                                <feComposite in2="hardAlpha" operator="arithmetic" k2="-1" k3="1"/>
                                <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.25 0"/>
                                <feBlend mode="normal" in2="shape" result="effect1_innerShadow_313_11"/>
                            </filter>
                        </defs>
                    </svg>
                        
                    <!-- <h1 class="relative text-6xl uppercase font-semibold text-[#f7d4b2] mb-6 drop-shadow-2xl select-none ">Login</h1> -->
                </div>
                <div class="w-full">
                    <label for="username" class="select-none text-sm leading-6 text-white block no-underline mt-1 font-medium">Username</label>
                    <div class="relative">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="stroke-[2px] absolute h-5 w-5 top-2 left-3 text-[#3d4c52]">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
                        </svg>
                        <input id="username" name="username" type="text" placeholder="Username" class="shadow-lg focus:ring-2 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full px-10 py-2 text-sm leading-6 text-slate-900 rounded-md  " required>
                    </div>
                </div>
                <div class="w-full">
                    <label for="password" class="select-none text-sm leading-6 text-white block no-underline mt-1 font-medium">Password</label>
                    <div class="relative">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" class="stroke-[2px] absolute h-5 w-5 top-2 left-3 text-[#3d4c52]">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 10.5V6.75a4.5 4.5 0 1 0-9 0v3.75m-.75 11.25h10.5a2.25 2.25 0 0 0 2.25-2.25v-6.75a2.25 2.25 0 0 0-2.25-2.25H6.75a2.25 2.25 0 0 0-2.25 2.25v6.75a2.25 2.25 0 0 0 2.25 2.25Z" />
                        </svg>
                        <input id="password" name="password" type="password" placeholder="Password" class="shadow-lg focus:ring-2 focus:ring-orange-300 focus:outline-none focus:border-0 appearance-none block w-full px-10 py-2 text-sm leading-6 text-slate-900 rounded-md" required>
                    </div>
                </div>
                <div>
                    <a href="/forgot-password" class="text-white block no-underline mt-1 font-medium text-sm  text-right mb-6">Forgot Password?</a>
                </div>
                <div  class="flex items-center justify-center pb-6 pt-6 ">
                    <button type="submit" class="h-10 w-1/2 px-6 inline-flex items-center justify-center font-bold rounded-md bg-f2b082 text-white hover:shadow-2xl">
                        LOGIN
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="stroke-[1.5px] w-6 h-6 ml-1">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M8.25 9V5.25A2.25 2.25 0 0 1 10.5 3h6a2.25 2.25 0 0 1 2.25 2.25v13.5A2.25 2.25 0 0 1 16.5 21h-6a2.25 2.25 0 0 1-2.25-2.25V15M12 9l3 3m0 0-3 3m3-3H2.25" />
                        </svg>
                    </button>
                </div>
                
            </form>
        </div>
    </figure>
</div>
<style lang="postcss">
	#cover{
		background: linear-gradient(45deg, #3d4c52 0%, #3d4c52 44%, #f7d4b2 44%, #f7d4b2 100%);
	}	
</style>


<!-- 
<style lang="postcss">
	@tailwind components;
	@layer components {
		label {
			@apply block text-sm font-semibold;
		}

		input {
			@apply p-1 rounded border;
		}

		button {
			@apply bg-teal-500 text-white p-1 rounded w-full my-1;
		}
	}
</style> -->
