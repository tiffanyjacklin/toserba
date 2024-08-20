<script>
  import TransactionHistory from '$lib/TransactionHistory.svelte';
  export let data;

</script>

<div class="mt-[90px]">
  <TransactionHistory userId={data.userId} roleId={data.roleId}></TransactionHistory>
</div>