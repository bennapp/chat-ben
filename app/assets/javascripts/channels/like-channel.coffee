class @LikeChannel
  constructor: (options) ->
    App.cable.subscriptions.create "LikeChannel",
      connected: ->
        console.log('connected to some likes! Websockets are happening?!')

        $('#like').click =>
          $like = $('#like')
          $dislike = $('#dislike')
          if $like.hasClass('btn-default')
            $like.removeClass('btn-default')
            $like.addClass('btn-primary')
            $dislike.addClass('btn-default')
            $dislike.removeClass('btn-danger')
            document.getElementById('like-sound').play()
            @perform("like", post_id: $('.post-header')[0].id)
          else
            $like.addClass('btn-default')
            $like.removeClass('btn-primary')
            document.getElementById('dislike-sound').play()
            @perform("unlike", post_id: $('.post-header')[0].id)

        $('#dislike').click =>
          $like = $('#like')
          $dislike = $('#dislike')
          if $dislike.hasClass('btn-default')
            $dislike.removeClass('btn-default')
            $dislike.addClass('btn-danger')
            $like.addClass('btn-default')
            $like.removeClass('btn-primary')
            document.getElementById('dislike-sound').play()
            @perform("dislike", post_id: $('.post-header')[0].id)
          else
            $dislike.addClass('btn-default')
            $dislike.removeClass('btn-danger')
            document.getElementById('like-sound').play()
            @perform("undislike", post_id: $('.post-header')[0].id)

      disconnected: ->
        console.log('disconnected')

      rejected: ->
        console.log('rejected')

      received: (data) ->
        if data.action == 'like_count'
          $('.like-count[data-post-id="' + data.post_id + '"]').text(data.like_count)
        else if data.action == 'total_users'
          $('#total-users').text(data.value)
        else if data.action == 'like'
          if data.like
            document.getElementById('like-sound').play()
          else
            document.getElementById('dislike-sound').play()



