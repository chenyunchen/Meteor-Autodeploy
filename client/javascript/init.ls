Meteor.startup(->
  Uploader.uploadUrl = Meteor.absoluteUrl "upload"
)
