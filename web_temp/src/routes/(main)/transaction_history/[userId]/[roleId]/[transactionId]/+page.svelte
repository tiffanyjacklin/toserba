<script>
  import TransactionHistoryDetails from '$lib/TransactionHistoryDetails.svelte';
  export let data;

</script>

<TransactionHistoryDetails transactionId={data.transactionId} userId={data.userId} roleId={data.roleId}></TransactionHistoryDetails>