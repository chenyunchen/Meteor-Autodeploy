@Message = new Mongo.Collection('Message')

Message.allow({
  insert: (userId, doc)->
    return !! userId
  remove: (userId, doc)->
    return !! userId
})
