Template.deployVM.rendered =->
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
  'click  li#test1': (e,t)->
    console.log '1'
  'click  li#test2': (e,t)->
    console.log '2'
  'click  li#test3': (e,t)->
    console.log '3'
  'click  li#test4': (e,t)->
    console.log '4'
})
