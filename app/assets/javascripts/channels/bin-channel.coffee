class @BinChannel
  constructor: (options) ->
    binId = options.binId
    return unless binId

    App.cable.subscriptions.create { channel: "BinChannel", bin_id: binId },
      connected: ->

      disconnected: ->

      rejected: ->

      received: (data) ->
        action = data.action
        if action == 'new_top_post'
          $('.page-header').after("<div class=\"flash notice alert alert-info\">Holy smokes! We just changed what was playing on this channel!!!</div>")
          $('.flash.notice').delay(3500).fadeOut(1400)
          window.nextPost(data.post_id, firstPost: true)
