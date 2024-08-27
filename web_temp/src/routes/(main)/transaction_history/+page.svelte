<script>
  import TransactionHistory from '$lib/TransactionHistory.svelte';
	import { sessionId } from '$lib/uri.js';
  export let data;
  sessionId.set(String(0));
</script>

<div class="mt-[90px]">
  <TransactionHistory></TransactionHistory>
</div>