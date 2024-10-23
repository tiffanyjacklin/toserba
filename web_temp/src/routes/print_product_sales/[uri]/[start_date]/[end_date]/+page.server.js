// @ts-nocheck
/** @type {import('../../$types').PageServerLoad} */
export async function load({ params, fetch }) {
	const uri = params.uri;
	const start_date = params.start_date;
    const end_date = params.end_date;

    // Fetch all data concurrently
	const [allStoreProfitData, allPromoCostData, all_store_profit] = await Promise.all([
		fetch(`http://${uri}:8888/profit/sum/all/store/${start_date}/${end_date}/0/0`).then((res) => res.json()),
		fetch(`http://${uri}:8888/promos/cost/all/${start_date}/${end_date}`).then((res) => res.json()),
		fetch(`http://${uri}:8888/profit/sum/all/store/${start_date}/${end_date}//0/0`).then((res) => res.json()),
	]);

    const totalPendapatan = calculateTotalPendapatan(allStoreProfitData.data);
    const totalBeban = allPromoCostData.data.promo_discount;
    const labaKotor = totalPendapatan - totalBeban;
    const allStoreProfit = all_store_profit.data;

	console.log(totalPendapatan);
	console.log(totalBeban);
	console.log(labaKotor);
	return {
		all_store_profit: allStoreProfit,
		startDate: start_date,
		endDate: end_date,
		total_pendapatan: totalPendapatan,
		total_beban: totalBeban,
		laba_kotor: labaKotor,
	};
}


function calculateTotalPendapatan(profitsArray) {
	let totalPendapatan = 0;

	profitsArray.forEach(item => {
	   totalPendapatan += item.profit;
	});

	return totalPendapatan;
 }