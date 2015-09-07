Template.deployVM.helpers(
  appVMName:->
    Session.get('appVMName')
  appVMContent:->
    Session.get('appVMContent')
  keys:->
    Session.get('keys')
)
Template.deployVM.created =->
    Session.set('appVMName','Not choice an option!')
    Session.set('appVMContent','Please select an application first.')
    Meteor.call 'showSSHKey', (err,res)->
      if not err
        message = res['ssh_keys']
        Session.set('keys',message)
      else
        console.log err
Template.deployVM.rendered =->
  $('ul.tabs').tabs()
  $('select').material_select()
  $('.collapsible').collapsible({
    accordion : false
  })
  $('textarea#sshKey').characterCounter()
  $('.modal-trigger').leanModal()
Template.deployVM.events({
  'click button#select': (e,t)->
    Session.set('appVMId',e.currentTarget.attributes.appId.value)
    Session.set('appVMName',e.currentTarget.parentNode.previousElementSibling.innerText)
    Session.set('appVMContent',e.currentTarget.parentElement.firstChild.innerText)
    $('#clickStep3').click()
  'click a#default':(e,t)->
    $('#clickStep2').click()
  'click a#finish':(e,t)->
    allDefine = true
    image = Session.get('appVMId')
    name = $('#vmname')[0].value
    size = $('#selectSize')[0].value
    region = ''
    obj = $("input[name='group1']")
    for i from 0 til obj.length
      if obj[i].checked
        region = obj[i].id
        break
    key = Session.get('key')
    if image is '' or image is undefined
        allDefine = false
        Materialize.toast('Application not select!', 4000)
    if name is '' or name is undefined
        allDefine = false
        Materialize.toast('VM Name not define!', 4000)
    if size is '' or size is undefined
        allDefine = false
        Materialize.toast('VM Size not select!', 4000)
    if region is '' or region is undefined
        allDefine = false
        Materialize.toast('Region not select!', 4000)
    if key is '' or key is undefined
      key = null
    if allDefine
      data = {
        name: name
        region: region
        size: size
        image: image
        ssh_keys: [key]
        backups: false
        ipv6: false
        user_data: null
        private_networking: null
      }
      Meteor.call 'createVM', data, (err,res)->
        if not err
          Router.go('/manage/service')
  'click a#selectKey':(e,t)->
    $(e.target).addClass('active')
    Session.set('key',e.target.attributes.keyid.value)
  'click button#addKeyPOP':(e,t)->
    $('#modal').openModal()
  'click a#createKey':(e,t)->
    key = $('#inputSSHKey')[0].value
    name = $('#keyName')[0].value
    data = {
      name: name
      public_key: key
    }
    Meteor.call 'addSSHKey', data, (err,res)->
      if not err
        keys = Session.get('keys')
        keys.push(res['ssh_key'])
        Session.set('keys',keys)
      else
        console.log err
})
