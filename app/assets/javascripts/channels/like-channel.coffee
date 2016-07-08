class @LikeChannel
  constructor: (options) ->
    App.cable.subscriptions.create "LikeChannel",
      connected: ->

      disconnected: ->

      rejected: ->

      received: (data) ->
        if data.action == 'total_users'
          $('#total-users').text(data.value)
