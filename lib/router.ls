Router.configure({
  layoutTemplate: 'layout'
  data:->
    @subscribe('Message')
})
Router.map ->
  this.route 'index',
    path: '/'
  this.route 'create',
    path: '/create'
  this.route 'deployVM',
    path: '/deploy/vm'
  this.route 'deployService',
    path: '/deploy/service'
  this.route 'manageService',
    path: '/manage/service'
  this.route 'manageBackUp',
    path: '/manage/backup'
