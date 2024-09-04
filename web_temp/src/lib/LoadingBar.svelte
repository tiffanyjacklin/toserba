<script>
    export let loading = false;
</script>

<style>
@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
</style>

{#if loading}
<div class="fixed top-0 left-0 w-full h-screen flex justify-center items-center z-[200] backdrop-brightness-90 ">
    <i class="fa-solid fa-spinner fa-2xl animate-spin"></i>
</div>
{/if}