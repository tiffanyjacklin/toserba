<script>
    export let value = "0000-00-00 00:00:00";
    export let date = true; 
    export let hour = true;
    export let second = true;
    export let ampm = true;
    export let monthNumber = true;
    export let dash = true;
    export let dateFirst = true;

    let displayValue = formatDate(value);

    $: {
        displayValue = formatDate(value);
    }

    function formatDate(value) {
        // console.log("Raw value:", value);
        if (!value || 
            !/^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})$/.test(value) && 
            !/^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)$/.test(value)) {
            return "Invalid Date";
        }

        // Handle splitting based on the format
        let datePart, timePart;

        if (value.includes(' ')) {
            // Handle "YYYY-MM-DD HH:MM:SS"
            [datePart, timePart] = value.split(' ');
        } else if (value.includes('T')) {
            // Handle "YYYY-MM-DDTHH:MM:SSZ"
            [datePart, timePart] = value.split('T');
            // Remove trailing "Z" from the time part
            timePart = timePart.replace('Z', '');
        }

        // Validate the splitting worked
        if (!datePart || !timePart) return "Invalid Date";

        // Further extract date and time components
        let [year, month, day] = datePart.split('-').map(Number);
        let [hours, minutes, seconds] = timePart.split(':').map(Number);

        if (isNaN(year) || isNaN(month) || isNaN(day) || isNaN(hours) || isNaN(minutes) || isNaN(seconds)) {
            return "Invalid Date";
        }

        let dateObj = new Date(year, month - 1, day, hours, minutes, seconds || 0);
        if (isNaN(dateObj.getTime())) return "Invalid Date";

        let dayStr = day.toString().padStart(2, '0');
        let monthStr = (month).toString().padStart(2, '0');
        let yearStr = year.toString();

        let hoursStr = hours.toString().padStart(2, '0');
        let minutesStr = minutes.toString().padStart(2, '0');
        let secondsStr = seconds.toString().padStart(2, '0');

        let ampmText = '';
        if (ampm) {
            ampmText = hours >= 12 ? 'PM' : 'AM';
            hours = hours % 12 || 12;
        }

        let separator = monthNumber ? (dash ? '-' : '/') : ' ';

        let monthDisplay = monthNumber ? (dash ? monthStr + '-' : monthStr + '') :
        dateObj.toLocaleString('default', { month: 'long' });

        let datePartFormatted;
        if (monthNumber) {
            // Ensure the separator is placed correctly between day, month, and year
            datePartFormatted = `${dayStr}${separator}${monthStr}${separator}${yearStr}`;
        } else {
            datePartFormatted = `${dayStr} ${dateObj.toLocaleString('default', { month: 'long' })} ${yearStr}`;
        }

        // console.log(`Month: ${monthNumber}, Dash: ${dash}`);
        // console.log(separator);
        let timePartFormatted = `${hoursStr}:${minutesStr}`;
        if (second) {
            timePartFormatted += `:${secondsStr}`;
        }
        timePartFormatted += ampm ? ` ${ampmText}` : '';

        // let datePartFormatted = `${dayStr}${separator}${monthDisplay}${separator}${yearStr}`;
        
        // console.log("Formatted Date Part:", datePartFormatted); // Debugging: Check formatted date part
        // console.log("Formatted Time Part:", timePartFormatted); // Debugging: Check formatted time part

        if (date && hour) {
            return dateFirst ? `${datePartFormatted}, ${timePartFormatted}` : `${timePartFormatted}, ${datePartFormatted}`;
        } else if (date) {
            return datePartFormatted;
        } else if (hour) {
            return timePartFormatted;
        } else {
            return value;
        }
    }
</script>

{displayValue}
