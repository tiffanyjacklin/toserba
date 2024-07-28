// @ts-nocheck
import { browser } from '$app/environment';
import { thisMonth } from '$lib/this_month';
import { goto } from '$app/navigation';
import { writable } from 'svelte/store';

let today = new Date();
export let currentDate = new Date(today);
export let monthYear = ''; 
export const daysInMonth = writable([]);

export const tasksStore = writable({}); 

export function loadTasks(year, month, day) {
    const dateKey = `tasks_${year}_${month}_${day}`;
    const existingTasks = JSON.parse(localStorage.getItem(dateKey)) || [];
    tasksStore.update(tasks => {
        return { ...tasks, [dateKey]: existingTasks };
    });
}

export function saveTasks(year, month, day, taskList) {
    const dateKey = `tasks_${year}_${month}_${day}`;
    localStorage.setItem(dateKey, JSON.stringify(taskList));
    tasksStore.update(tasks => {
        return { ...tasks, [dateKey]: taskList };
    });
}

export function updateDaysInMonth() {
    if (browser){
        const selectedMonth = currentDate.getMonth() + 1;
        const selectedYear = currentDate.getFullYear();
        const numDays = new Date(selectedYear, selectedMonth, 0).getDate(); 
        const startDay = new Date(selectedYear, selectedMonth - 1, 1).getDay(); 
        const days = Array.from({ length: startDay }, (_, i) => null)
            .concat(Array.from({ length: numDays }, (_, i) => i + 1));
        daysInMonth.set(days); // Update the store
        console.log(days);
        for (let day = 1; day <= numDays; day++) {
            loadTasks(selectedYear, selectedMonth + 1, day);
        }
    }
}

export const updateMonthYear = () => {
    const options = { year: 'numeric', month: 'long' };
    if (browser){
        monthYear = currentDate.toLocaleDateString('en-US', options);
        localStorage.setItem('thisMonth', monthYear);
        thisMonth.set(monthYear); 
        updateDaysInMonth();
        console.log(localStorage.getItem('thisMonth'));
    }
};

export const gotoToday = () => {
    const today = new Date(); 
    currentDate = new Date(today); 

    updateMonthYear();
    
    goto(`/monthly/${today.getFullYear()}/${today.getMonth() + 1}`);
};

export const gotoPreviousMonth = () => {
    currentDate.setMonth(currentDate.getMonth() - 1);
    updateMonthYear();
    goto(`/monthly/${currentDate.getFullYear()}/${currentDate.getMonth() + 1}`);
};

export const gotoNextMonth = () => {
    currentDate.setMonth(currentDate.getMonth() + 1);
    updateMonthYear();
    goto(`/monthly/${currentDate.getFullYear()}/${currentDate.getMonth() + 1}`);
};


updateMonthYear();
