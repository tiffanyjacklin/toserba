<script>
    export let value = 0; // Initial value in the smallest currency unit (e.g., Rp 400,000.00)
    export let currency = true;
    export let decimal = true;
 
    // Reactive variable to store the formatted value
    let displayValue;
 
    // Use reactive statement to update displayValue whenever value, currency, or decimal changes
    $: {
       let curr = currency ? "Rp " : "";
       let digit = decimal ? 2 : 0;
       
       displayValue = formatCurrency(value, curr, digit);
    }
 
    function formatCurrency(value, curr, digit) {
       return curr + Number(value).toLocaleString('en-US', {
          minimumFractionDigits: digit,
          maximumFractionDigits: digit
       });
    }
 </script>
 
 <div>
    {displayValue}
 </div>
 