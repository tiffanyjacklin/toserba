<script lang="ts">
    import * as d3 from 'd3';
  
    export let data = [100000, 150000, 120000, 130000, 1800000, 1100000]; 
    export let dates = ["21 Aug 2024", "22 Aug 2024", "24 Aug 2024", "24 Aug 2024", "27 Aug 2024", "2 Sep 2024"]; 
    console.log("tessssssssssss",data);
  
    export let width = 500; 
    export let height = 300;
    export let marginTop = 20;
    export let marginRight = 40;
    export let marginBottom = 40;
    export let marginLeft = 60;  
    export let axisLineColor = "lightgray";
    export let labelColor = "black";
    export let lineColor = "#f2b082";
    let maxNumber = data.length > 0 ? Math.max(...data) : 0;
    let roundedMax = Math.ceil(maxNumber);

    $: x = d3.scalePoint().domain(dates).range([marginLeft, width - marginRight]).padding(0.5); 
    $: y = d3.scaleLinear([0, roundedMax], [height - marginBottom, marginTop]);
  
    $: line = d3.line<number>()
      .x((d, i) => x(dates[i]))
      .y(d => y(d));
  
    let gx: any;
    let gyGrid: any;
    let gyLabel: any; 
  
    $: d3.select(gx)
        .call(d3.axisBottom(x).tickSize(-height + marginTop + marginBottom).tickSizeOuter(0))
        .call(g => g.selectAll(".domain").remove())
        .call(g => g.selectAll(".tick line").attr("stroke", axisLineColor)) 
        .call(g => g.selectAll(".tick text")
          .attr("fill", labelColor)
          .attr("dy", "1.5em")); 
  
    $: d3.select(gyGrid)
        .call(d3.axisRight(y).tickSize(-width + marginLeft + marginRight).tickSizeOuter(0)) 
        .call(g => g.select(".domain").remove()) 
        .call(g => g.selectAll(".tick line").attr("stroke", axisLineColor)) 
        .call(g => g.selectAll(".tick text").remove()); 
  
    $: d3.select(gyLabel)
        .call(d3.axisLeft(y).ticks(5).tickSize(0).tickSizeOuter(0)) 
        .call(g => g.select(".domain").remove()) 
        .call(g => g.selectAll(".tick text").attr("fill", labelColor));
</script>

<svg width={width} height={height}>
    <g bind:this={gx} transform="translate(0,{height - marginBottom})" />
    <g bind:this={gyGrid} transform="translate({width - marginRight},0)" />
    <g bind:this={gyLabel} transform="translate({marginLeft},0)" />
    
    <path stroke-width="1.5" d={line(data)} stroke={lineColor} fill="none" />
    
    <g stroke-width="1.5">
      {#each data as d, i}
      <circle cx={x(dates[i])} cy={y(d)} r="6" fill={lineColor} />
      {/each}
    </g>
</svg>
  