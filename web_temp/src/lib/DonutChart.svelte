<script>
  import * as d3 from "d3";

  let width = 450;
  let height = 450;
  let margin = 40;

  let radius = Math.min(width, height) / 2 - margin;
  export let samping_bawah = "bawah";

  // Your data structure is an array of objects
  export let data_temp = [
      { store_warehouse_name: "Toko Tip Kaya", profit: -100800 },
      { store_warehouse_name: "Toko BCD", profit: -100400 }
  ];

  console.log(data_temp);

  $: totalSum = data_temp.reduce((acc, item) => acc + item.profit, 0);
  $: currentSum = data_temp.reduce((acc, item) => acc + Math.abs(item.profit), 0);

  $: color = d3
      .scaleOrdinal()
      .domain(data_temp.map(d => d.store_warehouse_name))
      .range(d3.schemeSet2);

  $: pie = d3
      .pie()
      .sort(null)
      .value(d => Math.abs(d.profit)); // Use absolute value for pie layout

  $: pieData = pie(data_temp);

  $: arc = d3
      .arc()
      .innerRadius(radius * 0.5)
      .outerRadius(radius * 0.8);

  $: outerArc = d3
      .arc()
      .innerRadius(radius * 0.9)
      .outerRadius(radius * 0.9);

  $: clickedSlice = null;
  $: clickedValue = null;
  
  function handleSliceClick(slice) {
      currentSum = data_temp.reduce((acc, item) => acc + Math.abs(item.profit), 0);
      clickedSlice = slice;

      // Set clicked value to the original profit
      clickedValue = slice.data.profit;

      setTimeout(() => {
          clickedSlice = null;
          clickedValue = null;
      }, 2000);
  }
</script>

<div class="flex items-center gap-x-4 justify-center">
  <svg
      {width}
      {height}
      viewBox="{-width / 2}, {-height / 2}, {width}, {height}"
      style:max-width="100%"
      style:height="auto"
  >
      <g class="chart-inner">
          {#each pieData as slice}
              <path
                  d={arc(slice)}
                  fill={color(slice.data.store_warehouse_name)}
                  stroke="white"
                  class={clickedSlice === slice ? "drop-shadow-[0_0_5px_rgba(0,0,0,0.5)]" : ""}
                  on:click={() => handleSliceClick(slice)}
              />
          {/each}
      </g>
      <text
          x="0"
          y="0"
          text-anchor="middle"
          alignment-baseline="middle"
          font-size="24"
          fill="black"
      >
      {#if clickedValue !== null}
          {clickedValue}
      {:else}
          {totalSum}
      {/if}
      </text>

      {#each pieData as slice}
          <text
              font-weight="bold"
              transform={`translate(${outerArc.centroid(slice)[0] * 1.1}, ${outerArc.centroid(slice)[1] * 1.1})`}
              text-anchor="middle"
              fill="black"
              font-size="16"
          >
              {(Math.abs(slice.data.profit) / currentSum * 100).toFixed(1)}%
          </text>
      {/each}
  </svg>
  
  {#if samping_bawah === 'samping'}
      <div class="legend">
      {#each data_temp as { store_warehouse_name, profit }}
          <div class="">
              <span class="inline-block items-center w-3 h-3 mr-1.5" style:background-color={color(store_warehouse_name)}></span>
              {store_warehouse_name}
          </div>
      {/each}
      </div>
  {/if}
</div>

{#if samping_bawah === 'bawah'}
<div class="flex justify-center">
  <div class="flex-col mt-5">
      {#each data_temp as { store_warehouse_name, profit }}
          <div class="">
              <span class="inline-block items-center w-3 h-3 mr-1.5" style:background-color={color(store_warehouse_name)}></span>
              {store_warehouse_name}
          </div>
      {/each}
  </div>
</div>
{/if}
