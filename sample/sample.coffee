@Users = new Meteor.Collection("users")
@Counters = new Meteor.Collection("counters")

if Meteor.isClient
  state = (stateName) -> Session.set("state", stateName)
  
  findAllUsers = () -> Users.find {}, { sort:{id:1}}
  findUser = (userid) -> Users.findOne id:parseInt userid
  deleteUser = (userid) -> Users.remove id:parseInt userid
  updateUser = (user) -> Users.update {_id:user._id}, user
  insertUser = (user) ->
    if Counters.find().count() is 0
      Counters.insert c:0

    Counters.update {}, {$inc:{c:1}}
    count = Counters.findOne {}
    user.id = count.c
    Users.insert user

  Handlebars.registerHelper "stateIs", (stateName) ->
    return Session.get("state") is stateName

  Template.users.users = () ->
    return findAllUsers()

  Template.show.user = () ->
    return findUser Session.get("userid")

  Template.show.notice = () ->
    Session.get "notice"

  Template._form.user = () ->
    userid = Session.get("userid")
    findUser userid if userid

  Template._form.events =
    "click #create" : () ->
      user =
        name : $("#user_name").val()
        email: $("#user_email").val()

      insertUser user
      Session.set "notice", "User was successfully created."
      router.navigate "user/#{user.id}", true

    "click #update" : () ->
      user = findUser Session.get("userid")
      user.name = $("#user_name").val()
      user.email = $("#user_email").val()

      updateUser user
      Session.set "notice", "User was successfully updated."
      router.navigate "user/#{user.id}", true

  UserRouter = Backbone.Router.extend
    routes:
      "" : "index"
      "user" : "index"
      "user/new" : "newUser"
      "user/:id" : "show"
      "user/:id/edit" : "edit"
      "user/:id/destroy" : "destroy"
    index : () ->
      state "index"
    show : (id) ->
      Session.set "userid", id
      state "show"
    edit : (id) ->
      Session.set "userid", id
      state "edit"
    destroy : (id) ->
      deleteUser id
      state "index"
    newUser : () ->
      Session.set "userid", null
      state "newUser"

  router = new UserRouter
  
  Meteor.startup () ->
    state "index"
    Backbone.history.start pushState: true

if Meteor.isServer
  Meteor.startup () -> 
