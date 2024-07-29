<script>
	export let title = 'Bioskop';
</script>

<div class="flex items-center gap-4 p-2 px-4 shadow">
	<div>{title}</div>
	<slot />
	<div class="p-1 ml-auto border rounded-full size-8">PP</div>
</div>
