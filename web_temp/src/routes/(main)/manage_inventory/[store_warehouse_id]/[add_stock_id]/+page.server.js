// @ts-nocheck
/** @type {import('../$types').PageLoad} */
export async function load({ params }) {
    return {  store_warehouse_id: params.store_warehouse_id, add_stock_id: params.add_stock_id };
}