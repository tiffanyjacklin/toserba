// @ts-nocheck
/** @type {import('../../$types').PageServerLoad} */
export async function load({ params, fetch }) {
	const uri = params.uri;
	const delivery_order_id = params.delivery_order_id;
    const sw_id_from = params.sw_id_from;
    const sw_id_to = params.sw_id_to;

    // Fetch all data concurrently
	const [sw_from, sw_to, do_, do_detail] = await Promise.all([
		fetch(`http://${uri}:8888/store_warehouses/${sw_id_from}`).then((res) => res.json()),
		fetch(`http://${uri}:8888/store_warehouses/${sw_id_to}`).then((res) => res.json()),
		fetch(`http://${uri}:8888/orders/delivery/${delivery_order_id}`).then((res) => res.json()),
		fetch(`http://${uri}:8888/orders/delivery/detail/${delivery_order_id}`).then((res) => res.json()),
	]);

    const from_data = sw_from.data;
    const to_data = sw_to.data;
    const do_data = do_.data;
    const do_detail_data = do_detail.data;

	return {
		from: from_data,
		to: to_data,
		delivery_order: do_data,
		delivery_order_details: do_detail_data
	};
}