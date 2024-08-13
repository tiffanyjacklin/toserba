<script>
    export let value = 0; // Initial value in the smallest currency unit (e.g., Rp 400,000.00)
    let displayValue = formatCurrency(value); // Initialize displayValue with the formatted value

    function formatCurrency(value) {
        return "Rp " + Number(value).toLocaleString('en-US', {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        });
    }

    function handleInput(event) {
        // Update displayValue while keeping the "Rp" prefix
        displayValue = "Rp " + event.target.value.replace(/[^\d,.]/g, ''); 
    }

    function handleBlur() {
        const rawValue = displayValue.replace(/[^\d.]/g, ''); // Remove all non-numeric and non-period characters
        value = parseFloat(rawValue.replace(/,/g, '')) || 0; // Convert to number or default to 0
        displayValue = formatCurrency(value); // Format the value with the "Rp" prefix
    }

    function handleFocus() {
        const rawValue = displayValue.replace(/[^\d.]/g, ''); // Show raw value without "Rp" but keep decimal places
        displayValue = rawValue !== '' ? rawValue : '0.00'; // Ensure there is always something to display
    }
</script>

<div>
    <input type="text"
           class="shadow-[inset_0_2px_3px_rgba(0,0,0,0.4)] text-[#3d4c52] text-end bg-white text-md rounded-lg focus:ring-[#f7d4b2] focus:border-[#f7d4b2] block w-full px-2.5 py-0.5"
           placeholder="Rp 0.00"
           bind:value={displayValue}
           on:input={handleInput}
           on:blur={handleBlur}
           on:focus={handleFocus}
           required />
</div>
