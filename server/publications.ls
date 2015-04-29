fs = Meteor.npmRequire('fs')
Meteor.methods({
  execSSH: (data)->
    response = Meteor.sync (done)->
        connection = Meteor.npmRequire('ssh2');
        conn = new connection();
        conn.on('ready', ->
          conn.exec(data.script, (err, stream)->
            if err
              defer.reject()
            stream.on('exit', (code, signal)->
              done(null,'ok')
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

Meteor.methods({
  'getVMCPU': (data)->
    host = data.host
    port = data.port
    response = Meteor.sync (done)->
      HTTP.call('GET','http://'+host+':'+port+'/api/v1.2/docker',
        (error,result)->
          if !error
            data = JSON.parse result.content
            all = []
            for container of data
              containerInfo = data[container]
              name = containerInfo.aliases[0]
              if name isnt 'cadvisor'
                cur = containerInfo.stats[containerInfo.stats.length-1]
                prev = containerInfo.stats[containerInfo.stats.length-2]
                rawUsage = cur.cpu.usage.total - prev.cpu.usage.total
                curdate = new Date(cur.timestamp)
                prevdate = new Date(prev.timestamp)
                interval = (curdate.getTime() - prevdate.getTime())*1000000
                cpuUsage = Math.round((rawUsage/interval)*100)
                #console.log containerInfo.spec.memory.limit
                memoryUsage = Math.round((cur.memory.usage/1042317312)*100)
                networkReceive = Math.round((cur.network['rx_bytes'] - prev.network['rx_bytes'])/(interval/1000000000))
                networkTransfer = Math.round((cur.network['tx_bytes'] - prev.network['tx_bytes'])/(interval/1000000000))
                if cpuUsage > 100
                  cpuUsage = 100
                usage = {
                  name: name
                  cpuUsage: cpuUsage
                  memoryUsage: memoryUsage
                  networkReceive: networkReceive
                  networkTransfer: networkTransfer
                }
                all.push(usage)
            done(null,all)
      )
    return response.result
})
