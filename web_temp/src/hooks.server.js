// @ts-nocheck
import { redirect } from '@sveltejs/kit';

export const handle = async ({ event, resolve }) => {
	// Stage 1
	event.locals.auth = event.cookies.get('auth') ? JSON.parse(event.cookies.get('auth')) : false;

	// Stage 2
	const currentPath = event.url.pathname;

	// Only redirect if the user is not authenticated and not already on the login page
	if (!event.locals.auth && currentPath !== '/login') {
		return redirect(302, '/login');
	}

	const response = await resolve(event);
	// Stage 3
	return response;
};
