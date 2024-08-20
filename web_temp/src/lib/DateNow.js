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
export function isInTimeRange(closingTime, rangeMinutes = 30) {
    const now = new Date();
    const closingDate = new Date(closingTime);
    const maxDate = new Date(closingDate.getTime() + rangeMinutes * 60000); // Add range in milliseconds

    return now >= closingDate && now <= maxDate;
}