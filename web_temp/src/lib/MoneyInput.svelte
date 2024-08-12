<script>
    export let value = 0; // Initial value in the smallest currency unit (e.g., Rp 400,000.00)
    let displayValue = formatCurrency(value);

    function formatCurrency(value) {
        return "Rp " + Number(value).toLocaleString('id-ID', {
            minimumFractionDigits: 2,
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
            displayValue = rawValue; // Show raw value while typing
        }
    }

    function handleBlur() {
        if (displayValue !== '') {
            displayValue = formatCurrency(value); // Format the value when input loses focus
        }
    }

    function handleFocus() {
        displayValue = value.toFixed(2).toString(); // Show raw value with two decimal places when input is focused
    }
</script>

<div class="">
    <input type="text"
           class="shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] text-end bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] block w-full px-2.5 py-0.5"
           placeholder="0.00"
           bind:value={displayValue}
           on:input={handleInput}
           on:blur={handleBlur}
           on:focus={handleFocus}
           required />
</div>