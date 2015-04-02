root = exports ? this
root.Applications = new Meteor.Collection('applications')
root.Distributions = new Meteor.Collection('distributions')

Meteor.methods({
  'distributionInfo': ->
    distribution = []
    user = Meteor.user()
    response = Meteor.sync (done)->
      HTTP.call('GET','https://api.digitalocean.com/v2/images?type=distribution',
        headers:
          'Authorization': 'Bearer ' +  user.services.digitalocean.accessToken
          'Content-Type': 'application/x-www-form-urlencoded'
        (err,res)->
          if not err
            data = EJSON.parse(res.content)
            images = data.images
            if Distributions.find().count() > 0
                id = Distributions.findOne({})['_id']
                Distributions.update({
                  _id: id
                },{
                  $set: {images: images}
                })
            else
                Distributions.insert({images: images})
            done(null,images)
          else
            throw new Meteor.Error(500, err)
      )
    return response.result
})

Meteor.methods({
  'applicationInfo': ->
    user = Meteor.user()
    response = Meteor.sync (done)->
      HTTP.call('GET','https://api.digitalocean.com/v2/images?type=application',
        headers:
          'Authorization': 'Bearer ' +  user.services.digitalocean.accessToken
          'Content-Type': 'application/x-www-form-urlencoded'
        (err,res)->
          if not err
            data = EJSON.parse(res.content)
            images = data.images
            if Applications.find().count() > 0
                id = Applications.findOne({})['_id']
                Applications.update({
                  _id: id
                },{
                  $set: {images: images}
                })
            else
                Applications.insert({images: images})
            done(null,images)
          else
            throw new Meteor.Error(500, err)
      )
    return response.result
})
