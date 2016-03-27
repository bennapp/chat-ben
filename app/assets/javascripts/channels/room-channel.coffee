class @RoomChannel
  constructor: (options) ->
    roomToken = options.roomToken

    App.cable.subscriptions.create { channel: "RoomChannel", room: roomToken },
      connected: ->
        console.log('connected')

      disconnected: ->
        console.log('disconnected')

      rejected: ->
        console.log('rejected')

      received: (data) ->
        console.log data
