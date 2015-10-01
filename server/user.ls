root = exports ? this
root.UserSecret = new Meteor.Collection('usersecret')
root.UserVM = new Meteor.Collection('uservm')
fs = Meteor.npmRequire('fs')
exec = Meteor.npmRequire('child_process').exec

execSSH = (data)->
  connection = Meteor.npmRequire('ssh2')
  conn = new connection()
  conn.on('ready', ->
    conn.exec(data.script, (err, stream)->
      if err
        defer.reject()
      stream.on('exit', (code, signal)->
        console.log 'Docker start make images'
      ).on('close', ->
        conn.end()
      )
    )
  ).connect({
    host: data.host,
    port: data.port
    username: data.user
    privateKey: fs.readFileSync(data.key, 'utf-8')
  })

Meteor.methods({
  'createVM': (data)->
    user = Meteor.user()
    response = Meteor.sync (done)->
      HTTP.call('POST','https://api.digitalocean.com/v2/droplets',
        headers:
          'Authorization': 'Bearer ' +  user.services.digitalocean.accessToken
          'Content-Type': 'application/json'
        data: data
        (err,res)->
          if not err
            data = {
              userId: user._id
              vmId: res.data.droplet.id
              vmName: res.data.droplet.name
              vmMemory: res.data.droplet.memory
              vmDisk: res.data.droplet.disk
              vmCPU: res.data.droplet.vcpus
              created: res.data.droplet.created_at
              status: res.data.droplet.status
              kernel: res.data.droplet.kernel
            }
            UserVM.insert data
            done(null,res)
          else
            throw new Meteor.Error(500, err)
      )
    return response.result
})

Meteor.methods({
  'removeVM': (id)->
    user = Meteor.user()
    response = Meteor.sync (done)->
      HTTP.call('DELETE','https://api.digitalocean.com/v2/droplets/'+id,
        headers:
          'Authorization': 'Bearer ' +  user.services.digitalocean.accessToken
          'Content-Type': 'application/x-www-form-urlencoded'
        (err,res)->
          if not err
            done(null,res)
      )
    return response.result
})

Meteor.methods({
 'userVMInfo':->
    user = Meteor.user()
    response = Meteor.sync (done)->
      HTTP.call('GET','https://api.digitalocean.com/v2/droplets',
        headers:
          'Authorization': 'Bearer ' +  user.services.digitalocean.accessToken
          'Content-Type': 'application/json'
        (err,res)->
          if not err
            data = EJSON.parse(res.content)
            vm = data.droplets
            done(null,vm)
          else
            throw new Meteor.Error(500, err)
      )
    return response.result
})


Meteor.methods({
  'powerOnVM': (data)->
    user = Meteor.user()
    response = Meteor.sync (done)->
      HTTP.call('POST','https://api.digitalocean.com/v2/droplets/'+data.id+'/actions',
        headers:
          'Authorization': 'Bearer ' + user.services.digitalocean.accessToken
          'Content-Type': 'application/json'
        data: data.action
        (err,res)->
          if not err
            console.log res
            done(null,res)
          else
            throw new Meteor.Error(500, err)
      )
    return response.result
})

Meteor.methods({
  'showSSHKey': ->
    user = Meteor.user()
    response = Meteor.sync (done)->
      HTTP.call('GET','https://api.digitalocean.com/v2/account/keys',
        headers:
          'Authorization': 'Bearer ' +  user.services.digitalocean.accessToken
          'Content-Type': 'application/json'
        (err,res)->
          if not err
            data = EJSON.parse(res.content)
            done(null,data)
          else
            throw new Meteor.Error(500, err)
      )
    return response.result
})

Meteor.methods({
  'addSSHKey': (data)->
    user = Meteor.user()
    response = Meteor.sync (done)->
      HTTP.call('POST','https://api.digitalocean.com/v2/account/keys',
        headers:
          'Authorization': 'Bearer ' +  user.services.digitalocean.accessToken
          'Content-Type': 'application/json'
        data: data
        (err,res)->
          if not err
            data = EJSON.parse(res.content)
            done(null,data)
          else
            throw new Meteor.Error(500, err)
      )
    return response.result
})

Meteor.methods({
  'dockerfileUpload': (data)->
    user = Meteor.user()
    dockerfile = data.dockerfile
    imageName = data.imageName
    fs.mkdir('/tmp/'+user._id,->
        fs.writeFile('/tmp/'+user._id+'/dockerfile', dockerfile,(err)->
          if not err
            cmd = 'scp -i /Users/yunchen/.ssh/id_rsa -pr /tmp/'+user._id+' azureuser@yunchen.cloudapp.net:/home/azureuser/docker'
            exec(cmd,(error, stdout, stderr)->
                console.log imageName
                data = {
                  key: '/Users/yunchen/.ssh/id_rsa'
                  host: '128.199.160.94'
                  port: 22
                  user: 'root'
                  script: 'touch /tmp/success.txt'
                }
                execSSH(data)
            )
        )
    )
})
