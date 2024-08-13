<script>

    export let value = 0; // Initial value in the smallest currency unit (e.g., Rp 400,000.00)
    export let currency = true;
    export let decimal = true;
    let curr = "";
    let digit = 0;
    if (currency){
        curr = "Rp ";
    }
    if (decimal){
        digit = 2;
    }
    
    let displayValue = formatCurrency(value); // Initialize displayValue with the formatted value
    
    function formatCurrency(value) {
        return curr + Number(value).toLocaleString('en-US', {
            minimumFractionDigits: digit,
            maximumFractionDigits: digit
        });
    }
</script>

<div>
    {displayValue}
</div>