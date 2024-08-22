<script>
    export let open = false;
    export let onClose = () => {};
    export let color = "#f7d4b2";

    function close() {
        onClose();
    }
    function handleKeyDown(event) {
        if (event.key === 'Escape') {
            close();
        }
    }
</script>

{#if open}
     <div class="overlay" role="dialog" aria-labelledby="modal-title" on:click={close} on:keydown={handleKeyDown}>
        <div class="overflow-y-scroll max-h-full overflow-y-auto modal-content bg-[{color}] shadow-[0_6px_0px_0px_rgba(242,176,130,1)]" on:click|stopPropagation >
            <!-- <button class="close-button" type="button" on:click={close}>✖</button> -->
            <button type="button" on:click={close} class="close-button text-gray-400 bg-transparent hover:bg-gray-200 hover:text-white rounded-lg text-sm w-8 h-8 ms-auto inline-flex justify-center items-center dark:hover:bg-gray-600 dark:hover:text-white" data-modal-toggle="crud-modal">
                <svg class="w-3 h-3" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
                    <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
                </svg>
                <span class="sr-only">Close modal</span>
            </button>
            <slot></slot>
        </div>
    </div>
{/if}

<style>
    .overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 1000;
    }

    .modal-content {
        /* background: white; */
        padding: 10px;
        border-radius: 8px;
        position: relative;
        width: 100%;
        max-width: 550px;
    }

    .close-button {
        position: absolute;
        top: 32px;
        right: 32px;
        border: none;
        background: transparent;
        font-size: 24px;
        cursor: pointer;
    }
</style>
