showData = []
#new ReactiveVar
#new ReactiveDict
#new Mongo.Collection null
#x = Dep.dependency()
#x.changed()
#  ...
drawhexagon = []
vm = []
Template.index.rendered = ->
  $('.button-collapse').sideNav()
  $('.parallax').parallax()
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
  MapColumns = 16
  MapRows = 7
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


Template.index.events({
  'click a#createVM': (e,t)->
    data = {
      name: 'test-VM'
      region: 'sgp1'
      size: '512mb'
      image: 10581649
      ssh_keys: [722957]
      backups: false
      ipv6: true
      user_data: null
      private_networking: null
    }
    Meteor.call 'createVM', data, (err,res)->
      if not err
        console.log res
        data = {
          id: res.data.droplet.id
          name: res.data.droplet.name
          memory: res.data.droplet.memory
          disk: res.data.droplet.disk
        }
        vm.push data
        message = '<b>Success!</b><br/>'+res.data.droplet.name+'<br/>'+res.data.droplet.memory+'MB<br/>'+res.data.droplet.disk+'<br/>Machine Create Success! :)'
        toastr.success(message)
      else
        console.log err

  'click a#powerOnVm': (e,t)->
    data = {
      id: 4285228
      action:
        type: 'power_on'
    }
    Meteor.call 'powerOnVM', data, (err,res)->
      if not err
        console.log res
      else
        console.log err

  'click a#removeVM': (e,t)->
    Meteor.call 'removeVM', vm[0].id, (err,res)->
      if not err
        message = '<b>Success!</b><br/>Delete VM Success! :)'
        toastr.success(message)
      else
        console.log err

  'click a#userInfo': (e,t)->
    Meteor.call 'userInfo', (err,res)->
      if not err
        message = '<b>Hi! :)</b><br/>'+res.services.digitalocean.username+'<br/>'+res.services.digitalocean.email
        toastr.success(message)
      else
        console.log err

  'click a#userVMInfo': (e,t)->
    Meteor.call 'userVMInfo', (err,res)->
      if not err
        console.log res
      else
        console.log err

  'click a#distributionInfo': (e,t)->
    Meteor.call 'distributionInfo', (err,res)->
      message = 'OK'
      toastr.success(message)
      showData.length = 0
      if not err
        for i in res
          distributionInfo = {
            distribution: i.distribution
            slug: i.slug
            create_at: i.created_at
          }
          showData.push distributionInfo
      else
        console.log err

  'click a#applicationInfo': (e,t)->
    Meteor.call 'applicationInfo', (err,res)->
      message = 'OK'
      toastr.success(message)
      showData.length = 0
      if not err
        for i in res
          applicationInfo = {
            distribution: i.distribution
            slug: i.slug
            create_at: i.created_at
          }
          showData.push applicationInfo
      else
        console.log err

  'click a#showSSHKey': (e,t)->
    Meteor.call 'showSSHKey', (err,res)->
      if not err
        message = res['ssh_keys'][0]
        console.log message
      else
        console.log err

  'click a#addSSHKey': (e,t)->
    data = {
        name: 'yun'
        public_key: 'local'
    }
    Meteor.call 'addSSHKey', data, (err,res)->
      if not err
        console.log res
      else
        console.log err

  'click a#execSSH': (e,t)->
    data = {
        script: 'sudo docker run --volume=/:/rootfs:ro --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --publish=8080:8080 --detach=true --name=cadvisor google/cadvisor:latest'
        key: '/Users/yunchen/.ssh/id_rsa'
        host: '128.199.203.246'
        port: 22
        user: 'root'
    }
    Meteor.call 'execSSH', data, (err,res)->
      if not err
        console.log res
      else
        console.log err

  'click a#test': (e,t)->
    Meteor.call 'test1', (err,res)->
      if not err
        console.log res
      else
        console.log err

  'click a#getCPU': (e,t)->
    data = {
      host: '128.199.226.157'
      port: 8080
    }
    setInterval(->
      Meteor.call 'getVMCPU', data, (err,res)->
        if not err
          console.log res
        else
          console.log err
    , 2000)
})
