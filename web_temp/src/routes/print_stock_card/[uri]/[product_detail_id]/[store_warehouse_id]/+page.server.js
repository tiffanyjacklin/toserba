// @ts-nocheck
/** @type {import('../../$types').PageServerLoad} */
export async function load({ params, fetch }) {
	const uri = params.uri;
	const product_id = params.product_detail_id;
    const sw_id = params.store_warehouse_id;

    let stock_card;  // Declare stock_card outside the if-else block
	
    if (sw_id !== '-') {
		stock_card = await fetch(`http://${uri}:8888/products/stock/card/product/store_warehouse/${product_id}/${sw_id}/0/0`).then((res) => res.json());
	} else {
		stock_card = await fetch(`http://${uri}:8888/products/stock/card/product/${product_id}/0/0`).then((res) => res.json());
	}

    const stock_cardnya = stock_card.data;

	return {
		stock_card: stock_cardnya
	};
}
