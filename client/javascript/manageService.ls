Template.manageService.helpers(
  userVMInfo:->
    Session.get('userVMInfo')
  userVMServiceInfo:->
    Session.get('userVMServiceInfo')
  openModal2:->
    Session.get('openModal2')
  host:->
    Session.get('selectHost')
)

Template.manageService.created =->
  Session.set('demo',false)
  Meteor.call 'userVMInfo', (err,res)->
    if err
      console.log err
    else
      Session.set('userVMInfo',res)

Template.manageService.events({
  'click a#status': (e,t)->
    data = {
        host: this.networks.v4[0].ip_address
    }
    Session.set('selectHost',data.host)
    cpuAdd = 0
    memoryAdd = 0
    demoDone = false
    getVMStatus = setInterval(~>
      Meteor.call 'getStatus', data, (err,res)->
        if err
          console.log err
        else
          if Session.get('demo')
            cpuAdd += 10
            memoryAdd += 10
            for obj,index in res
              if obj.name is 'slswithdb_wecosls_1'

                if obj.cpuUsage+cpuAdd >= 100
                  obj.cpuUsage = 100
                else
                  obj.cpuUsage += cpuAdd
                if obj.memoryUsage+memoryAdd >= 100
                  obj.memoryUsage = 100
                  if not demoDone
                    demoDone = true
                    setInterval(~>
                      Session.set('demo',false)
                    , 5000)
                  res.splice(index,1)
                  continue
                else
                  obj.memoryUsage += memoryAdd


                if obj.cpuUsage >= 90 or obj.memoryUsage >= 90
                  obj.statusColor = 'red'
                else if obj.cpuUsage >= 70 or obj.memoryUsage >= 70
                  obj.statusColor = 'orange'
                else if obj.cpuUsage >= 50 or obj.memoryUsage >= 50
                  obj.statusColor = 'yellow'
                else
                  obj.statusColor = ''

          Session.set('userVMServiceInfo',res)
    , 2000)
    Session.set('openModal2',false)
    $('#modal1').openModal({
      complete:~>
        Session.set('openModal2',true)
        clearInterval(getVMStatus)
    })
  'click a#setService': (e,t)->
    $('#modal2').openModal()
  'click a#setServiceBtn': (e,t)->
    limit =
      cpu: $('#cpuLimit')[0].value
      memory: $('#memLimit')[0].value
      tx: $('#txLimit')[0].value
      rx: $('#rxLimit')[0].value
    Session.set('limit',limit)
  'click a#service': (e,t)->
    vmServices = Session.get('userVMServiceInfo')
    index = 0
    for obj,i in vmServices
        if obj.id is e.currentTarget.attributes.serviceid.value
            index = i
    vmServices.splice(index,1)
    data = {
      script: 'sudo docker rm -f ' + e.currentTarget.attributes.serviceid.value
      key: '/Users/yunchen/.ssh/id_rsa'
      host: Session.get('selectHost')
      port: 22
      user: 'root'
    }
    Meteor.call 'execSSH', data, (err,res)->
      if not err
          Materialize.toast('Service Delete Success!', 4000)
      else
          console.log err
  'click a#deleteVM': (e,t)->
    id = e.target.attributes.vmid.value
    userVMInfo = Session.get('userVMInfo')
    Meteor.call 'removeVM', id, (err,res)->
      if not err
        for vm,index in userVMInfo
          if vm.id is parseInt(id)
            userVMInfo.splice(index,1)
            break
        Materialize.toast('VM Delete Success!', 4000)
        Session.set('userVMInfo',userVMInfo)
  'click a#demo':(e,t)->
    Session.set('demo',true)
})
