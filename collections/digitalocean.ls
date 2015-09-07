root = exports ? this
root.Applications = new Meteor.Collection('applications')
root.Distributions = new Meteor.Collection('distributions')

Meteor.methods({
  'createVMInfo': ->
    type = 'application'
    distribution = []
    user = Meteor.user()
    response = Meteor.sync (done)->
      HTTP.call('GET','https://api.digitalocean.com/v2/images?type='+type+'&page=2',
        headers:
          'Authorization': 'Bearer ' +  user.services.digitalocean.accessToken
          'Content-Type': 'application/x-www-form-urlencoded'
        (err,res)->
          if not err
            data = EJSON.parse(res.content)
            console.log data
            images = data.images
            done(null,images)
          else
            throw new Meteor.Error(500, err)
      )
    return response.result
})
