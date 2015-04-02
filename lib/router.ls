Router.configure({
  layoutTemplate: 'layout'
})
Router.map ->
  this.route 'index', {
    path: '/'
  }
  this.route 'create', {
    path: '/create'
  }
