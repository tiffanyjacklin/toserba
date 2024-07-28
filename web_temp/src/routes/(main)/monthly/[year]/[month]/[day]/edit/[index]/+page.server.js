// @ts-nocheck
/** @type {import('./$types').PageLoad} */
export async function load({ params }) {
	return { year: params.year, month: params.month, day: params.day, index: params.index };
}
