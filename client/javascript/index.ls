Template.index.events({
  'click a#createVM': (e,t)->
    data = {
      userId = Meteor.user()._id
      vmName = 'test-droplets'
      vmRegion = 'sgp1'
      vmSize = '512mb'
      vmImage = 7354580
    }
    Meteor.call 'test', data, (err,res)->
      if not err
        console.log res
      else
        console.log err

  'click a#removeVM': (e,t)->
    userId = Meteor.user()._id
    Meteor.call 'test2', userId, (err,res)->
      if not err
        console.log res
      else
        console.log err

  'click a#userInfo': (e,t)->
    Meteor.call 'userInfo', (err,res)->
      if not err
        console.log res
      else
        console.log err

  'click a#imageInfo': (e,t)->
    Meteor.call 'imageInfo', (err,res)->
      if not err
        console.log res
      else
        console.log err
})
