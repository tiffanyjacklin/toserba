<script>
   import SessionHistory from '$lib/SessionHistory.svelte';
   import { onMount } from 'svelte';

   export let data;
   let session = [];
   async function fetchLast() {
      const response = await fetch(`http://leap.crossnet.co.id:8888/cashier/session`, {
         method: 'GET',
         headers: {
               'Content-Type': 'application/json'
         }
      });

      if (!response.ok) {
         console.error('last session fetch failed', response);
         return;
      }

      const data = await response.json();

      if (data.status !== 200) {
         console.error('Invalid fetch last', data);
         return;
      }

      session = data.data;
   //   console.log(last_session);
   }
   onMount(() => {
        fetchLast();
   });

</script>

<SessionHistory session={session} userId={data.userId}></SessionHistory>