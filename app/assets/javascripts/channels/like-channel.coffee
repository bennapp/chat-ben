class @LikeChannel
  constructor: (options) ->
    App.cable.subscriptions.create "LikeChannel",
      connected: ->
        onClickDislike = =>
          $like = $('#like')
          $dislike = $('#dislike')
          if $dislike.hasClass('btn-default')
            $dislike.removeClass('btn-default')
            $dislike.addClass('btn-danger')
            $like.addClass('btn-default')
            $like.removeClass('btn-primary')
            audio = document.getElementById('dislike-sound')
            audio.volume = 0.1
            audio.play()
            @perform("dislike", post_id: $('.post-header').data('post-id'))
          else
            $dislike.addClass('btn-default')
            $dislike.removeClass('btn-danger')
            audio = document.getElementById('like-sound')
            audio.volume = 0.1
            audio.play()
            @perform("undislike", post_id: $('.post-header').data('post-id'))

        onClickLike = =>
          $like = $('#like')
          $dislike = $('#dislike')
          if $like.hasClass('btn-default')
            $like.addClass('btn-primary')
            $like.removeClass('btn-default')
            $dislike.addClass('btn-default')
            $dislike.removeClass('btn-danger')
            audio = document.getElementById('like-sound')
            audio.volume = 0.1
            audio.play()
            @perform("like", post_id: $('.post-header').data('post-id'))
          else
            $like.addClass('btn-default')
            $like.removeClass('btn-primary')
            audio = document.getElementById('dislike-sound')
            audio.volume = 0.1
            audio.play()
            @perform("unlike", post_id: $('.post-header').data('post-id'))

        $('#like').unbind('click').click onClickLike
        $('#dislike').unbind('click').click onClickDislike

      disconnected: ->

      rejected: ->

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
