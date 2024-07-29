// @ts-nocheck

import { onMount } from 'svelte';
import { fail, redirect } from '@sveltejs/kit';
import { goto } from '$app/navigation';
import { browser } from '$app/environment';

/** @type {import('./$types').Actions} */
export const actions = {
	login: async ({ request, cookies }) => {
		const formData = await request.formData();
		const entries = Object.fromEntries(formData);
		
		const response = await fetch(`http://localhost:2681/user/login?username=${entries.username}&password=${entries.password}`, {
			method: 'PUT',
			headers: {
				'Content-Type': 'application/json'
			}
		});		if (!response.ok) {
            return fail(response.status, { message: 'Login failed.' });
        }

        const data = await response.json();
        
        if (data.status !== 200) {
            return fail(400, { message: 'Invalid username or password.' });
        }

        const authValue = data.data;
		console.log(authValue);

		cookies.set('auth', JSON.stringify(authValue), {
			maxAge: 60 * 60 * 24,
			sameSite: 'strict',
			path: '/',
			secure: false,
			httpOnly: false
		});
		if (browser) {localStorage.setItem('userId', authValue.user_id);
			console.log(localStorage.getItem('userId'));
		}
		return redirect(302, `/pilih_role/${authValue.user_id}`);
	}
};
