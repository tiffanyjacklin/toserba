// @ts-nocheck
/** @type {import('../../$types').PageServerLoad} */
export async function load({ params, fetch }) {
	const uri = params.uri;
	const transactionId = params.transactionId;

	const transaction = async () =>
		await fetch(`http://${uri}:8888/transaction/${transactionId}`).then((res) => res.json());
    const store_warehouse = async () =>
		await fetch(`http://${uri}:8888/store_warehouses/${(await transaction()).data.UserData.user_id}/1//0/0`).then((res) => res.json());
    const transaction_detail = async () =>
		await fetch(`http://${uri}:8888/transaction/detail/${transactionId}/0/0`).then((res) => res.json());

	// console.log(await transaction_detail());
	return {
		transaction: (await transaction()).data.Transaction,
		payment_method: (await transaction()).data.PaymentMethod,
		cashier_id: (await transaction()).data.UserData.user_id,
		store_warehouse: (await store_warehouse()).data[0],
		transaction_detail: (await transaction_detail()).data,
		user: (await transaction()).data.UserData,
	};
}