// @ts-nocheck
/** @type {import('../$types').PageLoad} */
export async function load({ params }) {
    return { transactionId: params.transactionId };
}