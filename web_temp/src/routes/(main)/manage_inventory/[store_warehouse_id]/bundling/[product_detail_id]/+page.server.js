// @ts-nocheck
/** @type {import('../../$types').PageLoad} */
export async function load({ params }) {
    return {  store_warehouse_id: params.store_warehouse_id, product_detail_id: params.product_detail_id};
}