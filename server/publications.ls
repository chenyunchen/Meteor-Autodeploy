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
  'createVM': (data)->
    user =  Meteor.user()
    HTTP.call('POST','https://api.digitalocean.com/v2/droplets',
      {
        headers:
          'Authorization': 'Bearer ' + user.services.digitalocean.accessToken
          'Content-Type': 'application/json'
        data:
          name: data.vmName
          region: data.vmRegion
          size: data.vmSize
          image: data.vmImage
      }
      (error,result)->
        if !error
          console.log result
    )
})

Meteor.methods({
  'deleteVM': (id)->
    user =  Meteor.user()
    HTTP.call('DELETE','https://api.digitalocean.com/v2/droplets/'+id,
      headers:
        'Authorization': 'Bearer ' +  user.services.digitalocean.accessToken
        'Content-Type': 'application/x-www-form-urlencoded'
      (error,result)->
        if !error
          console.log result
    )
})

Meteor.methods({
  'userInfo': ->
    user = Meteor.user()
    return user
})

Meteor.methods({
  'imageInfo': ->
    user = Meteor.user()
    data = Meteor.sync (done)->
      HTTP.call('GET','https://api.digitalocean.com/v2/images',
        headers:
          'Authorization': 'Bearer ' +  user.services.digitalocean.accessToken
          'Content-Type': 'application/x-www-form-urlencoded'
        (err,res)->
          if not err
            done(null,res)
          else
            throw new Meteor.Error(500, err)
      )
    return data.result
})
