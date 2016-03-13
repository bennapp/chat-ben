#= require action_cable
#= require_self
#= require_tree .

@App = {}
App.cable = ActionCable.createConsumer('/cable')

App.cable.subscriptions.create "AppearanceChannel",
  # Called when the subscription is ready for use on the server
  connected: ->
    console.log('connected')
    # @appear()

  # Called when the WebSocket connection is closed
  disconnected: ->
    console.log('disconnected')

  # Called when the subscription is rejected by the server
  rejected: ->
    console.log('rejected')

  appear: ->
    # Calls `AppearanceChannel#appear(data)` on the server
    @perform("appear", appearing_on: 'some data')
