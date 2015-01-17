execSSH = (script,key,host,port,user)->
    defer = Q.defer()
    connection = Meteor.npmRequire('ssh2');
    conn = new connection();
    conn.on('ready', ->
      conn.exec(script, (err, stream)->
        if err
          defer.reject()
        stream.on('exit', (code, signal)->
          defer.resolve()
        ).on('close', ->
          conn.end()
        )
      )
    ).connect({
      host: host,
      port: port
      username: user
      privateKey: Meteor.npmRequire('fs').readFileSync(key)
    });
    defer.promise
Meteor.publish 'createRoute', ->
    hipache = "docker run --name hipache-npm -p ::6379 -p :80:80 -d ongoworks/hipache-npm"

Meteor.publish 'createWebConfiguration', ->
    port = 3000
    advisor = "docker run --volume=/:/rootfs:ro --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --publish=8080:8080 --detach=true --name=cadvisor google/cadvisor:latest"
    website = 'docker build -t website https://github.com/Casear/docker-node-express.git '
    runWebsite = 'docker run -d -p '+port+':'+port+' -t website'

Meteor.publish 'createVM',->
  HTTP.call('POST','https://api.digitalocean.com/v2/droplets',
    {
      headers:
        'Authorization': 'Bearer ' + ServerSession.get(result.data.uid)
        'Content-Type': 'application/json'
      data:
        name: 'test-droplets'
        region: 'sgp1'
        size: '512mb'
        image: 7354580
    }
    (error,result)->
      if !error
        console.log result
  )

Meteor.publish 'deleteVM',(id)->
  HTTP.call('DELETE','https://api.digitalocean.com/v2/droplets/3028017',
    headers:
      'Authorization': 'Bearer ' + ServerSession.get(result.data.uid)
      'Content-Type': 'application/x-www-form-urlencoded'
    (error,result)->
      if !error
        console.log result
  )
