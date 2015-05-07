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
  this.route 'deployVM', {
    path: '/deploy/vm'
  }
  this.route 'account', {
    path: '/account'
  }
