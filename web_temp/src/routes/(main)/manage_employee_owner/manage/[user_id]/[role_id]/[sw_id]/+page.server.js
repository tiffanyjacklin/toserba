// @ts-nocheck
/** @type {import('../../../../../../$types').PageLoad} */
export async function load({ params }) {
    return { user_id: params.user_id, role_id: params.role_id, sw_id: params.sw_id };
}
