// @ts-nocheck
/** @type {import('../$types').PageLoad} */
export async function load({ params }) {
    return {  store_warehouse_id: params.store_warehouse_id, transactionId: params.transactionId };
}