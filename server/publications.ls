fs = Meteor.npmRequire('fs')
Meteor.methods({
  'execSSH': (data)->
    response = Meteor.sync (done)->
        connection = Meteor.npmRequire('ssh2');
        conn = new connection();
        conn.on('ready', ->
          conn.exec(data.script, (err, stream)->
            if err
              defer.reject()
            stream.on('exit', (code, signal)->
              done(null,true)
            ).on('close', ->
              conn.end()
            )
          )
        ).connect({
          host: data.host,
          port: data.port
          username: data.user
          privateKey: fs.readFileSync(data.key, 'utf-8')
        });
    return response.result
})

Meteor.methods({
  'createRoute': ->
    hipache = "docker run --name hipache-npm -p ::6379 -p :80:80 -d ongoworks/hipache-npm"
})

Meteor.methods({
  'createWebConfiguration': ->
    port = 3000
    advisor = "docker run --volume=/:/rootfs:ro --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --publish=8080:8080 --detach=true --name=cadvisor google/cadvisor:latest"
    website = 'docker build -t website https://github.com/Casear/docker-node-express.git '
    runWebsite = 'docker run -d -p '+port+':'+port+' -t website'
})

getVMCPU = (data)->
  host = data.host
  if data.hasOwnProperty('port')
      port = data.port
  else
      port = 8080
  defer = Q.defer()
  HTTP.call('GET','http://'+host+':'+port+'/api/v1.2/docker',
    (error,result)->
      if !error
        data = JSON.parse result.content
        all = []
        for container of data
          containerInfo = data[container]
          id = containerInfo.aliases[1]
          name = containerInfo.aliases[0]
          cur = containerInfo.stats[containerInfo.stats.length-1]
          prev = containerInfo.stats[containerInfo.stats.length-2]
          rawUsage = cur.cpu.usage.total - prev.cpu.usage.total
          curdate = new Date(cur.timestamp)
          prevdate = new Date(prev.timestamp)
          interval = (curdate.getTime() - prevdate.getTime())*1000000
          cpuUsage = Math.round((rawUsage/interval)*100)
          memoryUsage = Math.round((cur.memory.usage/1042317312)*100)
          networkReceive = Math.round((cur.network['rx_bytes'] - prev.network['rx_bytes'])/(interval/1000000000))
          networkTransfer = Math.round((cur.network['tx_bytes'] - prev.network['tx_bytes'])/(interval/1000000000))
          if cpuUsage > 100
            cpuUsage = 100
          usage = {
            id: id
            name: name
            cpuUsage: cpuUsage
            memoryUsage: memoryUsage
            networkReceive: networkReceive
            networkTransfer: networkTransfer
          }
          all.push(usage)
        defer.resolve(all)
  )
  return defer.promise

getRegStatus = (data)->
  host = data.host
  if data.hasOwnProperty('port')
      port = data.port
  else
      port = 8080
  defer = Q.defer()
  HTTP.call('GET','http://'+host+':'+port+'/api/v1.2/docker',
    (error,result)->
      if !error
        data = JSON.parse result.content
        resData = {
          capacity: 0
          usage: 0
        }
        for container of data
          containerInfo = data[container]
          name = containerInfo.aliases[0]
          if name is 'registry_instance'
            disk = containerInfo.stats[59].filesystem[0]
            resData.capacity = Math.floor(disk.capacity/1073741824)
            resData.usage = Math.floor(disk.usage/1073741824)
        defer.resolve(resData)
  )
  return defer.promise

Meteor.methods({
  'getStatus': (data)->
    response = Meteor.sync (done)->
      getVMCPU(data).then (result)->
        done(null,result)
    return response.result
})

Meteor.methods({
  'getRegStatus': (data)->
    response = Meteor.sync (done)->
      getRegStatus(data).then (result)->
        done(null,result)
    return response.result
})
