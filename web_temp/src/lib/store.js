import { browser } from '$app/environment';

export function loadFromLocalStorage(key, defaultValue) {
    if (browser) {
        const value = localStorage.getItem(key);
        return value ? JSON.parse(value) : defaultValue;
    }
    return defaultValue;
}

export function saveToLocalStorage(key, value) {
    if (browser) {
        localStorage.setItem(key, JSON.stringify(value));
    }
}
