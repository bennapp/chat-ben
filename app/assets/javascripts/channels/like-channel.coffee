class @LikeChannel
  constructor: (options) ->
    App.cable.subscriptions.create "LikeChannel",
      connected: ->
        console.log('connected to some likes! Websockets are happening?!')
        $('#like').click =>
          $like = $('#like')
          if $like.hasClass('btn-default')
            $like.removeClass('btn-default')
            $like.addClass('btn-primary')
            @perform("like", post_id: $('.post-header')[0].id)
          else
            @perform("unlike", post_id: $('.post-header')[0].id)
            $like.addClass('btn-default')
            $like.removeClass('btn-primary')

      disconnected: ->
        console.log('disconnected')

      rejected: ->
        console.log('rejected')

      received: (data) ->
        if data.action == 'like_count'
          $('.like-count[data-post-id="' + data.post_id + '"]').text(data.like_count)


