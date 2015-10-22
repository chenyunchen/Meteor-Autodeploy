data =
  host: 'yunchen.cloudapp.net'
  port: 1234
Template.manageBackUp.helpers(
  host:->
      data.host+':'+data.port
  capacity:->
      Session.get('capacity')
  usage:->
      Session.get('usage')
  imageList:->
      Session.get('imageList')
)
Template.manageBackUp.rendered =->
  Meteor.call 'getRegStatus', data, (err,res)->
    if err
      console.log err
    else
      Session.set('capacity',res.capacity)
      Session.set('usage',res.usage)
Template.manageBackUp.created =->
  Meteor.call 'getRegList', (err,res)->
    if err
      console.log err
    else
      Session.set('imageList',res)
