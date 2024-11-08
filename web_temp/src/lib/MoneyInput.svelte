<script>
    export let value = 0;
    export let shadow = true;
    export let koma = false;
    export let end = true;
    $: displayValue = formatCurrency(value);
    function formatCurrency(value) {
        return "Rp " + Number(value).toLocaleString('en-US', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 2
        });
    }
    function handleInput(event) {
        const rawValue = event.target.value.replace(/[^0-9.]/g, ''); // Remove non-numeric and non-decimal characters
        if (rawValue === '' || !/^\d*\.?\d*$/.test(rawValue)) {
            value = 0; // Set to 0 if the input is empty or invalid
            displayValue = rawValue; // Show raw value while typing
        } else {
            value = Number(rawValue); // Convert to number
            if (value <= 0) {
                value = 1; // Set minimum value to 1 or any other positive value you prefer
            }
            displayValue = rawValue; // Show raw value while typing
        }
    }
    function handleBlur() {
        if (displayValue !== '') {
            displayValue = formatCurrency(value); // Format the value when input loses focus
        }
    }
    function handleFocus() {
        displayValue = value;
    }
</script>

<div class="">
    <input type="text"
           class={` ${shadow === true ? 'shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)]' : ''} text-[#3d4c52] ${end === true ? 'text-end' : 'text-start'} bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] block w-full px-2.5 py-0.5 h-8 `}
           placeholder={`Rp 0.00`}
           bind:value={displayValue}
           on:input={handleInput}
           on:blur={handleBlur}
           on:focus={handleFocus}
           required />
</div>