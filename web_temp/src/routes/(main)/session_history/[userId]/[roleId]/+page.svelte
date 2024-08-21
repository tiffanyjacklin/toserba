<script>
   import SessionHistory from '$lib/SessionHistory.svelte';
   import { onMount } from 'svelte';

   export let data;
   
</script>

<SessionHistory sessionId={0} userId={data.userId} roleId={data.roleId}></SessionHistory>