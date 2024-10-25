export function getFormattedDate() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');

    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}
export function getFormattedDateForPrint() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  const seconds = String(now.getSeconds()).padStart(2, '0');

  return `${year}-${month}-${day} ${hours}.${minutes}.${seconds}`;
}

export function getFormattedDateNow() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}

export function getThirtyDaysBefore(dateString, sum) {
  const today = new Date(dateString);
  today.setDate(today.getDate() - sum);
  const year = today.getFullYear();
  const month = String(today.getMonth() + 1).padStart(2, '0');
  const day = String(today.getDate()).padStart(2, '0');

  return `${year}-${month}-${day}`;
}

export function getDateCount(start_date, end_date) {
  const startDate = new Date(start_date);
  const endDate = new Date(end_date);

  const timeDifference = endDate - startDate;
  const dayDifference = timeDifference / (1000 * 60 * 60 * 24);

  return Math.round(dayDifference);
}

export function isInTimeRange(closingTime, rangeMinutes = 30) {
    const now = new Date();
    const closingDate = new Date(closingTime);
    const maxDate = new Date(closingDate.getTime() + rangeMinutes * 60000); // Add range in milliseconds

    return now >= closingDate && now <= maxDate;
}

export function getFormattedDateSpecial({
    date = true,
    hour = true,
    second = true,
    ampm = true,
    monthNumber = true,
    dash = true,
    dateFirst = true
  } = {}) {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    let hours = now.getHours();
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');
  
    let ampmText = '';
    if (ampm) {
      ampmText = hours >= 12 ? 'PM' : 'AM';
      hours = hours % 12 || 12; // Convert to 12-hour format
    }
    const hoursStr = String(hours).padStart(2, '0');
    const minutesStr = String(hours).padStart(2, '0');
    const secondsStr = String(hours).padStart(2, '0');
  
    // Determine the separator based on the `dash` and `monthNumber` settings
    const separator = monthNumber ? (dash ? '-' : '/') : ' ';
  
    // Construct the formatted date part
    const datePartFormatted = monthNumber 
      ? `${day}${separator}${month}${separator}${year}` 
      : `${day} ${now.toLocaleString('default', { month: 'long' })} ${year}`;
  
    // Construct the formatted time part
    let timePartFormatted = `${hoursStr}:${minutesStr}`;
    if (second) {
      timePartFormatted += `:${secondsStr}`;
    }
    timePartFormatted += ampm ? ` ${ampmText}` : '';
  
    // Combine the date and time parts based on settings
    if (date && hour) {
      return dateFirst 
        ? `${datePartFormatted}, ${timePartFormatted}` 
        : `${timePartFormatted}, ${datePartFormatted}`;
    } else if (date) {
      return datePartFormatted;
    } else if (hour) {
      return timePartFormatted;
    } else {
      // Default to full ISO format if no specific format is chosen
      return `${year}-${month}-${day} ${hoursStr}:${minutesStr}:${secondsStr}`;
    }
  }


  export function getFormattedDateSpecialWithValue({
    value, date = true,
    hour = true,
    second = true,
    ampm = true,
    monthNumber = true,
    dash = true,
    dateFirst = true
  } = {}) {
    const now = new Date(value);
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    let hours = now.getHours();
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');
  
    let ampmText = '';
    if (ampm) {
      ampmText = hours >= 12 ? 'PM' : 'AM';
      hours = hours % 12 || 12; // Convert to 12-hour format
    }
    const hoursStr = String(hours).padStart(2, '0');
    const minutesStr = String(hours).padStart(2, '0');
    const secondsStr = String(hours).padStart(2, '0');
  
    // Determine the separator based on the `dash` and `monthNumber` settings
    const separator = monthNumber ? (dash ? '-' : '/') : ' ';
  
    // Construct the formatted date part
    const datePartFormatted = monthNumber 
      ? `${day}${separator}${month}${separator}${year}` 
      : `${day} ${now.toLocaleString('default', { month: 'long' })} ${year}`;
  
    // Construct the formatted time part
    let timePartFormatted = `${hoursStr}:${minutesStr}`;
    if (second) {
      timePartFormatted += `:${secondsStr}`;
    }
    timePartFormatted += ampm ? ` ${ampmText}` : '';
  
    // Combine the date and time parts based on settings
    if (date && hour) {
      return dateFirst 
        ? `${datePartFormatted}, ${timePartFormatted}` 
        : `${timePartFormatted}, ${datePartFormatted}`;
    } else if (date) {
      return datePartFormatted;
    } else if (hour) {
      return timePartFormatted;
    } else {
      // Default to full ISO format if no specific format is chosen
      return `${year}-${month}-${day} ${hoursStr}:${minutesStr}:${secondsStr}`;
    }
  }

  export function formatDate(date) {
      const d = new Date(date);
      const month = String(d.getMonth() + 1).padStart(2, '0');
      const day = String(d.getDate()).padStart(2, '0');
      const year = d.getFullYear();
      return `${year}-${month}-${day}`;
  }