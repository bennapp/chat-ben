#= require action_cable

class @Cable
  constructor: ->
    window.App = {}
    App.cable = ActionCable.createConsumer('/cable')
