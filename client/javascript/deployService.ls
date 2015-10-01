Template.deployService.helpers(
    vm:->
        Session.get('vmList')
)
Template.deployService.created =->
    Session.set('moniter',false)
    Session.set('ipython',false)
    Meteor.call 'userVMInfo',(err,res)->
      if not err
          Session.set('vmList',res)

Template.deployService.events({
  'click a#status1': (e,t)->
      exist = false
      for domClass in e.currentTarget.classList
          if domClass is 'active'
              exist = true
      if exist
          $(e.target).removeClass('active')
          Session.set('moniter',false)
      else
          $(e.target).addClass('active')
          Session.set('moniter',true)
  'click a#status2': (e,t)->
      exist = false
      for domClass in e.currentTarget.classList
          if domClass is 'active'
              exist = true
      if exist
          $(e.target).removeClass('active')
          Session.set('ipython',false)
      else
          $(e.target).addClass('active')
          Session.set('ipython',true)
  'click a#new': (e,t)->
      $('#modal').openModal()


  'click a#confirm': (e,t)->
      for vm in Session.get('vmList')
          if vm.id.toString() is Session.get('vmId')
              data = {
                key: '/Users/yunchen/.ssh/id_rsa'
                host: vm.networks.v4[0].ip_address
                port: 22
                user: 'root'
              }
              if Session.get('moniter')
                  data.script = 'sudo docker run --volume=/:/rootfs:ro --volume=/var/run:/var/run:rw --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --publish=8080:8080 --detach=true --name=cadvisor google/cadvisor:latest'
              if Session.get('ipython')
                  data.script += ';sudo docker run -d -p 80:8888 --name=ipython_notebook -e "PASSWORD=default" -e "USE_HTTP=1" ipython/notebook'
              Meteor.call 'execSSH', data, (err,res)->
                  if not err
                      Meteor.defer(->
                          Router.go('/manage/service')
                          Materialize.toast('Service Create Success!', 4000)
                      )
                  else
                      console.log err
  'click li#select': (e,t)->
      exist = false
      for domClass in e.currentTarget.classList
          if domClass is 'active'
              exist = true
      if exist
          $(e.target).removeClass('active')
          Session.set('vmId','')
      else
          $(e.target).addClass('active')
          Session.set('vmId',e.currentTarget.attributes.vmid.value)
  'click a#popDockerfile': (e,t)->
      $('#dockerfileModal').openModal()
  'click a#popRunShell': (e,t)->
      $('#runShellModal').openModal()
  'click a#dockerfileCreate': (e,t)->
    dockerfile = $('#dockerfile')[0].value
    imageName = $('#imageName')[0].value
    data = {
      dockerfile: dockerfile
      imageName: imageName
    }
    Meteor.call 'dockerfileUpload', data, (err,res)->
      if not err
        console.log res
})
