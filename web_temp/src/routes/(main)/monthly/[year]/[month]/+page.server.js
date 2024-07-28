// @ts-nocheck
/** @type {import('./$types').PageLoad} */
export async function load({ params }) {
	return { year: parseInt(params.year), month: parseInt(params.month) };
}
