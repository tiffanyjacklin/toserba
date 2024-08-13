<script>
  import TransactionHistory from '$lib/TransactionHistory.svelte';
  export let data;

</script>

<TransactionHistory userId={data.userId} roleId={data.roleId}></TransactionHistory>