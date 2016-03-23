class @PostChannel
  constructor: (options) ->
    App.cable.subscriptions.create "PostChannel",
      connected: ->
        console.log('connected')

      disconnected: ->
        console.log('disconnected')

      rejected: ->
        console.log('rejected')

      received: (data) ->
        if (action = data["action"]) == 'num_waiting'
          postId = data["post_id"]
          numWaiting = data["num_waiting"]

          waitingToChatMessage = ' waiting to chat right now!'
          $badge = $('li#' + postId + ' .badge')
          $badge.tooltip().attr('data-original-title', numWaiting + waitingToChatMessage)
          $badge.text(numWaiting)
        else if action == 'new'
          #
        else


