Router.configure({
  layoutTemplate: 'layout'
})
Router.map ->
  this.route 'index', {
    path: '/'
  }
  this.route 'info', {
    where: 'server'
    path: '/info'
    action: ->
      console.log this.userId
  }
