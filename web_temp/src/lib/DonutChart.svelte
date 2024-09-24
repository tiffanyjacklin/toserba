<script>
    import * as d3 from "d3";
  
    let width = 450;
    let height = 450;
    let margin = 40;
  
    let radius = Math.min(width, height) / 2 - margin;
    export let samping_bawah = "bawah";
    export let data_temp = {
        "Toko Tip Kaya": -100800,
        "Gudang XYZ": 119200
    };
  
    const data = data_temp;
    
    // Convert data to an array and use absolute values for rendering
    const data_ready = Object.entries(data).map(([key, value]) => [key, Math.abs(value)]);
    
    const totalSum = Object.values(data).reduce((a, b) => a + b, 0);
    $: currentSum = data_ready.reduce((a, b) => a + b[1], 0);
  
    const color = d3
        .scaleOrdinal()
        .domain(data_ready.map(d => d[0]))
        .range(d3.schemeSet2);
  
    const pie = d3
        .pie()
        .sort(null)
        .value(d => d[1]); // Use the absolute values for the pie layout
  
    const pieData = pie(data_ready);
  
    const arc = d3
        .arc()
        .innerRadius(radius * 0.5) 
        .outerRadius(radius * 0.8);
  
    const outerArc = d3
        .arc()
        .innerRadius(radius * 0.9)
        .outerRadius(radius * 0.9);
    
    let clickedSlice = null;
    let clickedValue = null;
    function handleSliceClick(slice) {
      currentSum = data_ready.reduce((a, b) => a + b[1], 0); // Use the absolute total for percentages
      clickedSlice = slice;
  
      // Optionally, set a temporary value to indicate the clicked slice if needed
      clickedValue = data[slice.data[0]]; // Use the absolute value for display purposes
  
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
                    fill={color(slice.data[0])}
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
                {(slice.data[1] / currentSum * 100).toFixed(1)}%
            </text>
        {/each}
    </svg>
    {#if samping_bawah === 'samping'}
        <div class="legend">
        {#each Object.entries(data) as [key, value]}
            <div class="">
            <span class="inline-block items-center w-3 h-3 mr-1.5" style:background-color={color(value)}></span>
            {key}
            </div>
        {/each}
        </div>
    {/if}
  </div>
  {#if samping_bawah === 'bawah'}
  <div class="flex justify-center">
    <div class="flex-col mt-5">
      {#each Object.entries(data) as [key, value]}
        <div class="">
          <span class="inline-block items-center w-3 h-3 mr-1.5" style:background-color={color(value)}></span>
          {key}
        </div>
      {/each}
    </div>
  </div>
  {/if}