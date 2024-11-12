// @ts-nocheck
/** @type {import('../../$types').PageLoad} */
export async function load({ params }) {
    return { store_warehouse_id: params.store_warehouse_id, delivery_order_id: params.delivery_order_id};
}