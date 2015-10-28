Template.layout.helpers(
  chatMessages:->
    Message.find().fetch()
)
Template.layout.rendered = ->
  $(".dropdown-button").dropdown()
  $('.button-collapse').sideNav()
  $(document).ready(->
      $('.modal-trigger').leanModal()
  )

Template.layout.events({
  'click a#msgSend':(e,t)->
    msg = $('#msg')[0].value
    $('#msg')[0].value = ''
    user = Meteor.user()
    data =
      user:user
      message:msg
    Message.insert(data)
})
