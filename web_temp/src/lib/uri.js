// src/lib/uri.js
import { writable } from 'svelte/store';
import { loadFromLocalStorage, saveToLocalStorage } from '$lib/store.js';
import { browser } from '$app/environment';

// Define stores with default values from localStorage
export const uri = writable(loadFromLocalStorage('uri', 'localhost'));
export const userId = writable(loadFromLocalStorage('userId', ''));
export const roleId = writable(loadFromLocalStorage('roleId', ''));
export const sessionId = writable(loadFromLocalStorage('sessionId', ''));
// export const transactionId = writable(loadFromLocalStorage('transactionId', ''));
export const totalAmount = writable(loadFromLocalStorage('totalAmount', ''));

// Subscribe to changes and save to localStorage only in the browser
if (browser) {
    uri.subscribe(value => saveToLocalStorage('uri', value));
    userId.subscribe(value => saveToLocalStorage('userId', value));
    roleId.subscribe(value => saveToLocalStorage('roleId', value));
    sessionId.subscribe(value => saveToLocalStorage('sessionId', value));
    // transactionId.subscribe(value => saveToLocalStorage('transactionId', value));
    totalAmount.subscribe(value => saveToLocalStorage('totalAmount', value));
}

// export const uri = writable('leap.crossnet.co.id');