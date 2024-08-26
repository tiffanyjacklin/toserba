// src/lib/uri.js
import { writable } from 'svelte/store';
import { loadFromLocalStorage, saveToLocalStorage } from '$lib/store.js';
import { browser } from '$app/environment';

// Define stores with default values from localStorage
// export const uri = writable(loadFromLocalStorage('uri', 'localhost'));
export const uri = writable(loadFromLocalStorage('uri', 'leap.crossnet.co.id'));
export const userId = writable(loadFromLocalStorage('userId', ''));
export const user = writable(loadFromLocalStorage('user', ''));
export const roleId = writable(loadFromLocalStorage('roleId', ''));
export const privileges = writable(loadFromLocalStorage('privileges', ''));
export const sessionId = writable(loadFromLocalStorage('sessionId', ''));
// export const transactionId = writable(loadFromLocalStorage('transactionId', ''));
export const totalAmount = writable(loadFromLocalStorage('totalAmount', ''));

// Subscribe to changes and save to localStorage only in the browser
if (browser) {
    uri.subscribe(value => saveToLocalStorage('uri', value));
    userId.subscribe(value => saveToLocalStorage('userId', value));
    user.subscribe(value => saveToLocalStorage('user', value));
    roleId.subscribe(value => saveToLocalStorage('roleId', value));
    sessionId.subscribe(value => saveToLocalStorage('sessionId', value));
    privileges.subscribe(value => saveToLocalStorage('privileges', value));
    // transactionId.subscribe(value => saveToLocalStorage('transactionId', value));
    totalAmount.subscribe(value => saveToLocalStorage('totalAmount', value));
}
