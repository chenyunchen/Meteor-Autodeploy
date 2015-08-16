

Template.manageService.helpers(
  userVMInfo:->
    Session.get('userVMInfo')
  userVMServiceInfo:->
    Session.get('userVMServiceInfo')
)

Template.manageService.created =->
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
    getVMStatus = setInterval(~>
      Meteor.call 'getStatus', data, (err,res)->
        if err
          console.log err
        else
          Session.set('userVMServiceInfo',res)
    , 2000)
    $('#modal1').openModal({
      complete:~>
        clearInterval(getVMStatus)
    })
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
})
