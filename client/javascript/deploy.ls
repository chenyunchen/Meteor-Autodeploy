Template.deployVM.helpers(
  clicked:->
    Session.get('clicked')
)
Template.deployVM.rendered =->
  Session.set('clicked',true)
  $('ul.tabs').tabs()
Template.deployVM.events({
  'click a#getStatus': (e,t)->
    data = {
      host: '128.199.226.157'
    }
    setInterval(->
      Meteor.call 'getStatus', data, (err,res)->
        if not err
          console.log res
        else
          console.log err
    , 2000)
  'click  a#test1': (e,t)->
    console.log '1'
  'click  a#test2': (e,t)->
    Session.set('clicked',false)
    console.log '2'
  'click  a#test3': (e,t)->
    console.log '3'
  'click  a#test4': (e,t)->
    console.log '4'
})
