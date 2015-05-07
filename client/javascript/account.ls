showData = []
#new ReactiveVar
#new ReactiveDict
#new Mongo.Collection null
#x = Dep.dependency()
#x.changed()
#  ...
drawhexagon = []
vm = []
Template.account.rendered = ->
  #The color of each hexagon
  #Function to call when you mouseover a node
  color = ['#0072E3','#00DB00','#D9B300','#CE0000']
  mover = (d,i)->
    update()
    toastr.clear()
    for number in drawhexagon
      if number is i
        index = drawhexagon.indexOf(i)
        data = showData[index]
        message = data.distribution + '<br/>' + data.slug + '<br/>' + data.create_at
        if index in [0,1,2]
          message = '<b>Warning!</b><br/>' + message + '<br/>CPU or Memory > 50% :o'
          toastr.warning(message)
          break
        else if index is 19
          message = '<b>Emergency!</b><br/>' + message + '<br/>CPU or Memory > 85% :('
          toastr.error(message)
          break
        else
          message = '<b>Stable!</b><br/>' + message + '<br/>Your server works fine :)'
          toastr.success(message)
          break

    el = d3.select this
    .transition()
    .duration 10
    .style 'fill-opacity', 0.3


  #Mouseout function
  mout = (d)->
    el = d3.select this
    .transition()
    .duration(1000)
    .style('fill-opacity', 1)

  #svg sizes and margins
  margin = {
    top: 30
    right: 0
    bottom: 20
    left: 0
  }

  width = window.innerWidth - margin.left - margin.right - 40
  height = window.innerHeight - margin.top - margin.bottom - 80

  #The number of columns and rows of the heatmap
  MapColumns = 11
  MapRows = 5
  for i from 1 to 20
    while true
      randomNum = Math.floor(Math.random()*MapColumns*MapRows)
      if drawhexagon.indexOf(randomNum) is -1
        drawhexagon.push randomNum
        break

  #The maximum radius the hexagons can have to still fit the screen
  hexRadius = d3.min [width/((MapColumns + 0.5) * Math.sqrt(3)), height/((MapRows + 1/3) * 1.5)]

  #Set the new height and width of the SVG based on the max possible
  width = MapColumns*hexRadius*Math.sqrt(3)
  heigth = MapRows*1.5*hexRadius+0.5*hexRadius

  #Set the hexagon radius
  hexbin = d3.hexbin().radius hexRadius

  #Calculate the center positions of each hexagon
  points = []
  for i from 0 til MapRows
    for j from 0 til MapColumns
      points.push [hexRadius * j * 1.75, hexRadius * i * 1.5]

  #Create SVG element
  svg = d3.select('#chart').append('svg')
  .attr 'width', width + margin.left + margin.right
  .attr 'height', height + margin.top + margin.bottom
  .append 'g'
  .attr 'transform', 'translate(' + margin.left + ',' + margin.top + ')'

  #Start drawing the hexagons
  svg.append 'g'
  .selectAll '.hexagon'
  .data hexbin points
  .enter().append('path')
  .attr 'class', 'hexagon'
  .attr 'd', (d)->
    'M' + d.x + ',' + d.y + hexbin.hexagon()
  .attr 'stroke', (d,i)->
    '#fff'
  .attr 'stroke-width', '1px'
  .attr 'id', (d,i)->
    i
  .style 'fill', color[0]
  .on 'mouseover', mover
  .on 'mouseout', mout

  update = ->
    for number in drawhexagon
     if drawhexagon.indexOf(number) in [0,1,2]
       drawColor = 2
       d3.select("[id='" + number + "']").style 'fill', color[drawColor]
     else if drawhexagon.indexOf(number) is 19
       drawColor = 3
       d3.select("[id='" + number + "']").style 'fill', color[drawColor]
     else
       drawColor = 1
       d3.select("[id='" + number + "']").style 'fill', color[drawColor]
