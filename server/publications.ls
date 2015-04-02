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
